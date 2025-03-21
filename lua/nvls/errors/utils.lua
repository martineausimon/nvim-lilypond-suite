local M = {}

function M.format_pattern(pattern)
  return pattern and pattern:gsub("\\", "\\\\") or nil
end

function M.qf_type(loglevel)
  return ({
    error = "E",
    warning = "W",
    Erreur = "E",
    Avertissement = "W",
  })[loglevel] or "I"
end

function M.get_end_col(file, lnum, col)
  lnum = tonumber(lnum)
  col = tonumber(col)
  local bufnr = vim.fn.bufnr(file, false)
  local end_col = col
  local line_text

  if bufnr ~= -1 then
    line_text = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  else
    line_text = vim.fn.readfile(file)[lnum]
  end
  return line_text and #line_text or end_col
end

function M.get_col(file, lnum, pattern)
  local f = io.open(file, "r")
  if not f then
    return nil
  end

  local line
  for i = 1, lnum do
    line = f:read("*l")
    if not line then
      f:close()
      return nil
    end
  end

  local start_col = line:find(pattern)

  f:close()

  if start_col then
    return start_col
  else
    return 0
  end
end

function M.remove_duplicates(t)
  local seen, i = {}, 1
  while i <= #t do
    if seen[t[i]] then
      table.remove(t, i)
    else
      seen[t[i]] = true
      i = i + 1
    end
  end
  return t
end

function M.diagnostics_priority(diagnostics)
  local priorities = {
    ["\\lyricmode"] = 1,
    ["Emergency stop"] = 1,
    ["Fatal error occurred"] = 1,
  }
  table.sort(diagnostics, function(a, b)
    local function get_priority(message)
      for pattern, priority in pairs(priorities) do
        if message:find(pattern) then
          return priority
        end
      end
      return math.huge
    end
    local a_priority = get_priority(a.message)
    local b_priority = get_priority(b.message)
    if a_priority ~= b_priority then
      return a_priority < b_priority
    else
      return a.lnum < b.lnum
    end
  end)
  return diagnostics
end

return M

