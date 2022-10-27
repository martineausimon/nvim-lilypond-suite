local g, b, fn    = vim.g, vim.b, vim.fn
local expand      = fn.expand
local lilyMap     = vim.api.nvim_buf_set_keymap
local lilyHi      = vim.api.nvim_set_hl
local lilyCmd     = vim.api.nvim_create_user_command
local lilyWords   = expand('<sfile>:p:h') .. '/../lilywords'

if not g.nvls_options then
  require('nvls').setup()
end

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
  local output      = g.nvls_options.lilypond.options.output
  print('Opening ' .. g.nvls_short .. '.' .. output .. '...')
  require('nvls').viewer(g.nvls_main_name .. '.' .. output)
end, {})

lilyCmd('LilyCmp', function() 
  require('lilypond').DefineLilyVars()
  local output      = g.nvls_options.lilypond.options.output
  fn.execute('write')
  print('Compiling ' .. g.nvls_short .. '.ly...')
  makeprg = "lilypond -f " .. output .. " -o" .. 
    g.nvls_main_name .. ' ' .. g.nvls_main
  errorfm = '%+G%f:%l:%c:, %f:%l:%c: %m,%-G%.%#'
  require('nvls').make(makeprg,errorfm)
end, {})

lilyCmd('Hyphenation', function()
  require('lilypond').DefineLilyVars()
  local lang = g.nvls_options.lilypond.options.hyphenation_language
  if fn.has('python3') == 0 then
    print('[NVLS] python3 is not available')
    do return end
  end
  fn.execute('py3 import pyphen')
  fn.execute('py3 import vim')
  fn.execute('py3 import re')
  fn.execute([[let @"=substitute(@", '\n', '', 'g')]])
  fn.execute('py3 def py_vim_string_replace(str):' ..
  'return str.replace(a, b)')
  fn.execute([[py3 dic = pyphen.Pyphen(lang=']] .. lang .. [[')]])
  fn.execute([[py3 a = vim.eval('@"')]])
  fn.execute([[py3 b = dic.inserted(a, hyphen = ' -- ')]])
  fn.execute([[py3 b = re.sub('  -- ', ' ', b)]])
  fn.execute([[py3 b = re.sub('" -- ', '"', b)]])
  fn.execute('py3do return py_vim_string_replace(line)')
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

local cmp         = g.nvls_options.lilypond.mappings.compile
local view        = g.nvls_options.lilypond.mappings.open_pdf
local switch      = g.nvls_options.lilypond.mappings.switch_buffers
local version     = g.nvls_options.lilypond.mappings.insert_version
local play        = g.nvls_options.lilypond.mappings.player
local hyphenation = g.nvls_options.lilypond.mappings.hyphenation
local nrm = { noremap = true }
lilyMap(0, 'n', cmp,         ":LilyCmp<cr>",     nrm)
lilyMap(0, 'n', view,        ":Viewer<cr>",      nrm)
lilyMap(0, 'n', switch,      "<C-w>w",           nrm)
lilyMap(0, 'i', switch,      "<esc><C-w>w",      nrm)
lilyMap(0, 'n', play,        ":LilyPlayer<cr>",  nrm)
lilyMap(0, 'v', hyphenation, "y:Hyphenation<cr>", nrm)
lilyMap(0, 'n', version,
  [[0O\version<space>]] .. 
  [[<Esc>:read<Space>!lilypond<Space>-v]] ..
  [[<Bar>grep<Space>LilyPond<Bar>cut<Space>-c<Space>14-20<cr>]] ..
  [[kJi"<esc>A"<esc>]],
  {noremap = true, silent = true}
)
