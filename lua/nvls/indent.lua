local M = {}

function M.lilypond()
  local ind = 0
  if vim.fn.line(".") == 1 then return ind end
  local lnum = vim.fn.prevnonblank(vim.fn.line(".") - 1)
  if string.match(vim.fn.getline(lnum), '^.*[{<]%s*$') then
    ind = vim.fn.indent(lnum) + vim.bo.sw
  else
    ind = vim.fn.indent(lnum)
  end
  if string.match(vim.fn.getline(vim.fn.line(".")), '^.*[}>]%s*$') then
    ind = ind - vim.bo.sw
  end
  for _, id in ipairs(vim.fn.synstack(lnum, 1)) do
    if vim.fn.synIDattr(id, "name") == "lilyScheme" then
      ind = vim.fn.lispindent(vim.fn.line("."))
    end
  end
  return ind
end

return M
