local shellescape = vim.fn.shellescape
local expand = vim.fn.expand

local makeLualatex = "lualatex" ..
    " --output-directory=" .. shellescape(expand('%:p:h')) .. 
    " --shell-escape" ..
    " --interaction=nonstopmode %:p:S"

local lualatexEfm = "%+G! LaTeX %trror: %m," ..
    "%+GLaTeX %.%#Warning: %.%#line %l%.%#," ..
    "%+GLaTeX %.%#Warning: %m," ..
    "%+G! %m,%+El.%l %m,%-G%.%#"

local makeLytex = "cd " .. shellescape(vim.b.tmpOutDir) .. 
  " && " .. "lualatex" ..
    " --output-directory=" .. shellescape(expand('%:p:h')) ..
    " --shell-escape " ..
    "--interaction=nonstopmode " .. 
    shellescape(vim.b.tmpOutDir .. expand('%:t:r') .. '.tex')

local makeLilypondBook = "lilypond-book" .. 
    " --output=" .. shellescape(vim.b.tmpOutDir) .. " %:p:S"

local lilypondBookEfm = '%+G%f:%l:%c:, %f:%l:%c: %m,%-G%.%#'

local M = {}

function M.DetectLilypondSyntax()
  if vim.g.lytexSyn == 1 then
    vim.g.lytexSyn = 0
    vim.cmd[[set syntax=tex]]
    return
  elseif vim.fn.search("begin{lilypond}", "n") ~= 0 then
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

function M.SelectMakePrgType()
  if vim.fn.search("usepackage{lyluatex}", "n") ~= 0 then
    vim.b.nvls_cmd = "lualatex"
    require('nvls').make(makeLualatex,lualatexEfm)
  elseif vim.fn.search("begin{lilypond}", "n") ~= 0 then
    vim.b.nvls_cmd = "lilypond-book"
    require('nvls').make(makeLilypondBook,lilypondBookEfm)
  else
    vim.b.nvls_cmd = "lualatex"
    require('nvls').make(makeLualatex,lualatexEfm)
  end
end

function M.lytexCmp()
  vim.b.nvls_cmd = "lualatex"
  require('nvls').make(makeLytex,lualatexEfm)
end

return M
