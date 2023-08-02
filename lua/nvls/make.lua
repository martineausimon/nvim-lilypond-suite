local Config = require('nvls.config')
local Utils = require('nvls.utils')
local Diagnostics = require('nvls.diagnostics')
local Player = require('nvls.player')
local nvls_options = require('nvls').get_nvls_options()

local output = nvls_options.lilypond.options.output
local audio_format = nvls_options.player.options.audio_format
local midi_synth = nvls_options.player.options.midi_synth

if midi_synth == "timidity" then
  audio_format = "wav"
end

local include_dir = nvls_options.lilypond.options.include_dir or nil
if type(include_dir) == "table" then
  include_dir = table.concat(include_dir, " -I ")
end

local backend = nvls_options.lilypond.options.backend or nil
if backend then
  backend = "-dbackend=" .. backend .. " "
end

local M = {}

function M.commands()
  local ly = Config.fileInfos("lilypond")
  local ly_main = Utils.shellescape(ly.main)
  local ly_tmp = Utils.shellescape(ly.tmp)
  local ly_name = Utils.shellescape(ly.name)
  local tex = Config.fileInfos("tex")
  local tex_folder = Utils.shellescape(vim.fn.expand(tex.folder))
  local tex_main = Utils.shellescape(tex.main)
  local tex_tmp = Utils.shellescape(tex.tmp)
  local tex_name = Utils.shellescape(tex.name)

  local commands = {
    lilypond = {
      efm = "%f:%l:%c:%m,%f:%l:%m%[^;],%f:%l:%m,%-G%.%#",
      make = string.format('lilypond %s %s -f %s -o %s %s', backend or '', include_dir and ('-I ' .. include_dir) or '', output, ly_name, ly_main)
    },
    lualatex = {
      efm = "%f:%l:%m,%-G%.%#",
      make = string.format('lualatex --file-line-error --output-directory=%s --shell-escape --interaction=nonstopmode %s', tex_folder, tex_main)
    },
    lilypondBook = {
      efm = '%+G%f:%l:%c:, %f:%l:%c: %m,%-G%.%#',
      make = string.format('lilypond-book %s --output=%s %s', include_dir and ('-I ' .. include_dir) or '', tex_tmp, vim.fn.expand(tex_main))
    },
    lytex = {
      efm = "%f:%l:%m,%-G%.%#",
      make = string.format('cd %s && lualatex --file-line-error --output-directory=%s --shell-escape --interaction=nonstopmode %s', tex_tmp, tex_folder, Utils.shellescape(Utils.joinpath(tex_tmp, tex_name .. '.tex')))
    },
    fluidsynth = {
      efm = " ",
      make = (function()
        if midi_synth == "timidity" then
          return string.format('timidity %s -Ow -o %s', ly.midi, ly.audio)
        else
          return string.format('fluidsynth -T raw -F - %s -s | ffmpeg -f s32le -i - %s', ly.midi, ly.audio)
        end
      end)()
    },
    tmpplayer = {
      efm = "%-G%.%#",
      make = (function()
        if midi_synth == "timidity" then
          return string.format('timidity %s -Ow -o %s', Utils.joinpath(ly_tmp, "tmp.midi"), Utils.joinpath(ly_tmp, "tmp.wav"))
        else
          return string.format('fluidsynth -T raw -F - %s -s | ffmpeg -f s32le -i - %s', Utils.joinpath(ly_tmp, "tmp.midi"), Utils.joinpath(ly_tmp, "tmp." .. audio_format))
        end
      end)()
    },
  }

  local win_commands = {
    lytex = {
      make = string.format('cd /d %s & lualatex --file-line-error --output-directory=%s --shell-escape --interaction=nonstopmode %s', tex_tmp, tex_folder, Utils.shellescape(Utils.joinpath(tex_tmp, tex_name .. '.tex')))
    },
    fluidsynth = {
      make = string.format('timidity %s -Ow -o %s', Utils.joinpath(ly_tmp, "tmp.midi"), Utils.joinpath(ly_tmp, "tmp." .. audio_format))
    },
    tmpplayer = {
      make = string.format('timidity %s -Ow -o %s', Utils.joinpath(ly_tmp, "tmp.midi"), Utils.joinpath(ly_tmp, "tmp." .. audio_format))
    }
  }

  if package.config:sub(1, 1) == '\\' then
    commands = vim.tbl_deep_extend('keep', win_commands, commands)
  end

  return commands
end

local type_commands = {}
local post_commands = {}

function M.async(type)

  local lines = {""}

  type_commands = {
    ["lilypond"] = { M.commands().lilypond.make, M.commands().lilypond.efm },
    ["lualatex"] = { M.commands().lualatex.make, M.commands().lualatex.efm },
    ["lilypond-book"] = { M.commands().lilypondBook.make, M.commands().lilypondBook.efm },
    ["lytex"] = { M.commands().lytex.make, M.commands().lytex.efm },
    ["fluidsynth"] = { M.commands().fluidsynth.make, M.commands().fluidsynth.efm },
    ["tmpplayer"] = { M.commands().tmpplayer.make, M.commands().tmpplayer.efm },
  }

  local cmd, errorfm = unpack(type_commands[type] or {})

  if not cmd or not errorfm then
    do return end
  end

  local function on_event(job_id, data, event)
    if event == "stdout" or event == "stderr" then
      if data then
        vim.list_extend(lines, data)
      end
    end

    if event == "exit" then
      vim.fn.setqflist({}, " ", {
        title = type,
        lines = lines,
        efm = errorfm,
      })
      M.post(type, lines, errorfm)
    end
  end
  local job_id = vim.fn.jobstart(
    cmd,
    {
      on_stderr = on_event,
      on_stdout = on_event,
      on_exit = on_event,
      stdout_buffered = true,
      stderr_buffered = true,
    }
  )
end

function M.post(type, lines, errorfm)

  post_commands = {
    ["lilypond-book"] = function() M.async("lytex") end,
    ["fluidsynth"] = function()
      local file = Config.fileInfos("lilypond")
      vim.fn.execute('stopinsert')
      print(' ')
      Player.open(file.audio, file.name .. "." .. audio_format)
    end,
    ["tmpplayer"] = function()
      local file = Config.fileInfos("lilypond")
      vim.fn.execute('stopinsert')
      print(' ')
      Player.open(Utils.joinpath(file.tmp, 'tmp.' .. audio_format), "QuickPlayer")
    end,
    ["lilypond"] = function()
      if nvls_options.lilypond.options.diagnostics then
        Diagnostics.set(lines,errorfm,type)
      else
        vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
      end
      print(' ')
    end,
  }

  local postFunction = post_commands[type]

  if postFunction then
    postFunction()
  else
    vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
    print(' ')
  end

end

return M
