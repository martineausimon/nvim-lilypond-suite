local Utils = require('nvls.utils')
local nvls_options = require('nvls').get_nvls_options()

local M = {}

function M.open(file, name)
  name = name or nil
  if not Utils.exists(file) then
    Utils.message(string.format("File %s doesn't exists", name or file), "ERROR")
    do return end
  end

  local os = vim.loop.os_uname().sysname

  local os_commands = {
      ["Darwin"] = "open",
      ["Linux"] = "xdg-open",
      ["Windows"] = "start"
  }

  local cmd = os_commands[os]

  if nvls_options.lilypond.options.pdf_viewer ~= nil then
    cmd = nvls_options.lilypond.options.pdf_viewer
    vim.fn.jobstart(string.format('%s %s', cmd, file))
  elseif cmd then
    vim.fn.jobstart(string.format('%s %s', cmd, file))
  else
    Utils.message(string.format("Unsupported operating system : %s", os), "ERROR")
  end
end

return M
