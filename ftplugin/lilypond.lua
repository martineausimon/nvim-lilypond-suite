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

if not g.nvls_options then
  require('nvls').setup()
end

local cmp     = g.nvls_options.lilypond.mappings.compile
local view    = g.nvls_options.lilypond.mappings.open_pdf
local switch  = g.nvls_options.lilypond.mappings.switch_buffers
local version = g.nvls_options.lilypond.mappings.insert_version
local play    = g.nvls_options.lilypond.mappings.player
lilyMap(0, 'n', cmp,    ":LilyCmp<cr>",       {noremap = true})
lilyMap(0, 'n', view,   ":Viewer<cr>",        {noremap = true})
lilyMap(0, 'n', switch, "<C-w>w",             {noremap = true})
lilyMap(0, 'i', switch, "<esc><C-w>w",        {noremap = true})
lilyMap(0, 'n', play,   ":LilyPlayer<cr>",    {noremap = true})
lilyMap(0, 'n', version,
  [[0O\version<space>]] .. 
  [[<Esc>:read<Space>!lilypond<Space>-v]] ..
  [[<Bar>grep<Space>LilyPond<Bar>cut<Space>-c<Space>14-20<cr>]] ..
  [[kJi"<esc>6la"<esc>]],
  {noremap = true, silent = true}
)
local lang = g.nvls_options.lilypond.options.pitches_language
g.nvls_language = lang
