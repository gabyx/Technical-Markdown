-- https://github.com/pandoc/lua-filters/issues/101

format = nil

function setFormatIncludeBlock (cb)
  if cb.classes:includes('include') and cb.attributes['format'] == nil then
    cb.attributes.format = format
  end
  return cb
end


function setFormat(doc)
    format = doc.meta["include-format"]
    io.stderr:write("Settings include blocks to format: " .. format .. "\n")

    local blks =  pandoc.walk_block(
      pandoc.Div(doc.blocks),
      { CodeBlock = setFormatIncludeBlock }
    ).content

    return pandoc.Pandoc(blks, doc.meta)
end

return {
  {Pandoc = setFormat}
}