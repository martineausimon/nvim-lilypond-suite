local Utils = require('nvls.utils')
local nvls_options = require('nvls').get_nvls_options()

local M = {}

function M.fileInfos()
  local C = {}
  local audio_format = nvls_options.player.options.audio_format
  local midi_synth = nvls_options.player.options.midi_synth
  local main_folder, main_file
  local include_dir = nvls_options.lilypond.options.include_dir or ''

  if type(include_dir) == "table" then
    include_dir = "-I " .. table.concat(include_dir, " -I ")
  elseif include_dir ~= '' or include_dir ~= nil then
    include_dir = "-I " .. include_dir
  end

  if vim.bo.filetype == "tex" then
    main_folder = nvls_options.latex.options.main_folder
    main_file = nvls_options.latex.options.main_file
  elseif vim.bo.filetype == "texinfo" then
    main_folder = nvls_options.texinfo.options.main_folder
    main_file = nvls_options.texinfo.options.main_file
  elseif vim.bo.filetype == "lilypond" then
    main_folder = nvls_options.lilypond.options.main_folder
    main_file = nvls_options.lilypond.options.main_file
  end

  local main = vim.fn.expand('%:p')
  local main_path = vim.fs.joinpath(vim.fn.expand(main_folder), main_file)

  if vim.fn.filereadable(main_path) == 1 then
    main = main_path
  end

  if midi_synth == "timidity" then
    audio_format = "wav"
  end

  C.name             = vim.fn.fnamemodify(main, ":t:r")
  C.pdf              = Utils.change_extension(main, "pdf")
  C.audio            = Utils.change_extension(main, audio_format)
  C.audio_format     = audio_format
  C.midi             = Utils.change_extension(main, "midi")
  C.midi_synth       = midi_synth
  C.main             = main
  C.folder           = vim.fn.fnamemodify(main, ":h")
  C.tmp              = vim.fs.joinpath(vim.fn.stdpath("cache"), "nvls")
  C.output_fm        = nvls_options.lilypond.options.output
  C.include          = include_dir
  vim.fn.mkdir(C.tmp, 'p')

  return C
end

return M
