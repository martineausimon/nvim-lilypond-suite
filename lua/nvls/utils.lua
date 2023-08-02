
local M = {}

function M.message(str, hl)
  hl = hl or "Normal"
  vim.api.nvim_echo({{"[NVLS] " .. str, hl}}, true, {})
end

function M.joinpath(parent, filename)
  return parent .. package.config:sub(1, 1) .. filename
end

function M.change_extension(filename, newExtension)
  local baseName, currentExtension = filename:match("^(.+)(%.%w+)$")
  if baseName and currentExtension then
    return baseName .. "." .. newExtension
  else
    return nil
  end
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

  local specialChars

  if package.config:sub(1, 1) == '\\' then
    specialChars = windows
  else
    specialChars = unix
  end

  for i, j in pairs(specialChars) do
    file = file:gsub(i, j)
  end

  return file
end

function M.extract_from_sel(_start, _end)
  local nlines = math.abs(_end[2] - _start[2]) + 1
  local sel = vim.api.nvim_buf_get_lines(0, _start[2] - 1, _end[2], false)

  sel[1] = string.sub(sel[1], _start[3], -1)
  sel[nlines] = sel[nlines]:sub(1, _end[3])

  return table.concat(sel, '\n')
end

function M.os_type()
  if package.config:sub(1, 1) == '\\' then
    return "Windows"
  else
    local uname = io.popen("uname")
    local kernel = uname and uname:read("*a")
    return kernel and kernel:match("[^\r\n]+") or "Unknown"
  end
end

function M.exists(path)
  return io.open(vim.fn.glob(path)) ~= nil
end

function M.last_mod(file)
  local var
  local os_type = M.os_type()
  if io.open(vim.fn.glob(file), "r") == nil then
    return 0
  else
    if os_type == "Darwin" then
      var = io.popen("stat -f %m " .. file)
    elseif os_type == "Linux" then
      var = io.popen("stat -c %Y " .. file)
    elseif os_type == "Windows" then
      var = io.popen(string.format("for %%F in (%s) do @echo %%~tF", file))
    end
    if var then
      var = var:read()
      var = tonumber(var)
      return var
    end
  end
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
      if M.exists(file) then
        os.remove(file)
      end
    end
  end
  local tmp_contents = vim.fn.readdir(_file.tmp)
  for _, item in ipairs(tmp_contents) do
    local item_path = M.joinpath(_file.tmp, item)
    table.insert(to_delete, item_path)
  end
  for _, file in ipairs(to_delete) do
    if M.exists(file) then
      vim.fn.delete(file, "rf")
    end
  end
end

return M
