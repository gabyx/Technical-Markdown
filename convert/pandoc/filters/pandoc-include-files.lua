--- include-files.lua – filter to include Markdown files
---
--- Copyright: © 2019–2020 Albert Krewinkel
--- License:   MIT – see LICENSE file for details

-- pandoc's List type
local List = require 'pandoc.List'

--- Get include auto mode
local include_auto = false
function get_vars (meta)
  if meta['include-auto'] then
    include_auto = true
  end
end

--- Keep last heading level found
local last_heading_level = 0
function update_last_level(header)
  last_heading_level = header.level
end

--- Shift headings in block list by given number
local function shift_headings(blocks, shift_by)
  if not shift_by then
    return blocks
  end

  local shift_headings_filter = {
    Header = function (header)
      header.level = header.level + shift_by
      return header
    end
  }

  return pandoc.walk_block(pandoc.Div(blocks), shift_headings_filter).content
end

--- Include/exclude by attribute
--- `exclude-if-format='formatA;formatB;...'
--- `include-if-format='formatA;formatB;...`
--- Default: true
local function is_included(cb, file)
  local include = true
  local exclude = false

  if cb.attributes['include-if-format'] then
    include = cb.attributes['include-if-format']:match(FORMAT) ~= nil
  end

  if cb.attributes['exclude-if-format'] then
    exclude = cb.attributes['exclude-if-format']:match(FORMAT) ~= nil
  end

  return include == true and exclude == false
end

--- Replace extension by attribute `replace-ext-if-format='formatA:<extB>;formatB:<extA>;...'
local function replace_ext(cb, file)
  if cb.attributes['replace-ext-if-format'] then
    local new_ext = cb.attributes['replace-ext-if-format']:match(FORMAT..":([^;]*)")
    if new_ext then
        file, count = file:gsub("^(.+)%..+$", "%1".. new_ext, 1)
        if not count then
          -- If no extension replaced, add to the back
          file = file + new_ext
        end
    end
  end
  return file
end

--- Filter function for code blocks
local transclude
function transclude (cb)
  -- ignore code blocks which are not of class "include".
  if not cb.classes:includes 'include' then
    return
  end

  -- Markdown is used if this is nil.
  local format = cb.attributes['format']

  -- Attributes shift headings
  local shift_heading_level_by = 0
  local shift_input = cb.attributes['shift-heading-level-by']
  if shift_input then
    shift_heading_level_by = tonumber(shift_input)
  else
    if include_auto then
      -- Auto shift headings
      shift_heading_level_by = last_heading_level
    end
  end

  --- keep track of level before recursion
  local buffer_last_heading_level = last_heading_level

  local blocks = List:new()
  for line in cb.text:gmatch('[^\n]+') do
    if line:sub(1,2) ~= '//' then

      -- Filter by includes and excludes
      if not is_included(cb, line) then
        io.stderr:write("Excluding: '" .. line .. "'\n")
        goto skip
      end

      -- Replace extension if specified
      line = replace_ext(cb, line)

      io.stderr:write("Including: '" .. line .. "'\n")

      local fh = io.open(line)
      if not fh then
        io.stderr:write("Cannot open file " .. line .. " | Skipping includes\n")
      else
        local contents = pandoc.read(fh:read '*a', format).blocks
        last_heading_level = 0
        -- recursive transclusion
        contents = pandoc.walk_block(
          pandoc.Div(contents),
          { Header = update_last_level, CodeBlock = transclude }
          ).content
        --- reset to level before recursion
        last_heading_level = buffer_last_heading_level
        blocks:extend(shift_headings(contents, shift_heading_level_by))
        fh:close()
      end

      ::skip::
    end
  end
  return blocks
end

return {
  { Meta = get_vars },
  { Header = update_last_level, CodeBlock = transclude }
}
