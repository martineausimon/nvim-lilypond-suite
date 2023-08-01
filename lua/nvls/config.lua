local Utils = require('nvls.utils')
local nvls_options = require('nvls').get_nvls_options()

local main_folder
local main_file

local M = {}

function M.fileInfos(ft)
  local file = {}

  if ft == "tex" then
    main_folder = nvls_options.latex.options.main_folder
    main_file = nvls_options.latex.options.main_file
  elseif ft == "lilypond" then
    main_folder = nvls_options.lilypond.options.main_folder
    main_file = nvls_options.lilypond.options.main_file
  end

  local main = Utils.shellescape(vim.fn.expand('%:p'))

  if Utils.exists(Utils.joinpath(main_folder, '.lilyrc')) then
    dofile(Utils.joinpath(main_folder, '.lilyrc'))
    main = Utils.exists(Utils.joinpath(main_folder, main_file)) and Utils.shellescape(Utils.joinpath(main_folder, main_file)) or main
  elseif Utils.exists(Utils.joinpath(main_folder, main_file)) then
    main = Utils.shellescape(Utils.joinpath(main_folder, main_file))
  end

  local os_type = Utils.os_type()

  if os_type == "Windows" then
    local name = main:gsub("%.(i?ly)$", ""):gsub("%.tex$", "")
    file.name   = name:match('.*\\([^\\]+)$')
  else
    local name = main:gsub("%.(i?ly)$", ""):gsub("%.tex$", "")
    file.name   = name:match('.*/([^/]+)$'):gsub([[\]], "")
  end

  file.pdf    = Utils.change_extension(main, "pdf")
  file.mp3    = Utils.change_extension(main, "mp3")
  file.midi   = Utils.change_extension(main, "midi")
  file.main   = main
  file.folder = main_folder
  file.tmp    = Utils.joinpath(vim.fn.stdpath('cache'), 'nvls/')

  return file
end

return M
