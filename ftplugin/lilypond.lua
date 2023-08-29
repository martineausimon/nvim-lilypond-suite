local lilyWords   = vim.fn.expand('<sfile>:p:h') .. '/../lilywords'
local Config = require('nvls.config')
local Utils = require('nvls.utils')
local Viewer = require('nvls.viewer')
local Make = require('nvls.make')
local Player = require('nvls.player')
local nvls_options = require('nvls').get_nvls_options()

local ly = Config.fileInfos("lilypond")

vim.g.lilywords   = lilyWords
vim.cmd[[let $LILYDICTPATH = g:lilywords]]

vim.bo.autoindent = true
vim.bo.tabstop    = 2
vim.bo.shiftwidth = 2
vim.o.showmatch   = true
vim.opt_local.iskeyword:append([[-]])
vim.opt_local.iskeyword:append([[\]])
vim.opt_local.complete:append('k')

vim.api.nvim_create_user_command('LilyPlayer', function()
  Player.convert()
end, {})

vim.api.nvim_create_user_command('Viewer', function()
  ly = Config.fileInfos("lilypond")
  local output = nvls_options.lilypond.options.output
  Viewer.open(Utils.change_extension(ly.main, output), string.format('%s.%s', ly.name, output))
end, {})

vim.api.nvim_create_user_command('LilyCmp', function()
  ly = Config.fileInfos("lilypond")
  vim.fn.execute('write')
  Utils.message(string.format('Compiling %s.ly...', ly.name))
  Make.async("lilypond")
end, {})

vim.api.nvim_create_user_command('HyphChLang', function()
  require('nvls.hyphenate').quickLangInput()
end, {})

vim.api.nvim_set_hl(0, 'QuickFixLine', {bold = true})

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

local nvlsMap     = nvls_options.lilypond.mappings
local cmp         = nvlsMap.compile
local view        = nvlsMap.open_pdf
local switch      = nvlsMap.switch_buffers
local version     = nvlsMap.insert_version
local play        = nvlsMap.player
local hyphenation = nvlsMap.hyphenation
local chlang      = nvlsMap.hyphenation_change_lang
local ins         = nvlsMap.insert_hyphen
local add         = nvlsMap.add_hyphen
local deln        = nvlsMap.del_next_hyphen
local delp        = nvlsMap.del_prev_hyphen

local write_version = function()
  local v = io.popen('lilypond -v'):read("*a")
  if not v then
    Utils.message("LilyPond version not found.", "ERROR")
    return
  end
  v = string.match(v, "LilyPond%s+(%d+.%d+.%d+)")
  v = string.format('\\version "%s"', v)
  local c = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_lines(0, c[1] - 1, c[1] - 1, true, { v })
end

local map = function(key, cmd, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, key, cmd, { noremap = true, silent = true, buffer = true })
end

map(cmp,    "<cmd>LilyCmp<cr>")
map(view,   "<cmd>Viewer<cr>")
map(switch, "<C-w>w")
map(switch, "<esc><C-w>w", 'i')
map(play,   "<cmd>LilyPlayer<cr>")
map(chlang, "<cmd>HyphChLang<cr>")
map(ins,    "i<space>--<space><esc>")
map(add,    "a<space>--<space><esc>")
map(deln,   "/<space>--<space><cr>:nohl<cr>4x")
map(delp,   "?<space>--<space><cr>:nohl<cr>4x")
map(play, ":lua<space>require('nvls.player').quickplayer()<cr>", 'v')
map(hyphenation, ":lua<space>require('nvls.hyphenate').getHyphType()<cr>", 'v')
map(version, write_version)
