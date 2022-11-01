local fn = vim.fn
local expand = fn.expand

local M = {}

function M.lilyPlayer()
  local main_folder = nvls_options.lilypond.options.main_folder
  if fn.empty(
    fn.glob(expand(main_folder) 
    .. '/' .. nvls_short .. '.midi')) == 0 then
    print('Converting ' .. nvls_short .. '.midi to mp3...') 
    local convert = 'rm -rf ' .. lilyAudioFile .. ' && ' ..
      'fluidsynth -T raw -F - ' .. lilyMidiFile .. 
      ' -s | ffmpeg -f s32le -i - ' .. lilyAudioFile
    local efm = " " 
    require('nvls').make(convert,efm,"fluidsynth")
  elseif fn.empty(
    fn.glob(expand(main_folder) 
      .. '/' .. nvls_short .. '.mp3')) > 0 then
    print("[LilyPlayer] No mp3 file in working directory")
    do return end
  else
    require('nvls.lilypond').player()
  end
end

function M.DefineLilyVars()
  nvls_main = expand('%:p:S')
  local main_file = nvls_options.lilypond.options.main_file
  local main_folder = nvls_options.lilypond.options.main_folder

  if fn.empty(fn.glob(main_folder .. '/.lilyrc')) == 0 then
    dofile(expand(main_folder) .. '/.lilyrc')
    nvls_main = "'" .. expand(main_folder) .. "/" .. 
    main_file .. "'"

  elseif fn.empty(fn.glob(expand(main_folder) .. '/' .. 
    main_file)) == 0 then
      nvls_main = "'" .. expand(main_folder) .. "/" .. 
      main_file .. "'"
  end

  local name,out = nvls_main:gsub("%.(ly')", "'")
  if out == 0 then
    name,out = nvls_main:gsub("%.(ily')", "'")
  end
  nvls_main_name = name
  nvls_short = nvls_main_name:match('/([^/]+)$'):gsub("'", "")
  lilyMidiFile = expand(
    "'" .. nvls_main_name:gsub("'", "") .. ".midi'")
  lilyAudioFile = expand(
    "'" .. nvls_main_name:gsub("'", "") .. ".mp3'")
end

function M.player(file)
  local lilyPopup = require("nui.popup")
  local plopts = nvls_options.player.options
  
  local lilyPlayer = lilyPopup({
    enter = true,
    focusable = true,
    border = {
      text = { top = "[" .. nvls_short .. ".mp3]" },
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
      "--loop --config-dir=/tmp/ " .. file)
    fn.execute('stopinsert')
  end)
  
  local nrm = { noremap = true }
  local opt = nvls_options.player.mappings
  local lyopt = nvls_options.lilypond.mappings
  
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

function M.quickLangInput()
  local Input = require("nui.input")
  local plopts = nvls_options.player.options

  if nvls_hyphlang then
    value = nvls_hyphlang
  else
    value = nvls_options.lilypond.options.hyphenation_language
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
      nvls_hyphlang = value
    end,
  })

  input:mount()

  input:map("n", "<Esc>", function()
    input:unmount()
  end, { noremap = true })
end

function M.getVisualSelection()
  local getLines = vim.api.nvim_buf_get_lines
  local s_start  = vim.fn.getpos("'<")
  local s_end    = vim.fn.getpos("'>")
  local n_lines  = math.abs(s_end[2] - s_start[2]) + 1
  local lines    = getLines(0, s_start[2] - 1, s_end[2], false)
  lines[1]       = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

function M.getHyphType()
  require('nvls.lilypond').DefineLilyVars()
  if nvls_hyphlang then lang = nvls_hyphlang
  else lang = nvls_options.lilypond.options.hyphenation_language
  end
  if lang == "en_DEFAULT" then require('nvls.lilypond').hyphenator()
  else require('nvls.lilypond').pyphen()
  end
end

function M.hyphenator()
  local input = require('nvls.lilypond').getVisualSelection()
  require('nvls.hyphs')
  for i, j in pairs(hyphs) do 
    input = input:gsub("%f[%w_]" .. i .. "s?%f[^%w_]", j)
  end
  fn.execute("normal gvc" .. input)
end
  
function M.pyphen()
  if fn.has('python3') == 0 then
    print('[NVLS] python3 is not available')
    do return end
  end
  local input = require('nvls.lilypond').getVisualSelection()
  input = input:gsub("[\n\r]", " ")
  fn.execute('py3 import pyphen')
  fn.execute('py3 import vim')
  fn.execute('py3 import re')
  fn.execute([[py3 def py_vim_string_replace(str):]] ..
  [[return str.replace("]] .. input .. [[", b, 1)]])
  fn.execute([[py3 dic = pyphen.Pyphen(lang=']] .. lang .. [[')]])
  fn.execute([[py3 a = "]] .. input .. [["]])
  fn.execute([[py3 b = dic.inserted(a, hyphen = ' -- ')]])
  fn.execute([[py3 b = re.sub('  -- ', ' ', b)]])
  fn.execute([[py3 b = re.sub('" -- ', '"', b)]])
  fn.execute("'<,'>py3do return py_vim_string_replace(line)")
end

-- WORK IN PROGRES...
--function M.tempLy()
--  local input = require('nvls.lilypond').getVisualSelection()
--  local code = "\\score { \\relative c' { " .. input .. " } \\midi {} }"
--  tmpOutDir = expand('%:p:h') .. '/tmpOutDir/'
--  os.execute('rm -rf ' .. tmpOutDir)
--  os.execute('mkdir -p ' .. tmpOutDir)
--  local tmpfile = io.open(tmpOutDir .. 'tmp.ly', 'w')
--  tmpfile:write(code)
--  tmpfile:close()
--  os.execute('lilypond -s -o ' .. tmpOutDir .. ' ' ..tmpOutDir .. 'tmp.ly')
--  local convert = 'fluidsynth -T raw -F - ' .. tmpOutDir .. 'tmp.midi' ..
--      ' -s | ffmpeg -f s32le -i - ' .. tmpOutDir .. 'tmp.mp3'
--  local efm = " "
--  require('nvls').make(convert,efm,"tmpplayer")
--end

return M
