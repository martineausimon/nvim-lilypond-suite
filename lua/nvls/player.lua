local Config = require('nvls.config')
local Utils = require('nvls.utils')
local nvls_options = require('nvls').get_nvls_options()
local audio_format = nvls_options.player.options.audio_format

local M = {}

function M.convert()
  local ly = Config.fileInfos("lilypond")
  local audio = Utils.shellescape(ly.audio)
  local midi = Utils.shellescape(ly.midi)
  local os_type = Utils.os_type()
  if os_type ~= "Linux" and os_type ~= "Darwin" and audio_format ~= "wav" then
    Utils.message("In Windows, audio_format must be set to \"wav\"", "ErrorMsg")
    do return end
  end

  if Utils.exists(midi) then

    local midi_last = Utils.last_mod(midi)
    local audio_last = Utils.last_mod(audio)

    if (audio_last > midi_last) then
      M.open(audio, ly.name .. "." .. audio_format)

    else
      Utils.message(string.format('Converting %s.midi to %s...', ly.name, audio_format))
      os.remove(audio)
      require('nvls.make').async("fluidsynth")
    end

  elseif Utils.exists(audio) then
    M.open(audio, ly.name .. "." .. audio_format)

  else
    Utils.message(string.format("Can't find %s.%s or %s.midi in working directory", ly.name, audio_format, ly.name), "ErrorMsg")
    do return end
  end
end

function M.open(file,name)
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
    vim.fn.execute("term mpv " .. table.concat(plopts.mpv_flags, " ") .. " " .. file)
    vim.fn.execute('stopinsert')
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

function M.quickplayerInputType(sel)
  local from_top = Utils.extract_from_sel({0, 1, 1, 0}, vim.fn.getpos("'<"))

  local function getInputTypeFromSource(source)
    local relative = source:match(".*%prelative%s+%a*%p*%s*%{")
    local fixed = source:match(".*%pfixed%s+%a*%p*%s*%{")
    local chords = source:match(".*%pchords%s+%{")

    if relative then
      local ref_pitch = relative:match(".*%prelative(%s+%a%p*)")
      return "\\relative" .. ref_pitch
    elseif fixed then
      local ref_pitch = fixed:match(".*%pfixed(%s+%a%p*)")
      return "\\fixed" .. ref_pitch
    elseif chords then
      return "\\chords"
    else
      return ''
    end
  end

  if string.find(sel, "%pfixed%s+%a*%p*%s*%{") or
     string.find(sel, "%prelative%s+%a*%p*%s*%{") or
     string.find(sel, "%pchords.*%{") then
    return ''
  else
    return getInputTypeFromSource(from_top)
  end
end

function M.quickplayerGetTempo(sel)
  local from_top = Utils.extract_from_sel({0, 1, 1, 0}, vim.fn.getpos("'<"))

  local function extractTempo(source)
    local tempo = source:match([[.*%ptempo%s+(%d+%s*%=%s*%d+)]]) or
                  source:match([[.*%ptempo%s+(%"%a*%"%s+%d+%s*%=%s*%d+)]]) or
                  source:match([[.*%ptempo%s+(%"%a+%")]]) or
                  "4=60"
    return "\\tempo " .. tempo
  end

  if not (string.find(sel, "%ptempo%s") or string.find(from_top, "%ptempo%s")) then
    return ''
  else
    return extractTempo(from_top)
  end
end

function M.quickplayerCheckErr(str)
  local function countChar(str, char)
    local count = 0
    for _ in str:gmatch(char) do
      count = count + 1
    end
    return count
  end

  local bracket_pairs = {
    ["{"] = "}",
    ["<"] = ">"
  }

  for op_br, cl_br in pairs(bracket_pairs) do
    local op_count = countChar(str, op_br)
    local cl_count = countChar(str, cl_br)
    if op_count ~= cl_count then
      return string.format("%s brackets not matching in visual selection", op_br)
    end
  end

  if string.find(str, "%pscore%s") then
    return "Can't compile with \\score in visual selection"
  end

  return nil
end

function M.quickplayer()
  Utils.clear_tmp_files("lilypond")
  local sel = Utils.extract_from_sel(vim.fn.getpos("'<"), vim.fn.getpos("'>"))

  local err_msg = M.quickplayerCheckErr(sel)
  if err_msg then
    Utils.message(err_msg, "ErrorMsg")
    return
  else
    Utils.message('Converting to ' .. audio_format)
  end

  local input_type = M.quickplayerInputType(sel)

  local tempo = M.quickplayerGetTempo(sel)

  local codeParts = {}
  table.insert(codeParts, "\\score { ")
  table.insert(codeParts, input_type .. " { " .. sel .. " } ")
  table.insert(codeParts, "\\midi { " .. tempo .. " } ")
  table.insert(codeParts, "}")
  local code = table.concat(codeParts)

  local ly = Config.fileInfos("lilypond")
  local ly_file = Utils.joinpath(ly.tmp, 'tmp.ly')
  local tmpfile = io.open(ly_file, 'w')
  if tmpfile then
    tmpfile:write(code)
    tmpfile:close()
  end
  os.execute(string.format('lilypond --loglevel=NONE -o %s %s', ly.tmp, ly_file))

  require('nvls.make').async("tmpplayer")
end

return M
