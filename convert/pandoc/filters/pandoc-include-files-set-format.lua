-- https://github.com/pandoc/lua-filters/issues/101
function CodeBlock (cb)
  if cb.classes:includes('.include') then
    cb.attributes.format = 'markdown+emoji'
  end
  return cb
end