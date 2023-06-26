local b, g, fn, cmd = vim.b, vim.g, vim.fn, vim.cmd
local expand = vim.fn.expand
local shellescape = require('nvls').shellescape
local include_dir = nvls_options.lilypond.options.include_dir or nil
if type(include_dir) == "table" then
  include_dir = table.concat(include_dir, " -I ")
end

local M = {}

function M.DefineTexVars()
  nvls_main = shellescape(expand('%:p'))
  local main_file = nvls_options.latex.options.main_file
  main_folder = nvls_options.latex.options.main_folder

  if io.open(fn.glob(main_folder .. '/.lilyrc')) then
    dofile(expand(main_folder) .. '/.lilyrc')
    nvls_main = shellescape(expand(main_folder) .. "/" .. main_file)
    if not io.open(fn.glob(nvls_main)) then
      nvls_main = shellescape(expand('%:p'))
    end

  elseif io.open(fn.glob(expand(main_folder) .. '/' .. 
    main_file)) then
      nvls_main = shellescape(expand(main_folder) .. "/" .. main_file)
  end

  local name = nvls_main:gsub("%.(tex)", "")
  nvls_main_name = name
  nvls_short = nvls_main_name:match('/([^/]+)$')
  nvls_file_name = nvls_short:gsub([[\]], "")
  texPdf = shellescape(expand(nvls_main_name) .. '.pdf')
  tmpOutDir = expand(main_folder) .. '/tmpOutDir/'

  makeLualatex = 'lualatex' ..
      ' --file-line-error' ..
      ' --output-directory=' .. shellescape(expand(main_folder)) .. 
      ' --shell-escape' ..
      ' --interaction=nonstopmode ' .. nvls_main

  lualatexEfm = "%f:%l:%m,%-G%.%#"

  makeLytex = 'cd ' .. shellescape(tmpOutDir) .. 
    ' && ' .. 'lualatex' ..
      ' --file-line-error' ..
      ' --output-directory=' .. shellescape(expand(main_folder)) ..
      ' --shell-escape ' ..
      '--interaction=nonstopmode ' .. 
      shellescape(tmpOutDir .. expand(nvls_file_name) .. '.tex')

  makeLilypondBook = 'lilypond-book ' .. 
    (include_dir and '-I ' .. include_dir or '') .. 
      ' --output=' .. shellescape(tmpOutDir) .. ' ' ..
      shellescape(expand(nvls_main))

  lilypondBookEfm = '%+G%f:%l:%c:, %f:%l:%c: %m,%-G%.%#'

end

function M.ToggleLilypondSyntax()
  if g.lytexSyn == 1 then
    g.lytexSyn = 0
    cmd[[set syntax=tex]]
    return
  else
  M.DetectLilypondSyntax()
  end
end
    
function M.DetectLilypondSyntax()
  if fn.search("\\\\begin{lilypond}[^%]*$", "nw") ~= 0 then
    b.current_syntax = nil
    cmd('syntax include @TEX syntax/tex.vim')
    b.current_syntax = nil
    cmd('syntax include @lilypond syntax/lilypond.vim')
    cmd [[ 
    syntax region litex 
      \ matchgroup=Snip 
      \ start="\(%.\{}\)\@<!\\begin{lilypond}" 
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
  M.DefineTexVars()

  if fn.search("usepackage{lyluatex}", "n") ~= 0 then
    require('nvls').make(makeLualatex,lualatexEfm,"lualatex")
  elseif fn.search("begin{lilypond}", "n") ~= 0 then
    require('nvls').make(makeLilypondBook,lilypondBookEfm,"lilypond-book")
  else
    require('nvls').make(makeLualatex,lualatexEfm,"lualatex")
  end
end

function M.lytexCmp()
  M.DefineTexVars()
  require('nvls').make(makeLytex,lualatexEfm,"lualatex")
end

return M
