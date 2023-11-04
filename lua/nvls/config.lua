local Utils = require('nvls.utils')
local nvls_options = require('nvls').get_nvls_options()
local audio_format = nvls_options.player.options.audio_format
local midi_synth = nvls_options.player.options.midi_synth

local M = {}


function M.fileInfos()
  local file = {}
  local main_folder, main_file, lb_flags
  local backend = nvls_options.lilypond.options.backend

  if vim.bo.filetype == "tex" then
    main_folder = nvls_options.latex.options.main_folder
    main_file = nvls_options.latex.options.main_file
    lb_flags = nvls_options.latex.options.lilypond_book_flags or ''
    if backend then
      backend = '--process "lilypond -dbackend=' .. backend .. '"'
    end
  elseif vim.bo.filetype == "texinfo" then
    main_folder = nvls_options.texinfo.options.main_folder
    main_file = nvls_options.texinfo.options.main_file
    lb_flags = nvls_options.texinfo.options.lilypond_book_flags or ''
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

  if type(lb_flags) == "table" then
    lb_flags = table.concat(lb_flags, " ")
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

  file.name     = Utils.remove_path(name)
  file.pdf      = Utils.change_extension(main, "pdf")
  file.audio    = Utils.change_extension(main, audio_format)
  file.midi     = Utils.change_extension(main, "midi")
  file.main     = main
  file.folder   = Utils.shellescape(vim.fn.expand(main_folder), true)
  file.tmp      = Utils.joinpath(vim.fn.stdpath('cache'), 'nvls')
  file.backend  = backend or ''
  file.lb_flags = lb_flags
  vim.fn.mkdir(file.tmp, 'p')

  return file
end

return M
