local os_type = vim.loop.os_uname().sysname

local M = {}

function M.message(str, level)
  level = level or "INFO"
  vim.notify("[NVLS] " .. str, vim.log.levels[level], {})
end

function M.joinpath(parent, filename)
  return parent .. package.config:sub(1, 1) .. filename
end

function M.change_extension(file, new)
  local base, current = file:match("^(.+)(%.%w+)$")
  return base and current and base .. "." .. new or nil
end

function M.shellescape(file)
  local windows = {
    [" "] = "^ ",
    ["%("] = "^%(",
    ["%)"] = "^%)"
  }
  local unix = {
    [" "] = "\\ ",
    ["%("] = "\\%(",
    ["%)"] = "\\%)"
  }

  local specialChars = (os_type == "Windows") and windows or unix

  for i, j in pairs(specialChars) do
    file = file:gsub(i, j)
  end

  return file
end

function M.extract_from_sel(_start, _end)
  local nlines = math.abs(_end[2] - _start[2]) + 1
  local sel = vim.api.nvim_buf_get_lines(0, _start[2] - 1, _end[2], false)

  if nlines == 1 then
    sel[1] = sel[1]:sub(_start[3], _end[3])
  else
    sel[1] = sel[1]:sub(_start[3], -1)
    sel[nlines] = sel[nlines]:sub(1, _end[3])
  end

  return table.concat(sel, '\n')
end

function M.exists(path)
  return io.open(vim.fn.glob(path)) ~= nil
end

function M.last_mod(file)
  if not M.exists(file) then return 0 end
  local var = (
    os_type == "Darwin" and io.popen("stat -f %m " .. file) or
    os_type == "Linux" and io.popen("stat -c %Y " .. file) or
    os_type == "Windows" and io.popen(string.format("for %%F in (%s) do @echo %%~tF", file))
  )
  return var and tonumber(var:read()) or 0
end

function M.clear_tmp_files(type)
  local _file = require('nvls.config').fileInfos(type)
  local to_delete = {}
  if type == "tex" then
    to_delete = {
      M.change_extension(_file.main, 'log'),
      M.change_extension(_file.main, 'aux'),
      M.change_extension(_file.main, 'out'),
      M.joinpath(_file.folder, 'tmp-ly'),
    }
    for _, file in ipairs(to_delete) do
      os.remove(file)
    end
  end
  local tmp_contents = vim.fn.readdir(_file.tmp)
  for _, item in ipairs(tmp_contents) do
    local item_path = M.joinpath(_file.tmp, item)
    table.insert(to_delete, item_path)
  end
  for _, file in ipairs(to_delete) do
    vim.fn.delete(file, "rf")
  end
end

function M.map(key, cmd, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, key, cmd, { noremap = true, silent = true, buffer = true })
end

return M
