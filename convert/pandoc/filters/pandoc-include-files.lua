--- include-files.lua – filter to include Markdown files
---
--- Copyright: © 2019–2020 Albert Krewinkel
--- License:   MIT – see LICENSE file for details

-- pandoc's List type
local List = require 'pandoc.List'

-------------------------------------

-- This is the codeblock-var-replace
-- filter directly copied, since we
-- cannot run Lua filters inside this filter
-- https://github.com/jgm/pandoc/issues/6830
-- We replace variables in include blocks.

local sys = require 'pandoc.system'
local utils = require 'pandoc.utils'
local ut = require "module-lua.utils"

-- Save env. variables
local env = sys.environment()

-- Save meta table and metadata
local meta
function save_meta (m)
  meta = m
end

--- Replace variables in code blocks
local function var_replace_codeblocks (cb)

  --- Replace variable with values from environment
  --- and meta data (stringifing).
  local function replace(what, var)

    if what == "env" then
      return env[var]
    elseif what == "meta" then
      local v = meta[var]
      if v then
        return utils.stringify(v)
      end
    end
    return nil
  end

  -- ignore code blocks which are not of class "var-replace".
  if not cb.classes:includes 'var-replace' then
    return
  end

  cb.text = cb.text:gsub("%${(%l+):([^}]+)}", replace)
end


-------------------------------------

--- Get default settings
local include_auto = false
local default_format = nil
local include_fail_if_read_error = false

function get_vars (meta)
  if meta['include-auto'] then
    include_auto = true
  end

  if meta['include-fail-if-read-error'] then
    include_fail_if_read_error = true
  end

  -- If this is nil, markdown is used as a default format.
  default_format = meta['include-format']
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
local function is_included(cb)
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

  -- replace vars
  var_replace_codeblocks(cb)

  -- Filter by includes and excludes
  if not is_included(cb) then
    return List{} -- remove block
  end

  local format = cb.attributes['format']
  if not format then
    -- Markdown is used if this is nil.
    format = default_format
  end

  -- Check if we include the file as raw inline
  local raw = cb.attributes['raw']
  raw = raw == "true" and true or false

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

      -- Replace extension if specified
      line = replace_ext(cb, line)
      io.stderr:write(string.format("Including: [format: %s, raw: %s]\n - '%s'\n", format, tostring(raw), line))

      local fh = io.open(line)
      if not fh then
        io.stderr:write("Cannot open file " .. line .. " | Skipping includes\n")
        if include_fail_if_read_error then
          error("Abort due to read failure")
        end
      else
        text = fh:read('*a')
        fh:close()

        if raw then
          -- Inlcude as raw inline element
          blocks:extend({pandoc.RawBlock(format, text)})
        else
          -- Inlcude as parsed AST
          local contents = pandoc.read(text, format).blocks
          last_heading_level = 0
          -- recursive transclusion
          contents = pandoc.walk_block(
            pandoc.Div(contents),
            { Header = update_last_level, CodeBlock = transclude }
            ).content

          --- reset to level before recursion
          last_heading_level = buffer_last_heading_level
          blocks:extend(shift_headings(contents, shift_heading_level_by))
        end
      end

      ::skip::
    end
  end
  return blocks
end

return {
  { Meta = save_meta },
  { Meta = get_vars },
  { Header = update_last_level, CodeBlock = transclude }
}
