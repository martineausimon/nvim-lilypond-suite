local Config = require('nvls.config')
local Make = require('nvls.make')
local Utils = require('nvls.utils')
local main = Config.fileInfos().main

local M = {}

function M.ToggleLilypondSyntax()
  if vim.g.lytexSyn == 1 then
    vim.g.lytexSyn = 0
    vim.cmd('set syntax=tex')
  else
  M.DetectLilypondSyntax()
  end
end

function M.DetectLilypondSyntax()
  if Utils.has(main, "\\begin{lilypond}") or Utils.has(main, "\\lilypond") then
    vim.b.current_syntax = nil
    vim.cmd('syntax include @lilypond syntax/lilypond.vim')
    vim.cmd([[
      syn match litexCmd "\\lilypond\>\(\s\|\n\)\{}"
      \ nextgroup=litexOpts,litexReg
      \ transparent
      hi def link litexCmd texStatement
    ]])
    vim.cmd([[
      syn match texInputFile "\\lilypondfile\=\(\[.\{-}\]\)\=\s*{.\{-}}"
      \ contains=texStatement,texInputCurlies,texInputFileOpt
    ]])
    vim.cmd([[
      syn region litexOpts
      \ matchgroup=texDelimiter
      \ start="\["
      \ end="\]\(\n\|\s\)\{}"
      \ contained
      \ contains=texComment,@texMathZones,@NoSpell
      \ nextgroup=litexReg
      ]])
    vim.cmd([[
      syntax region litexReg
      \ matchgroup=Delimiter
      \ start="{"
      \ end="}" 
      \ contained
      \ contains=@lilypond,@lilyMatchGroup
    ]])
    vim.cmd([[ 
      syntax region litexReg
      \ start="\\begin{lilypond}" 
      \ end="\\end{lilypond}" 
      \ contains=litexOpts,@lilypond,@lilyMatchGroup
      \ keepend
    ]])
    vim.g.lytexSyn = 1
  end
end

function M.SelectMakePrgType()
  local cmd = "lualatex"
  if (Utils.has(main, "\\begin{lilypond}") or Utils.has(main, "\\lilypond"))
    and not Utils.has(main, "\\usepackage{lyluatex}")
  then cmd = "lilypond-book" end
  Make.async(cmd)
end

return M
