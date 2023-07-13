local fn = vim.fn
local expand = fn.expand

local M = {}

function M.lilyPlayer()
  local main_folder = nvls_options.lilypond.options.main_folder
  local uname = io.popen("uname")
  local kernel = uname:read("*a")
  uname:close()
  if kernel ~= "Linux\n" and kernel ~= "Darwin\n" then
    print("[NVLS] Function not supported on your system")
    do return end
  end

  local function getLastMod(file)
    local var
    if io.open(fn.glob(file), "r") == nil then
      return 0
    else
      if kernel == "Darwin\n" then
        var = io.popen("stat -f %m " .. fn.glob(file))
      else
        var = io.popen("stat -c %Y " .. fn.glob(file))
      end
      var = var:read()
      var = tonumber(var)
      return var
    end
  end

  if io.open(fn.glob(lilyMidiFile), "r") then

    local midi_last = getLastMod(lilyMidiFile)
    local mp3_last = getLastMod(lilyAudioFile)

    if (mp3_last > midi_last) then
      require('nvls.lilypond').player(lilyAudioFile, nvls_file_name .. ".mp3")

    else
      print('[NVLS] Converting ' .. nvls_file_name .. '.midi to mp3...')
      local convert = 'rm -rf "' .. lilyAudioFile .. '" && ' ..
        'fluidsynth -T raw -F - "' .. lilyMidiFile ..
        '" -s | ffmpeg -f s32le -i - "' .. lilyAudioFile .. '"'
      require('nvls').make(convert," ","fluidsynth")
    end

  elseif io.open(fn.glob(main_folder .. '/' ..
      nvls_short .. '.mp3', "r")) then
    require('nvls.lilypond').player(lilyAudioFile, nvls_file_name .. ".mp3")

  else
    print("[NVLS] No mp3 file in working directory")
    do return end
  end
end

function M.DefineLilyVars()
  nvls_main = require('nvls').shellescape(expand('%:p'))
  local main_file = nvls_options.lilypond.options.main_file
  local main_folder = nvls_options.lilypond.options.main_folder

  if io.open(fn.glob(main_folder .. '/.lilyrc')) then
    dofile(expand(main_folder) .. '/.lilyrc')
    nvls_main = require('nvls').shellescape(expand(main_folder) .. "/" .. main_file)
    if not io.open(fn.glob(nvls_main)) then
      nvls_main = require('nvls').shellescape(expand('%:p'))
    end

  elseif io.open(fn.glob(expand(main_folder) .. '/' ..
    main_file)) then
      nvls_main = require('nvls').shellescape(expand(main_folder) .. "/" .. main_file)
  end

  local name,out = nvls_main:gsub("%.(ly)", "")
  if out == 0 then
    name,out = nvls_main:gsub("%.(ily)", "")
  end
  nvls_main_name = name
  nvls_short = nvls_main_name:match('/([^/]+)$')
  nvls_file_name = nvls_short:gsub([[\]], "")
  lilyMidiFile = require('nvls').shellescape(expand(nvls_main_name .. ".midi"))
  lilyAudioFile = require('nvls').shellescape(expand(nvls_main_name .. ".mp3"))
end

function M.player(file,name)
  local lilyPopup = require("nui.popup")
  local plopts = nvls_options.player.options
  local event = require("nui.utils.autocmd").event
  local lilyPlayer = lilyPopup({
    enter = true,
    focusable = true,
    border = {
      text = { top = "[" .. name .. "]" },
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
    fn.execute("term mpv " .. table.concat(plopts.mpv_flags, " ") .. " " .. file)
    fn.execute('stopinsert')
  end)

  local nrm = { noremap = true }
  local opt = nvls_options.player.mappings
  local lyopt = nvls_options.lilypond.mappings

  local function map(key,cmd)
    lilyPlayer:map('n', key, cmd, nrm)
  end

  map(opt.quit, function() lilyPlayer:unmount() end)
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

  lilyPlayer:on({ event.TermClose }, function()
    vim.schedule(function()
      lilyPlayer:unmount()
    end)
  end, { once = true })

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

function M.inputString(s_start, s_end)
  local getLines = vim.api.nvim_buf_get_lines
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

  local input = require('nvls.lilypond').inputString(fn.getpos("'<"), fn.getpos("'>"))
  if lang == "en_DEFAULT" then require('nvls.lilypond').hyphenator(input)
  else require('nvls.lilypond').pyphen(input)
  end
end

function M.hyphenator(input)
  require('nvls.hyphs')
  for i, j in pairs(hyphs) do
    input = input:gsub("%f[%w_]" .. i .. "s?%f[^%w_]", j)
  end
  fn.execute("set paste")
  fn.execute("normal gvc" .. input)
  fn.execute("normal g`<")
  fn.execute("set nopaste")
end

function M.pyphen(input)
  if fn.has('python3') == 0 then
    print('[NVLS] python3 is not available')
    do return end
  end
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

function M.quickplayerInputType(sel)
  local from_top = require('nvls.lilypond').inputString({0, 1, 1, 0}, fn.getpos("'<"))

  if  string.find(sel, "%pfixed%s+%a*%p*%s*%{") or
      string.find(sel, "%prelative%s+%a*%p*%s*%{") or 
      string.find(sel, "%pchords.*%{") then
    return ''

  elseif string.find(from_top, "%prelative%s+%a*%p*%s*%{") then
    from_relative = from_top:gsub(".*%prelative%s+%a*%p*%s*%{", "")

    if string.find(from_relative, "%pfixed%s+%a*%p*%s*%{") then
      from_fixed = from_relative:gsub(".*pfixed%s+%a*%p*%s*%{", "")
      if string.find(from_fixed, "%pchords%s+%{") then
        return "\\chords"
      else
        local input_type = "\\fixed"
        local ref_pitch = string.match(from_relative, ".*%pfixed(%s+%a%p*)")
        return input_type .. ref_pitch
      end
    elseif string.find(from_relative, "%pchords%s+%{") then
        return "\\chords"
    else
      local input_type = "\\relative"
      local ref_pitch = string.match(from_top, ".*%prelative(%s+%a%p*)")
      return input_type .. ref_pitch
    end

  elseif string.find(from_top, "%pfixed%s+%a*%p*%s*%{") then
    from_fixed = from_top:gsub(".*%pfixed%s+%a*%p*%s*%{", "")

    if string.find(from_fixed, "%prelative%s+%a*%p*%s*%{") then
      from_relative = from_fixed:gsub(".*prelative%s+%a*%p*%s*%{", "")
      if string.find(from_relative, "%pchords%s+%{") then
        return "\\chords"
      else
        local input_type = "\\relative"
        local ref_pitch = string.match(from_fixed, ".*%prelative(%s+%a%p*)")
        return input_type .. ref_pitch
      end
    elseif string.find(from_fixed, "%pchords%s+%{") then
        return "\\chords"
    else
      local input_type = "\\fixed"
      local ref_pitch = string.match(from_top, ".*%pfixed(%s+%a%p*)")
      return input_type .. ref_pitch
    end

  elseif string.find(from_top, "%pchords%s+%{") then
    from_chords = from_top:gsub(".*%pchords%s+%{", "")

    if string.find(from_chords, "%prelative%s+%a*%p*%s*%{") then
      from_relative = from_chords:gsub(".*prelative%s+%a*%p*%s*%{", "")
      if string.find(from_relative, "%pfixed%s+%a*%p*%s*%{") then
        local input_type = "\\fixed"
        local ref_pitch = string.match(from_chords, ".*%pfixed(%s+%a%p*)")
        return input_type .. ref_pitch
      else
        local input_type = "\\relative"
        local ref_pitch = string.match(from_chords, ".*%prelative(%s+%a%p*)")
        return input_type .. ref_pitch
      end
    elseif string.find(from_chords, "%pfixed%s+%a*%p*%s*%{") then
      from_fixed = from_chords:gsub(".*pfixed%s+%a*%p*%s*%{", "")
      if string.find(from_fixed, "%prelative%s+%a*%p*%s*%{") then
        local input_type = "\\relative"
        local ref_pitch = string.match(from_chords, ".*%prelative(%s+%a%p*)")
        return input_type .. ref_pitch
      else
        local input_type = "\\fixed"
        local ref_pitch = string.match(from_chords, ".*%pfixed(%s+%a%p*)")
        return input_type .. ref_pitch
      end
    else
        return "\\chords"
    end
  else
    return ''
  end
end

function M.quickplayerGetTempo(sel)
  local from_top = require('nvls.lilypond').inputString({0, 1, 1, 0}, fn.getpos("'<"))

  if string.find(sel, "%ptempo%s") then return '' end

  if not string.find(from_top, "%ptempo%s") then 
    return ''
  else
    local tempo = string.match(from_top, ".*%ptempo%s+(%d+%s*%=%s*%d+)") or 
                  string.match(from_top, [[.*%ptempo%s+(%"%a*%"%s+%d+%s*%=%s*%d+)]]) or 
                  string.match(from_top, [[.*%ptempo%s+(%"%a+%")]]) or 
                  "4=60"
    return "\\tempo " .. tempo
  end

end

function M.quickplayerCheckErr(string)
  local function countChar(str,char)
    local _,n = str:gsub(char,"")
    return n
  end

  local op_curl_br  = countChar(string,[[{]])
  local cl_curl_br  = countChar(string,[[}]])
  local op_angle_br = countChar(string,[[<]])
  local cl_angle_br = countChar(string,[[>]])

  if op_curl_br ~= cl_curl_br then
    print('[NVLS] Curly brackets not matching in visual selection')
    do return end
  elseif op_angle_br ~= cl_angle_br then
    print('[NVLS] Angle brackets not matching in visual selection')
    do return end
  elseif string.find(string, "%pscore%s") then
    print("[NVLS] Can't compile with \\score in visual selection")
    do return end
  else
    return "OK"
  end
end

function M.quickplayer()
  local sel = require('nvls.lilypond').inputString(fn.getpos("'<"), fn.getpos("'>"))

  if require('nvls.lilypond').quickplayerCheckErr(sel) ~= "OK" then
    do return end
  end

  local input_type = require('nvls.lilypond').quickplayerInputType(sel)

  local tempo = require('nvls.lilypond').quickplayerGetTempo(sel)
  local code = "\\score { " .. input_type .. " { " .. sel .. " } \\midi { " .. tempo .. " } }"

  print("[NVLS] Converting to mp3...")
  tmpOutDir = "/tmp/nvls"
  os.execute('rm -rf ' .. tmpOutDir)
  os.execute('mkdir -p ' .. tmpOutDir)
  local tmpfile = io.open(tmpOutDir .. '/tmp.ly', 'w')
  tmpfile:write(code)
  tmpfile:close()
  os.execute('lilypond --loglevel=NONE -o ' .. tmpOutDir .. ' ' .. tmpOutDir .. '/tmp.ly')

  local convert = 'fluidsynth -T raw -F - ' .. tmpOutDir .. '/tmp.midi' ..
      ' -s | ffmpeg -f s32le -i - ' .. tmpOutDir .. '/tmp.mp3'
  require('nvls').make(convert,"%-G%.%#","tmpplayer")
end

return M
