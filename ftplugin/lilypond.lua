local g, b, fn    = vim.g, vim.b, vim.fn
local expand      = fn.expand
local lilyMap     = vim.api.nvim_buf_set_keymap
local lilyHi      = vim.api.nvim_set_hl
local lilyCmd     = vim.api.nvim_create_user_command
local lilyWords   = expand('<sfile>:p:h') .. '/../lilywords'

if not g.nvls_options then
  require('nvls').setup()
end

require('lilypond').DefineLilyVars()
g.lilywords   = lilyWords
vim.cmd[[let $LILYDICTPATH = g:lilywords]]

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

lilyCmd('HyphChLang', function() 
  require('lilypond').DefineLilyVars()
  require('lilypond').quickLangInput()
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

local nvlsMap = g.nvls_options.lilypond.mappings
local cmp         = nvlsMap.compile
local view        = nvlsMap.open_pdf
local switch      = nvlsMap.switch_buffers
local version     = nvlsMap.insert_version
local play        = nvlsMap.player
local hyphenation = nvlsMap.hyphenation
local chlang      = nvlsMap.hyphenation_change_lang
local nrm = { noremap = true }
lilyMap(0, 'n', cmp,         ":LilyCmp<cr>",     nrm)
lilyMap(0, 'n', view,        ":Viewer<cr>",      nrm)
lilyMap(0, 'n', switch,      "<C-w>w",           nrm)
lilyMap(0, 'i', switch,      "<esc><C-w>w",      nrm)
lilyMap(0, 'n', play,        ":LilyPlayer<cr>",  nrm)
lilyMap(0, '',  chlang,      ":HyphChLang<cr>",  nrm)
lilyMap(0, 'n', hyphenation, "i -- <esc>",       nrm)
lilyMap(0, 'v', hyphenation, 
  "y:lua<space>require('lilypond').loadPyphenModule()<cr>" ..
  "gv:py3do return py_vim_string_replace(line)<cr>", nrm)
lilyMap(0, 'n', version,
  [[0O\version<space>]] .. 
  [[<Esc>:read<Space>!lilypond<Space>-v]] ..
  [[<Bar>grep<Space>LilyPond<Bar>cut<Space>-c<Space>14-20<cr>]] ..
  [[kJi"<esc>A"<esc>]],
  {noremap = true, silent = true}
)
