local M = {}

local function marks_file()
  return vim.fs.joinpath(require('nvls').get_tmp_folder(), "nvls_marks.json")
end

local function load_all()
  local f = io.open(marks_file(), "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  local ok, res = pcall(vim.fn.json_decode, content)
  return ok and type(res) == "table" and res or {}
end

local function save_all(all_marks)
  vim.fn.mkdir(require('nvls').get_tmp_folder(), "p")
  local f = io.open(marks_file(), "w")
  if f then
    f:write(vim.fn.json_encode(all_marks))
    f:close()
  end
end

function M.key_for(file)
  local ok, infos = pcall(function() return require('nvls').get_file_infos() end)
  if ok and infos and infos.midi and file:find("tmp") then
    return vim.fs.normalize(infos.midi)
  end
  return vim.fs.normalize(file)
end

function M.for_file(file_key)
  local all = load_all()
  local file_marks = all[file_key] or {}

  local api = {}

  function api.list()
    local keys = {}
    for k, _ in pairs(file_marks) do table.insert(keys, k) end
    if #keys == 0 then return "" end
    table.sort(keys)
    return " [" .. table.concat(keys, ", ") .. "]"
  end

  function api.get(ch)
    return file_marks[ch]
  end

  function api.set(ch, time_pos)
    file_marks[ch] = time_pos
    all[file_key] = file_marks
    save_all(all)
  end

  function api.delete(ch)
    file_marks[ch] = nil
    all[file_key] = file_marks
    save_all(all)
  end

  return api
end

return M
