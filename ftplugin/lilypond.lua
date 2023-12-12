local lilyWords   = vim.fn.expand('<sfile>:p:h') .. '/../lilywords'
local Config = require('nvls.config')
local Utils = require('nvls.utils')
local Make = require('nvls.make')
local Player = require('nvls.player')
local opts = require('nvls').get_nvls_options().lilypond
local map, imap, vmap = Utils.map, Utils.imap, Utils.vmap

vim.g.lilywords = lilyWords
vim.cmd[[let $LILYDICTPATH = g:lilywords]]

vim.bo.tabstop    = 2
vim.bo.shiftwidth = 2
vim.o.showmatch   = true
vim.opt_local.iskeyword:append([[-]])
vim.opt_local.iskeyword:append([[\]])
vim.opt_local.complete:append('k')
if vim.api.nvim_buf_get_option(0, 'autoindent') then
  vim.opt_local.indentexpr = 'v:lua.require("nvls.indent").lilypond()'
  vim.opt_local.indentkeys:append('o', 'O', '}', '>>')
end

vim.api.nvim_create_user_command('LilyPlayer', function()
  Player.convert()
end, {})

vim.api.nvim_create_user_command('LilyCmp', function()
  local file = Config.fileInfos()
  vim.fn.execute('write')
  Utils.message(string.format('Compiling %s...', Utils.shellescape(Utils.remove_path(file.main)), false))
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

local cmp         = opts.mappings.compile
local view        = opts.mappings.open_pdf
local switch      = opts.mappings.switch_buffers
local version     = opts.mappings.insert_version
local play        = opts.mappings.player
local hyphenation = opts.mappings.hyphenation
local chlang      = opts.mappings.hyphenation_change_lang
local ins         = opts.mappings.insert_hyphen
local add         = opts.mappings.add_hyphen
local deln        = opts.mappings.del_next_hyphen
local delp        = opts.mappings.del_prev_hyphen

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

map(cmp,    "<cmd>LilyCmp<cr>")
map(view,   "<cmd>Viewer<cr>")
map(switch, "<C-w>w")
imap(switch, "<esc><C-w>w")
map(play,   "<cmd>LilyPlayer<cr>")
map(chlang, "<cmd>HyphChLang<cr>")
map(ins,    "i<space>--<space><esc>")
map(add,    "a<space>--<space><esc>")
map(deln,   "/<space>--<space><cr>:nohl<cr>4x")
map(delp,   "?<space>--<space><cr>:nohl<cr>4x")
vmap(play, ":lua<space>require('nvls.player').quickplayer()<cr>")
vmap(hyphenation, ":lua<space>require('nvls.hyphenate').getHyphType()<cr>")
map(version, write_version)
