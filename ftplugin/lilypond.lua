local fn          = vim.fn
local expand      = fn.expand
local lilyMap     = vim.api.nvim_buf_set_keymap
local lilyHi      = vim.api.nvim_set_hl
local lilyCmd     = vim.api.nvim_create_user_command
local lilyWords   = expand('<sfile>:p:h') .. '/../lilywords'

if not nvls_options then
  require('nvls').setup()
end

require('nvls.lilypond').DefineLilyVars()
vim.g.lilywords   = lilyWords
vim.cmd[[let $LILYDICTPATH = g:lilywords]]

vim.bo.autoindent = true
vim.bo.tabstop    = 2
vim.bo.shiftwidth = 2
vim.o.showmatch   = true
vim.opt_local.iskeyword:append([[-]])
vim.opt_local.iskeyword:append([[\]])
vim.opt_local.complete:append('k')

lilyCmd('LilyPlayer', function() 
  require('nvls.lilypond').DefineLilyVars()
  require('nvls.lilypond').lilyPlayer() 
end, {})

lilyCmd('Viewer', function() 
  require('nvls.lilypond').DefineLilyVars()
  local output = nvls_options.lilypond.options.output
  print('Opening ' .. nvls_file_name .. '.' .. output .. '...')
  require('nvls').viewer(nvls_main_name .. '.' .. output)
end, {})

lilyCmd('LilyCmp', function() 
  require('nvls.lilypond').DefineLilyVars()
  local output = nvls_options.lilypond.options.output

  local include_dir = nvls_options.lilypond.options.include_dir
  if type(include_dir) == "table" then
    include_dir = table.concat(include_dir, " -I ")
  end

  fn.execute('write')
  print('Compiling ' .. nvls_file_name .. '.ly...')
  makeprg = "lilypond " .. 
    "-I " .. include_dir .. 
    " -f " .. output .. 
    " -o '" .. nvls_main_name .. "' '" .. nvls_main .. "'"
  errorfm = "%f:%l:%c:%m,%f:%l:%m%[^;],%f:%l:%m,%-G%.%#"
  require('nvls').make(makeprg,errorfm,"lilypond")
end, {})

lilyCmd('HyphChLang', function() 
  require('nvls.lilypond').DefineLilyVars()
  require('nvls.lilypond').quickLangInput()
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
local dels        = nvlsMap.del_selected_hyphen
local nrm         = { noremap = true }
lilyMap(0, 'n', cmp,    ":LilyCmp<cr>",                      nrm)
lilyMap(0, 'n', view,   ":Viewer<cr>",                       nrm)
lilyMap(0, 'n', switch, "<C-w>w",                            nrm)
lilyMap(0, 'i', switch, "<esc><C-w>w",                       nrm)
lilyMap(0, 'n', play,   ":LilyPlayer<cr>",                   nrm)
lilyMap(0, 'n', chlang, ":HyphChLang<cr>",                   nrm)
lilyMap(0, 'n', ins,    "i<space>--<space><esc>",            nrm)
lilyMap(0, 'n', add,    "a<space>--<space><esc>",            nrm)
lilyMap(0, 'n', deln,   "/<space>--<space><cr>:nohl<cr>4x",  nrm)
lilyMap(0, 'n', delp,   "/<space>--<space><cr>N:nohl<cr>4x", nrm)

lilyMap(0, 'v', play, 
  ":lua<space>require('nvls.lilypond').quickplayer()<cr>", 
  { noremap = true, silent = true })

lilyMap(0, 'v', hyphenation, 
  ":lua<space>require('nvls.lilypond').getHyphType()<cr>", 
  { noremap = true, silent = true })

lilyMap(0, 'n', version,
  [[0O\version<space>]] .. 
  [[<Esc>:read<Space>!lilypond<Space>-v]] ..
  [[<Bar>grep<Space>LilyPond<Bar>awk<Space>{'print<Space>$3'}<cr>]] ..
  [[kJi"<esc>A"<esc>]],
  {noremap = true, silent = true}
)

vim.cmd([[vmap <silent> ]] .. dels .. 
  [[ <esc>:%s/\%V<space>--<space>//g<cr>:nohl<cr>`<]])
