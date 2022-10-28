local g, b, fn = vim.g, vim.b, vim.fn
local expand = fn.expand

local M = {}

function M.lilyPlayer()
  local main_folder = g.nvls_options.lilypond.options.main_folder
  if fn.empty(
    fn.glob(expand(main_folder) 
    .. '/' .. g.nvls_short .. '.midi')) == 0 then
    print('Converting ' .. g.nvls_short .. '.midi to mp3...') 
    local convert = 'rm -rf ' .. g.lilyAudioFile .. ' && ' ..
      'fluidsynth -T raw -F - ' .. g.lilyMidiFile .. 
      ' -s | ffmpeg -f s32le -i - ' .. g.lilyAudioFile
    local fluidsynthEfm = " " 
    require('nvls').make(convert,fluidsynthEfm,"fluidsynth")
  elseif fn.empty(
    fn.glob(expand(main_folder) 
      .. '/' .. g.nvls_short .. '.mp3')) > 0 then
    print("[LilyPlayer] No mp3 file in working directory")
    do return end
  else
    require('lilypond').player()
  end
end

function M.DefineLilyVars()
  g.nvls_main = expand('%:p:S')
  local main_file = g.nvls_options.lilypond.options.main_file
  local main_folder = g.nvls_options.lilypond.options.main_folder

  if fn.empty(fn.glob(main_folder .. '/.lilyrc')) == 0 then
    dofile(expand(main_folder) .. '/.lilyrc')
    g.nvls_main = "'" .. expand(main_folder) .. "/" .. 
    main_file .. "'"

  elseif fn.empty(fn.glob(expand(main_folder) .. '/' .. 
    main_file)) == 0 then
      g.nvls_main = "'" .. expand(main_folder) .. "/" .. 
      main_file .. "'"
  end

  local name,out = g.nvls_main:gsub("%.(ly')", "'")
  if out == 0 then
    name,out = g.nvls_main:gsub("%.(ily')", "'")
  end
  g.nvls_main_name = name
  g.nvls_short = g.nvls_main_name:match('/([^/]+)$'):gsub("'", "")
  g.lilyMidiFile = expand(
    "'" .. g.nvls_main_name:gsub("'", "") .. ".midi'")
  g.lilyAudioFile = expand(
    "'" .. g.nvls_main_name:gsub("'", "") .. ".mp3'")
end

function M.player()
  local lilyPopup = require("nui.popup")
  local plopts = g.nvls_options.player.options
  
  local lilyPlayer = lilyPopup({
    enter = true,
    focusable = true,
    border = {
      text = { top = "[" .. g.nvls_short .. ".mp3]" },
      style = plopts.border_style,
    },
      position = {
      row = plopts.row,
      col = plopts.col,
    },
    size = {
      width = plopts.width,
      height = plopts.height,
    },
    buf_options = {
      modifiable = false,
      readonly = true,
    },
    win_options = {
      winhighlight = plopts.winhighlight,
    },
  })
  
  lilyPlayer:mount()
  
  vim.api.nvim_buf_call(lilyPlayer.bufnr, function() 
    fn.execute("term mpv --msg-level=cplayer=no,ffmpeg=no " ..
      "--loop --config-dir=/tmp/ " .. g.lilyAudioFile)
    fn.execute('stopinsert')
  end)
  
  local nrm = { noremap = true }
  local opt = g.nvls_options.player.mappings
  local lyopt = g.nvls_options.lilypond.mappings
  
  function map(key,cmd)
    lilyPlayer:map('n', key, cmd, nrm)
  end
  
  map(opt.quit,             function() lilyPlayer:unmount() end)
  map(lyopt.switch_buffers, "<cmd>stopinsert<cr><C-w>w")
  map(opt.backward,         "i<Left><cmd>stopinsert<cr>")
  map(opt.forward,          "i<Right><cmd>stopinsert<cr>")
  map(opt.small_forward,    "i<S-Right><cmd>stopinsert<cr>")
  map(opt.small_backward,   "i<S-Left><cmd>stopinsert<cr>")
  map(opt.play_pause,       "ip<cmd>stopinsert<cr>")
  map(opt.halve_speed,      "i{<cmd>stopinsert<cr>")
  map(opt.double_speed,     "i}<cmd>stopinsert<cr>")
  map(opt.decrease_speed,   "i[<cmd>stopinsert<cr>")
  map(opt.increase_speed,   "i]<cmd>stopinsert<cr>")
  map(opt.loop,             "il<cmd>stopinsert<cr>")
  map(':',                  "")
  map('i',                  "")

end

function M.loadPyphenModule()
  require('lilypond').DefineLilyVars()
  if g.nvls_hyphlang then
    lang = g.nvls_hyphlang
  else
    lang = g.nvls_options.lilypond.options.hyphenation_language
  end
  if fn.has('python3') == 0 then
    print('[NVLS] python3 is not available')
    do return end
  end
  fn.execute('py3 import pyphen')
  fn.execute('py3 import vim')
  fn.execute('py3 import re')
  fn.execute([[let @"=substitute(@", '\n', '', 'g')]])
  fn.execute('py3 def py_vim_string_replace(str):' ..
  'return str.replace(a, b, 1)')
  fn.execute([[py3 dic = pyphen.Pyphen(lang=']] .. lang .. [[')]])
  fn.execute([[py3 a = vim.eval('@"')]])
  fn.execute([[py3 b = dic.inserted(a, hyphen = ' -- ')]])
  fn.execute([[py3 b = re.sub('  -- ', ' ', b)]])
  fn.execute([[py3 b = re.sub('" -- ', '"', b)]])
end

function M.quickLangInput()
  local Input = require("nui.input")
  local plopts = g.nvls_options.player.options

  if g.nvls_hyphlang then
    value = g.nvls_hyphlang
  else
    value = g.nvls_options.lilypond.options.hyphenation_language
  end

  local input = Input({
    position = "50%",
    size = {
      width = 15,
    },
    border = {
      style = plopts.border_style,
      text = {
        top = "[Language?]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = plopts.winhighlight,
    },
  }, {
    prompt = "> ",
    default_value = value,
    on_submit = function(value)
      g.nvls_hyphlang = value
    end,
  })

  input:mount()

  input:map("n", "<Esc>", function()
    input:unmount()
  end, { noremap = true })
end

return M
