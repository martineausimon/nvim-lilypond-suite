local os_type = vim.loop.os_uname().sysname

local M = {}

function M.message(str, level)
  vim.schedule(function()
    level = level or "INFO"
    vim.notify("[NVLS] " .. str, vim.log.levels[level], {})
  end)
end

function M.has(file, string)
  local content = io.open(file, "r")
  if not content then return end
  content = content:read("*all")
  return content:find(string, 1, true) ~= nil
end

function M.change_extension(file, new)
  local base = vim.fn.fnamemodify(file, ":r")
  return base and base .. "." .. new or nil
end

function M.concat_flags(flags)
  if type(flags) == "table" then
    flags = table.concat(flags, " ")
  end
  return flags
end

function M.format_include_dirs(include_dir)
  local args = {}

  if type(include_dir) == "table" then
    for _, dir in ipairs(include_dir) do
      table.insert(args, vim.fn.expand(dir))
    end
  elseif include_dir and include_dir ~= '' then
    table.insert(args, vim.fn.expand(include_dir))
  end

  return args
end

function M.insert_flags(base_args, flags, at_start)
  if type(flags) == "table" then
    if at_start then
      for i = #flags, 1, -1 do
        table.insert(base_args, 1, flags[i])
      end
    else
      for _, flag in ipairs(flags) do
        table.insert(base_args, flag)
      end
    end
  elseif flags and flags ~= '' then
    if at_start then
      table.insert(base_args, 1, flags)
    else
      table.insert(base_args, flags)
    end
  end
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

function M.last_mod(file)
  if vim.fn.filereadable(file) ~= 1 then return 0 end

  local var = (
    os_type == "Darwin" and io.popen(string.format("stat -f %m %q", file)) or
    os_type == "Linux" and io.popen(string.format("stat -c %%Y %q", file)) or
    os_type == "Windows" and io.popen(string.format('for %%F in (%q) do @echo %%~tF', file))
  )

  local result = var and var:read("*a"):match("%d+") or "0"
  if var then var:close() end

  return tonumber(result)
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
      vim.fs.joinpath(_file.folder, 'tmp-ly'),
      vim.fs.joinpath(_file.folder, 'tmp[%w]+%.dvi'),
    }


    for _, item in ipairs(folder_contents) do
      if item:match("^tmp[%w]+%.dvi$") then
        table.insert(to_delete, vim.fs.joinpath(_file.folder, item))
      end
    end

    for _, file in ipairs(to_delete) do
      os.remove(file)
    end
  end
  local tmp_contents = vim.fn.readdir(_file.tmp)
  for _, item in ipairs(tmp_contents) do
    local item_path = vim.fs.joinpath(_file.tmp, item)
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
