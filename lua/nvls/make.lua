local Config = require('nvls.config')
local Utils = require('nvls.utils')
local Diagnostics = require('nvls.diagnostics')
local Player = require('nvls.player')

local M = {}

local function commands()
  local C = Config.fileInfos()
  local name = Utils.shellescape(C.name, true)

  local cmds = {
    lilypond = {
      efm = "%f:%l:%c:%m,%f:%l:%m%[^;],%f:%l:%m,%-G%.%#",
      make = string.format('lilypond %s %s -f %s -o %s %s', C.backend, C.include, C.output_fm, Utils.joinpath(C.folder, name), C.main)
    },
    lualatex = {
      --efm = "%f:%l:%m,%-G%.%#",
      efm = "%f:%l:%c: %m,%f:%l:%m,%-G%.%#",
      make = string.format('lualatex --file-line-error --output-directory=%s --shell-escape --interaction=nonstopmode %s', C.folder, C.main)
    },
    texinfo = {
      efm = "%f:%l:%m,%-G%.%#",
      make = string.format('texi2pdf --output=%s %s', Utils.change_extension(C.main, "pdf"), C.main)
    },
    lilypondBook = {
      efm = '%+G%f:%l:%c:, %f:%l:%c: %m,%-G%.%#',
      make = string.format('lilypond-book %s %s %s --output=%s %s', C.lb_flags, C.backend, C.include, C.tmp, C.main)
    },
    lytex = {
      efm = "%f:%l:%m,%-G%.%#",
      make = string.format('cd %s && lualatex --file-line-error --output-directory=%s --shell-escape --interaction=nonstopmode %s', C.tmp, C.folder, Utils.joinpath(C.tmp, name .. '.tex'))
    },
    lytexi = {
      efm = "%f:%l:%m,%-G%.%#",
      make = string.format('cd %s && texi2pdf --output=%s %s', C.tmp, Utils.change_extension(C.main, "pdf"), Utils.shellescape(Utils.joinpath(C.tmp, name .. '.texi'), true))
    },
    fluidsynth = {
      efm = " ",
      make = (function()
        if C.midi_synth == "timidity" then
          return string.format('timidity %s %s -Ow -o %s', C.midi, C.timidity_flags, C.audio)
        else
          return string.format('fluidsynth %s -T raw -F - %s -s | ffmpeg -f s32le -i - %s', C.fluidsynth_flags, C.midi, C.audio)
        end
      end)()
    },
    tmpplayer = {
      efm = "%-G%.%#",
      make = (function()
        if C.midi_synth == "timidity" then
          return string.format('timidity %s %s -Ow -o %s', Utils.joinpath(C.tmp, "tmp.midi"), C.timidity_flags, Utils.joinpath(C.tmp, "tmp.wav"))
        else
          return string.format('fluidsynth %s -T raw -F - %s -s | ffmpeg -f s32le -i - %s', C.fluidsynth_flags, Utils.joinpath(C.tmp, "tmp.midi"), Utils.joinpath(C.tmp, "tmp." .. C.audio_format))
        end
      end)()
    },
  }

  local win_cmds = {
    lytex = {
      make = string.format('cd /d %s & lualatex --file-line-error --output-directory=%s --shell-escape --interaction=nonstopmode %s', C.tmp, C.folder, Utils.shellescape(Utils.joinpath(C.tmp, name .. '.tex'), true))
    },
    fluidsynth = {
      make = string.format('timidity %s %s -Ow -o %s', Utils.joinpath(C.tmp, "tmp.midi"), C.timidity_flags, Utils.joinpath(C.tmp, "tmp." .. C.audio_format))
    },
    tmpplayer = {
      make = string.format('timidity %s %s -Ow -o %s', Utils.joinpath(C.tmp, "tmp.midi"), C.timidity_flags, Utils.joinpath(C.tmp, "tmp." .. C.audio_format))
    }
  }

  if package.config:sub(1, 1) == '\\' then
    cmds = vim.tbl_deep_extend('keep', win_cmds, cmds)
  end

  return cmds
end

local type_commands = {}
local post_commands = {}

local function post(type, lines, errorfm)

  post_commands = {
    ["lilypond-book"] = function()
      if vim.bo.filetype == "tex" then
        M.async("lytex")
      elseif vim.bo.filetype == "texinfo" then
        M.async("lytexi")
      end
    end,
    ["fluidsynth"] = function()
      local C = Config.fileInfos()
      vim.fn.execute('stopinsert')
      print(' ')
      Player.open(C.audio, C.name .. "." .. C.audio_format)
    end,
    ["tmpplayer"] = function()
      local C = Config.fileInfos()
      vim.fn.execute('stopinsert')
      print(' ')
      Player.open(Utils.joinpath(C.tmp, 'tmp.' .. C.audio_format), "QuickPlayer")
    end,
    ["lilypond"] = function()
      if require('nvls').get_nvls_options().lilypond.options.diagnostics then
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

function M.async(type)

  local lines = {""}

  type_commands = {
    ["lilypond"] = { commands().lilypond.make, commands().lilypond.efm },
    ["lualatex"] = { commands().lualatex.make, commands().lualatex.efm },
    ["texinfo"] = { commands().texinfo.make, commands().texinfo.efm },
    ["lilypond-book"] = { commands().lilypondBook.make, commands().lilypondBook.efm },
    ["lytex"] = { commands().lytex.make, commands().lytex.efm },
    ["lytexi"] = { commands().lytexi.make, commands().lytexi.efm },
    ["fluidsynth"] = { commands().fluidsynth.make, commands().fluidsynth.efm },
    ["tmpplayer"] = { commands().tmpplayer.make, commands().tmpplayer.efm },
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
      post(type, lines, errorfm)
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

return M
