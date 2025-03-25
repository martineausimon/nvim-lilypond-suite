local Utils = require('nvls.utils')
local Job = require('nvls.job')
local Player = require('nvls.player')
local opts = require('nvls').get_nvls_options().lilypond
local map, imap, vmap = Utils.map, Utils.imap, Utils.vmap

local lilyWords = vim.fs.joinpath(vim.fn.expand('<sfile>:p:h'), '..', 'lilywords')
vim.g.lilywords = lilyWords
vim.cmd[[let $LILYDICTPATH = g:lilywords]]
local lilyWordFiles = vim.fn.glob(lilyWords .. '/*', false, true)
for _, file in ipairs(lilyWordFiles) do
  vim.opt.dictionary:append(file)
end

vim.bo.tabstop  = 2
vim.bo.shiftwidth = 2
vim.o.showmatch = true
vim.opt_local.iskeyword:append({ "-", "\\" })
vim.opt_local.complete:append('k')
if vim.api.nvim_buf_get_option(0, 'autoindent') then
  vim.opt_local.indentexpr = 'v:lua.require("nvls.indent").lilypond()'
  vim.opt_local.indentkeys:append({ 'o', 'O', '}', '>>' })
end

vim.api.nvim_create_user_command('LilyPlayer', function()
  Player.convert()
end, {})

vim.api.nvim_create_user_command('LilyCmp', function()
  vim.fn.execute('write')
  local file = require('nvls').get_file_infos()

  local args = {
    "-f", file.output_fm,
    "-o", vim.fs.joinpath(file.folder, file.name),
    file.main
  }

  local include_args = Utils.format_include_dirs(opts.options.include_dir)
  for _, arg in ipairs(include_args) do
    table.insert(args, 1, "-I")
    table.insert(args, 2, arg)
  end

  if opts.options.backend then
    table.insert(args, 1, "-dbackend=" .. opts.options.backend)
  end

  Job:add('lilypond', args)
end, {})

vim.api.nvim_create_user_command('HyphChLang', function()
  require('nvls.hyphenate').quickLangInput()
end, {})

--vim.api.nvim_set_hl(0, 'QuickFixLine', {bold = true})

local function write_version()
  local v = io.popen('lilypond -v'):read("*a")
  v = v and v:match("LilyPond%s+(%d+%.%d+%.%d+)") or nil
  if v then
    v = string.format("\\version %q", v)
    local c = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_buf_set_lines(0, c[1] - 1, c[1] - 1, true, { v })
  else
    Utils.message("LilyPond version not found.", "ERROR")
  end
end

local key = opts.mappings
map(key.compile, "<cmd>LilyCmp<cr>")
map(key.open_pdf, "<cmd>Viewer<cr>")
map(key.switch_buffers, "<C-w>w")
imap(key.switch_buffers, "<esc><C-w>w")
map(key.player, "<cmd>LilyPlayer<cr>")
map(key.hyphenation_change_lang, "<cmd>HyphChLang<cr>")
map(key.insert_hyphen, "i<space>--<space><esc>")
map(key.add_hyphen, "a<space>--<space><esc>")
map(key.del_next_hyphen, "/<space>--<space><cr>:nohl<cr>4x")
map(key.del_prev_hyphen, "?<space>--<space><cr>:nohl<cr>4x")
vmap(key.player, ":lua<space>require('nvls.player').quickplayer()<cr>")
vmap(key.hyphenation, ":lua<space>require('nvls.hyphenate').getHyphType()<cr>")
map(key.insert_version, write_version)
