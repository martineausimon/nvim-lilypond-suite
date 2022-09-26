local expand      = vim.fn.expand
local lilyMap     = vim.api.nvim_buf_set_keymap
local lilyHi      = vim.api.nvim_set_hl
local lilyCmd     = vim.api.nvim_create_user_command
local lilyAutoCmd = vim.api.nvim_create_autocmd
local lilyWords   = expand('<sfile>:p:h') .. '/../lilywords'
local g           = vim.g
local b           = vim.b

g.lilywords   = lilyWords
vim.cmd[[let $LILYDICTPATH = g:lilywords]]

b.lilyplay     = expand('<sfile>:p:h') .. '/../lua/player.lua'

require('lilypond').DefineLilyVars()

vim.bo.autoindent = true
vim.bo.tabstop    = 2
vim.bo.shiftwidth = 2
vim.o.showmatch   = true
vim.opt_local.iskeyword:append([[-]])
vim.opt_local.iskeyword:append([[\]])
vim.opt_local.complete:append('k')

lilyCmd('LilyPlayer', function() 
  require('lilypond').DefineLilyVars()
  require('lilypond').lilyPlayer() 
end, {})

lilyCmd('Viewer', function() 
  require('lilypond').DefineLilyVars()
  print('Opening ' .. g.nvls_short .. '.pdf...')
  require('nvls').viewer(g.nvls_short .. '.pdf')
end, {})

lilyCmd('LilyCmp',    function() 
  require('lilypond').DefineLilyVars()
  vim.fn.execute('write')
  print('Compiling ' .. g.nvls_short .. '.ly...')
  makeprg = vim.b.nvls_cmd .. " -o" .. 
    g.nvls_main_name .. ' ' .. g.nvls_main
  errorfm = '%+G%f:%l:%c:, %f:%l:%c: %m,%-G%.%#'
  require('nvls').make(makeprg,errorfm)
end, {})

lilyHi(0, 'QuickFixLine', {bold = true})

vim.opt.dictionary:append({
  lilyWords .. '/grobs',
  lilyWords .. '/keywords',
  lilyWords .. '/musicFunctions',
  lilyWords .. '/articulations',
  lilyWords .. '/grobProperties',
  lilyWords .. '/paperVariables',
  lilyWords .. '/headerVariables',
  lilyWords .. '/contextProperties',
  lilyWords .. '/clefs',
  lilyWords .. '/repeatTypes',
  lilyWords .. '/languageNames',
  lilyWords .. '/accidentalsStyles',
  lilyWords .. '/scales',
  lilyWords .. '/musicCommands',
  lilyWords .. '/markupCommands',
  lilyWords .. '/contextsCmd',
  lilyWords .. '/dynamics',
  lilyWords .. '/contexts',
  lilyWords .. '/translators'
})

require('nvls').setup()
