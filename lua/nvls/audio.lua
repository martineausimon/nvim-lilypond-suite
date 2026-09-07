local Utils = require('nvls.utils')
local Job = require('nvls.job')

local M = {}

local function get_plopts()
  return require('nvls').get_nvls_options().player.options
end

function M.create(midi_input, format, on_done)
  local plopts = get_plopts()
  local audio_out = Utils.change_extension(midi_input, format)

  if plopts.midi_synth == "timidity" then
    local timidity_args = {
      midi_input, "-Ow",
      "-o", audio_out,
    }
    Utils.insert_flags(timidity_args, plopts.timidity_flags, false)

    Job:add("timidity", timidity_args, nil, function()
      if on_done then on_done(audio_out) end
    end)

  elseif plopts.midi_synth == "fluidsynth" then
    local raw_file = vim.fs.joinpath(require('nvls').get_tmp_folder(), "tmp.raw")

    local fluidsynth_args = {
      "-n", "-a", "file",
      "-T", "raw",
      "-F", raw_file,
    }

    Utils.insert_flags(fluidsynth_args, plopts.fluidsynth_flags, false)
    table.insert(fluidsynth_args, midi_input)

    local ffmpeg_args = {
      "-ac", "2",
      "-f", "s16le",
      "-i", raw_file,
    }
    Utils.insert_flags(ffmpeg_args, plopts.ffmpeg_flags)
    Utils.insert_flags(ffmpeg_args, audio_out)

    Job:add("fluidsynth", fluidsynth_args)
    Job:add("ffmpeg", ffmpeg_args, nil, function()
      vim.fn.delete(raw_file, "rf")
      if on_done then on_done(audio_out) end
    end)
  end
end

return M
