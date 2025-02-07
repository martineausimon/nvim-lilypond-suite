local Utils = require('nvls.utils')
local nvls_options = require('nvls').get_nvls_options()
local os = vim.loop.os_uname().sysname
local ft = vim.bo.ft

local M = {}

local function viewer_prg()

  local os_cmd = {
    ["Darwin"] = "open",
    ["Linux"] = "xdg-open",
    ["Windows"] = "start"
  }

  local config_cmd = {
    ["lilypond"] = nvls_options.lilypond.options.pdf_viewer,
    ["tex"] = nvls_options.latex.options.pdf_viewer,
    ["texinfo"] = nvls_options.texinfo.options.pdf_viewer
  }

  return config_cmd[ft] or os_cmd[os]
end

function M.open(file, name)
  name = name or nil
  if not Utils.exists(file) then
    Utils.message(string.format("File %s doesn't exists", name or file), "ERROR")
    do return end
  end


  if viewer_prg() then
    vim.fn.jobstart(string.format('%s %s', viewer_prg(), file))
  else
    Utils.message(string.format("Unsupported operating system : %s", os), "ERROR")
  end
end

return M
