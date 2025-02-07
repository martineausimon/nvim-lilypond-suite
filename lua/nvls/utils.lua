local os_type = vim.loop.os_uname().sysname

local M = {}

function M.message(str, level)
  level = level or "INFO"
  vim.notify("[NVLS] " .. str, vim.log.levels[level], {})
end

function M.has(file, string)
  local content = io.open(M.shellescape(file, false), "r")
  if not content then return end
  content = content:read("*all")
  return content:find(string, 1, true) ~= nil
end


function M.joinpath(parent, filename)
  if not filename then return '' end
  return parent .. package.config:sub(1, 1) .. filename
end

function M.remove_path(file)
  local out
  if os_type == "Windows" then
    out = file:match('.*\\([^\\]+)$')
  else
    out = file:match('.*/([^/]+)$')
  end
  return out
end

function M.remove_extension(file)
  local parts = {}
  for part in file:gmatch("([^%.]+)") do
    table.insert(parts, part)
  end
  if #parts > 1 then
    table.remove(parts)
  end
  local out = table.concat(parts, ".")
  return out
end

function M.change_extension(file, new)
  local base, current = file:match("^(.+)(%.%w+)$")
  return base and current and base .. "." .. new or nil
end

function M.shellescape(file, escape)
  if not file then return '' end
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

  if escape then
    for i, j in pairs(specialChars) do
      file = file:gsub(i, j)
    end
  else
    for i, j in pairs(specialChars) do
      file = file:gsub(j, i)
    end
  end

  return file
end

function M.concat_flags(flags)
  if type(flags) == "table" then
    flags = table.concat(flags, " ")
  end
  return flags
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

function M.clear_tmp_files()
  local _file = require('nvls.config').fileInfos()
  local folder_contents = vim.fn.readdir(_file.folder)
  local to_delete = {}
  if vim.bo.filetype == "tex" or vim.bo.filetype == "texinfo" then
    to_delete = {
      M.change_extension(_file.main, 'log'),
      M.change_extension(_file.main, 'aux'),
      M.change_extension(_file.main, 'out'),
      M.joinpath(_file.folder, 'tmp-ly'),
      M.joinpath(_file.folder, 'tmp[%w]+%.dvi'),
    }


    for _, item in ipairs(folder_contents) do
      if item:match("^tmp[%w]+%.dvi$") then
        table.insert(to_delete, M.joinpath(_file.folder, item))
      end
    end

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

function M.map(key, cmd)
  vim.keymap.set('n', key, cmd, { noremap = true, silent = true, buffer = true })
end

function M.imap(key, cmd)
  vim.keymap.set('i', key, cmd, { noremap = true, silent = true, buffer = true })
end

function M.vmap(key, cmd)
  vim.keymap.set('v', key, cmd, { noremap = true, silent = true, buffer = true })
end

return M
