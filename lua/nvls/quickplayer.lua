local Utils = require('nvls.utils')
local Job = require('nvls.job')
local Audio = require('nvls.audio')

local M = {}

local function inputType(sel)
  local from_top = Utils.extract_from_sel({0, 1, 1, 0}, vim.fn.getpos("'<"))

  local function getInputTypeFromSource(source)
    local relative = source:match(".*%prelative%s+%a*%p*%s*%{")
    local fixed = source:match(".*%pfixed%s+%a*%p*%s*%{")
    local chords = source:match(".*%pchords%s+%{")

    if relative then
      local ref_pitch = relative:match(".*%prelative(%s+%a%p*)") or " "
      return "\\relative" .. ref_pitch
    elseif fixed then
      local ref_pitch = fixed:match(".*%pfixed(%s+%a%p*)") or " "
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

local function getTempo(sel)
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

local function checkErr(str)
  local function countChar(s, char)
    local count = 0
    for _ in s:gmatch(char) do
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

function M.run()
  local file = require('nvls').get_file_infos()
  Utils.clear_tmp_files()

  local sel = Utils.extract_from_sel(vim.fn.getpos("'<"), vim.fn.getpos("'>"))

  local err_msg = checkErr(sel)
  if err_msg then
    Utils.message(err_msg, "ERROR")
    return
  end

  local input_type = inputType(sel)
  local tempo = getTempo(sel)

  local code = table.concat({
    "\\score { ",
    input_type .. " { " .. sel .. " } ",
    "\\midi { " .. tempo .. " } ",
    "}"
  })

  local ly_file = vim.fs.joinpath(file.tmp, 'tmp.ly')
  local tmpfile = io.open(ly_file, 'w')
  if tmpfile then
    tmpfile:write(code)
    tmpfile:close()
  end

  Job:add('lilypond', {
    "--loglevel=NONE",
    "-o", file.tmp,
    ly_file
  })

  Audio.create(vim.fs.joinpath(file.tmp, "tmp.midi"), file.audio_format, function(audio_out)
    require('nvls.player').load_or_open(audio_out)
  end)
end

return M
