local shellescape = vim.fn.shellescape
local expand = vim.fn.expand
local texPdfFile = shellescape(expand('%:p:r') .. '.pdf')
local M = {}
vim.b.tmpOutDir = expand('%:p:h') .. '/tmpOutDir/'

function M.DetectLilypondSyntax()
  if vim.g.lytexSyn == 1 then
    vim.g.lytexSyn = 0
    vim.cmd[[set syntax=tex]]
    return
  else
    if vim.fn.search("begin{lilypond}", "n") ~= 0 then
      vim.b.current_syntax = nil
      vim.cmd('syntax include @TEX syntax/tex.vim')
      vim.b.current_syntax = nil
      vim.cmd('syntax include @lilypond syntax/lilypond.vim')
      vim.cmd [[ 
      syntax region litex 
        \ matchgroup=Snip 
        \ start="\\begin{lilypond}" 
        \ end="\\end{lilypond}" 
        \ containedin=@TEX 
        \ contains=@lilypond
      ]]
      vim.cmd('filetype plugin on')
      vim.b.current_syntax = "litex"
      vim.g.lytexSyn = 1
    end
  end
end

function M.SelectMakePrgType()
  if vim.fn.search("usepackage{lyluatex}", "n") ~= 0 then
    require('tex').lualatexCmp()
  else 
    if vim.fn.search("begin{lilypond}", "n") ~= 0 then
      require('tex').lilypondBookCmp()
    else
      require('tex').lualatexCmp()
    end
  end
end

function M.lytexCmp()
  vim.b.nvls_cmd = "lualatex"
  vim.b.nvls_makeprg = "cd " .. shellescape(vim.b.tmpOutDir) .. 
  " && " .. vim.b.nvls_cmd ..
    " --output-directory=" .. shellescape(expand('%:p:h')) ..
    " --shell-escape " ..
    "--interaction=nonstopmode " .. 
    shellescape(vim.b.tmpOutDir .. expand('%:t:r') .. '.tex')
  vim.b.nvls_efm = "%+G! LaTeX %trror: %m," ..
    "%+GLaTeX %.%#Warning: %.%#line %l%.%#," ..
    "%+GLaTeX %.%#Warning: %m," ..
    "%+G! %m,%+El.%l %m,%-G%.%#"
  require('nvls').make()
end

function M.lualatexCmp()
  vim.b.nvls_cmd = "lualatex"
  vim.b.nvls_makeprg = vim.b.nvls_cmd ..
    " --output-directory=" .. shellescape(expand('%:p:h')) .. 
    " --shell-escape" ..
    " --interaction=nonstopmode %:p:S"
  vim.b.nvls_efm = "%+G! LaTeX %trror: %m," ..
    "%+GLaTeX %.%#Warning: %.%#line %l%.%#," ..
    "%+GLaTeX %.%#Warning: %m," ..
    "%+G! %m,%+El.%l %m,%-G%.%#"
  require('nvls').make()
end

function M.lilypondBookCmp()
  vim.b.nvls_cmd = "lilypond-book"
  vim.b.nvls_makeprg = vim.b.nvls_cmd .. 
    " --output=" .. shellescape(vim.b.tmpOutDir) .. " %:p:S"
  vim.b.nvls_efm = '%+G%f:%l:%c:, %f:%l:%c: %m,%-G%.%#'
  require('nvls').make()
end

function M.texViewer()
  vim.fn.jobstart('xdg-open ' .. texPdfFile)
end

return M
