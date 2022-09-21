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
  require('nvls').viewer()
end, {})

lilyCmd('LilyCmp',    function() 
  require('lilypond').DefineLilyVars()
  vim.fn.execute('write')
  print('Compiling ' .. g.nvls_short .. '.ly...')
  require('nvls').make()
end, {})

lilyMap(0, 'n', '<F3>',      ":LilyPlayer<cr>",    {noremap = true})
lilyMap(0, 'n', '<F4>',
  [[0O\version<space>]] .. 
  [[<Esc>:read<Space>!lilypond<Space>-v]] ..
  [[<Bar>grep<Space>LilyPond<Bar>cut<Space>-c<Space>14-19<cr>]] ..
  [[kJi"<esc>6la"<esc>]],
  {noremap = true, silent = true}
)

lilyMap(0, 'n', '<F5>',      ":LilyCmp<cr>",       {noremap = true})
lilyMap(0, 'i', '<F5>',      "<esc>:LilyCmp<cr>a", {noremap = true})
lilyMap(0, 'n', '<F6>',      ":Viewer<cr>",        {noremap = true})
lilyMap(0, 'n', '<A-Space>', "<C-w>w",             {noremap = true})
lilyMap(0, 'i', '<A-Space>', "<esc><C-w>w",        {noremap = true})

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
