local Config = require('nvls.config')
local Make = require('nvls.make')
local tex = Config.fileInfos("tex").main

local M = {}

function M.ToggleLilypondSyntax()
  if vim.g.lytexSyn == 1 then
    vim.g.lytexSyn = 0
    vim.cmd('set syntax=tex')
  else
  M.DetectLilypondSyntax()
  end
end

local function has(file, string)
  local content = io.open(file, "r"):read("*all")
  return content:find(string, 1, true) ~= nil
end

function M.DetectLilypondSyntax()
  if has(tex, "\\begin{lilypond}") or has(tex, "\\lilypond") then
    vim.b.current_syntax = nil
    vim.cmd('syntax include @lilypond syntax/lilypond.vim')
    vim.cmd([[ 
      syntax region litex 
      \ start="\\begin{lilypond}" 
      \ end="\\end{lilypond}" 
      \ keepend
      \ contains=@lilypond
    ]])
    vim.cmd([[
      syntax region litex 
      \ matchgroup=texStatement
      \ start="\\lilypond\s\{}\(\[.\+\]\)\{}{"
      \ end="}" 
      \ contains=@lilypond
    ]])
    vim.g.lytexSyn = 1
  end
end

function M.SelectMakePrgType()
  local cmd = "lualatex"
  if (has(tex, "\\begin{lilypond}") or has(tex, "\\lilypond"))
    and not has(tex, "\\usepackage{lyluatex}")
  then cmd = "lilypond-book" end
  Make.async(cmd)
end

return M
