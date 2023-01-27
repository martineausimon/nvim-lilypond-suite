local b, g, fn, cmd = vim.b, vim.g, vim.fn, vim.cmd
local shellescape = vim.fn.shellescape
local expand = vim.fn.expand
local include_dir = nvls_options.lilypond.options.include_dir
if type(include_dir) == "table" then
  include_dir = table.concat(include_dir, " -I ")
end

local makeLualatex = "lualatex" ..
    " --output-directory=" .. shellescape(expand('%:p:h')) .. 
    " --shell-escape" ..
    " --interaction=nonstopmode %:p:S"

local lualatexEfm = "%+G! LaTeX %trror: %m," ..
    "%+GLaTeX %.%#Warning: %.%#line %l%.%#," ..
    "%+GLaTeX %.%#Warning: %m," ..
    "%+G! %m,%+El.%l %m,%-G%.%#"

local makeLytex = "cd " .. shellescape(tmpOutDir) .. 
  " && " .. "lualatex" ..
    " --output-directory=" .. shellescape(expand('%:p:h')) ..
    " --shell-escape " ..
    "--interaction=nonstopmode " .. 
    shellescape(tmpOutDir .. expand('%:t:r') .. '.tex')

local makeLilypondBook = "lilypond-book" .. 
    " -I " .. include_dir .. 
    " --output=" .. shellescape(tmpOutDir) .. " %:p:S"

local lilypondBookEfm = '%+G%f:%l:%c:, %f:%l:%c: %m,%-G%.%#'

local M = {}

function M.DetectLilypondSyntax()
  if g.lytexSyn == 1 then
    g.lytexSyn = 0
    cmd[[set syntax=tex]]
    return
  elseif fn.search("begin{lilypond}", "n") ~= 0 then
    b.current_syntax = nil
    cmd('syntax include @TEX syntax/tex.vim')
    b.current_syntax = nil
    cmd('syntax include @lilypond syntax/lilypond.vim')
    cmd [[ 
    syntax region litex 
      \ matchgroup=Snip 
      \ start="\\begin{lilypond}" 
      \ end="\\end{lilypond}" 
      \ containedin=@TEX 
      \ contains=@lilypond
    ]]
    cmd('filetype plugin on')
    b.current_syntax = "litex"
    g.lytexSyn = 1
  end
end

function M.SelectMakePrgType()
  if fn.search("usepackage{lyluatex}", "n") ~= 0 then
    require('nvls').make(makeLualatex,lualatexEfm,"lualatex")
  elseif fn.search("begin{lilypond}", "n") ~= 0 then
    require('nvls').make(makeLilypondBook,lilypondBookEfm,"lilypond-book")
  else
    require('nvls').make(makeLualatex,lualatexEfm,"lualatex")
  end
end

function M.lytexCmp()
  require('nvls').make(makeLytex,lualatexEfm,"lualatex")
end

return M
