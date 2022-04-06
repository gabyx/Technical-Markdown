--- Pandoc filter to set the meta data 'abstract' variable

local List = require 'pandoc.List'

local abstract = nil
function set(meta)
  if abstract then
    io.stderr:write("Settings meta data abstract ... \n")
    meta['abstract'] = pandoc.MetaBlocks(abstract)
    return meta
  end
  return nil
end

function set_abstract(d)

  if d.classes:includes 'abstract' then
      -- Only in latex emoticons need to be replaced
      if FORMAT:match("latex") then
        abstract = d.content
        return List() -- remove the content
      end
  end
  return nil -- dont do anything
end

return {
    {Div = set_abstract},
    {Meta = set}
}
