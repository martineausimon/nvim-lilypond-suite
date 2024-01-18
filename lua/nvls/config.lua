local Utils = require('nvls.utils')
local nvls_options = require('nvls').get_nvls_options()

local M = {}

function M.fileInfos()
  local C = {}
  local audio_format = nvls_options.player.options.audio_format
  local midi_synth = nvls_options.player.options.midi_synth
  local main_folder, main_file, lb_flags
  local backend = nvls_options.lilypond.options.backend
  local include_dir = nvls_options.lilypond.options.include_dir or ''

  if type(include_dir) == "table" then
    include_dir = "-I " .. table.concat(include_dir, " -I ")
  elseif include_dir ~= '' or include_dir ~= nil then
    include_dir = "-I " .. include_dir
  end

  if vim.bo.filetype == "tex" then
    main_folder = nvls_options.latex.options.main_folder
    main_file = nvls_options.latex.options.main_file
    lb_flags = Utils.concat_flags(nvls_options.latex.options.lilypond_book_flags) or ''
    if backend then
      backend = '--process "lilypond -dbackend=' .. backend .. '"'
    end
  elseif vim.bo.filetype == "texinfo" then
    main_folder = nvls_options.texinfo.options.main_folder
    main_file = nvls_options.texinfo.options.main_file
    lb_flags = Utils.concat_flags(nvls_options.texinfo.options.lilypond_book_flags) or ''
    if backend then
      backend = '--process "lilypond -dbackend=' .. backend .. '"'
    end
  elseif vim.bo.filetype == "lilypond" then
    main_folder = nvls_options.lilypond.options.main_folder
    main_file = nvls_options.lilypond.options.main_file
    if backend then
      backend = '-dbackend=' .. backend
    end
  end

  local main = Utils.shellescape(vim.fn.expand('%:p'), true)
  local main_path = Utils.joinpath(vim.fn.expand(main_folder), main_file)

  if Utils.exists(main_path) then
    main = Utils.shellescape(main_path, true)
  end

  local name = Utils.remove_extension(main)
  name = Utils.shellescape(name, false)

  if os == "Windows" or midi_synth == "timidity" then
    audio_format = "wav"
  end

  C.name             = Utils.remove_path(name)
  C.pdf              = Utils.change_extension(main, "pdf")
  C.audio            = Utils.change_extension(main, audio_format)
  C.audio_format     = audio_format
  C.midi             = Utils.change_extension(main, "midi")
  C.midi_synth       = midi_synth
  C.fluidsynth_flags = Utils.concat_flags(nvls_options.player.options.fluidsynth_flags)
  C.timidity_flags   = Utils.concat_flags(nvls_options.player.options.timidity_flags)
  C.main             = main
  C.folder           = Utils.shellescape(vim.fn.expand(main_folder), true)
  C.tmp              = Utils.joinpath(vim.fn.stdpath('cache'), 'nvls')
  C.backend          = backend or ''
  C.output_fm        = nvls_options.lilypond.options.output
  C.lb_flags         = lb_flags
  C.include          = include_dir
  vim.fn.mkdir(C.tmp, 'p')

  return C
end

return M
