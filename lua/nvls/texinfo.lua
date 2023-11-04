local Config = require('nvls.config')
local Make = require('nvls.make')
local Utils = require('nvls.utils')
local main = Config.fileInfos().main

local M = {}

function M.ToggleLilypondSyntax()
  if vim.g.lytexiSyn == 1 then
    vim.g.lytexiSyn = 0
    vim.cmd('set syntax=texinfo')
  else
  M.DetectLilypondSyntax()
  end
end

function M.DetectLilypondSyntax()
  --TODO
  if Utils.has(main, "@lilypond") then
    vim.b.current_syntax = nil
    vim.cmd('syntax include @lilypond syntax/lilypond.vim')
    vim.cmd([[ 
      syntax region texinfoControlSequence
      \ start="@lilypond\s\{}\(\[.\{-}\]\)\{}\n" 
      \ end="@end\s\+lilypond"
      \ contains=litexiOpts,@lilypond,@lilyMatchGroup
      \ keepend
    ]])
    vim.cmd([[
      syn region litexiOpts
      \ matchgroup=Delimiter
      \ start="\["
      \ end="\]\(\n\|\s\)\{}"
      \ contained
      \ contains=@NoSpell
      ]])
    vim.g.lytexiSyn = 1
  end
end

function M.SelectMakePrgType()
  local cmd = "texinfo"
  if Utils.has(main, "@lilypond") then
    cmd = "lilypond-book"
  end
  Make.async(cmd)
end

return M

