local Utils = require('nvls.utils')
local nvls_options = require('nvls').get_nvls_options()

return function()
  local opts = {
    player = nvls_options.player.options,
    tex = nvls_options.latex.options,
    texinfo = nvls_options.texinfo.options,
    lilypond = nvls_options.lilypond.options,
  }

  local audio_format = opts["player"].audio_format
  local midi_synth = opts["player"].midi_synth
  if midi_synth == "timidity" then
    audio_format = "wav"
  end

  local main_folder, main_file
  local current_filetype = vim.bo.filetype

  if opts[current_filetype] then
    main_folder = opts[current_filetype].main_folder
    main_file = opts[current_filetype].main_file
  end

  local main = vim.fn.expand('%:p')
  local main_path = vim.fs.joinpath(vim.fn.expand(main_folder), main_file)

  if vim.fn.filereadable(main_path) == 1 then
    main = main_path
  end

  local file = {
    name = vim.fn.fnamemodify(main, ":t:r"),
    pdf = Utils.change_extension(main, "pdf"),
    audio = Utils.change_extension(main, audio_format),
    audio_format = audio_format,
    midi = Utils.change_extension(main, "midi"),
    midi_synth = midi_synth,
    main = main,
    folder = vim.fn.fnamemodify(main, ":h"),
    tmp = vim.fs.joinpath(vim.fn.stdpath("cache"), "nvls"),
    output_fm = opts["lilypond"].output
  }

  return file
end
