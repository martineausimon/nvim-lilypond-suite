local M = {}

local stored_diagnostics = {}

local function get_content(line, type)
  local filename, row, col, message = nil, 0, 0, nil

  if type == "lilypond" or type == "lilypond-book" then
    filename, row, col, message = string.match(line, '^([^%s].+):(%d+):(%d+): (.+)$')
  else
    filename, row, message = string.match(line, '^([^%s].+):(%d+): (.+)$')
  end

  if not filename then return nil end

  return {
    filename = filename,
    row = tonumber(row) or 0,
    col = tonumber(col) or 0,
    message = string.gsub(message, '^error: ', ''),
    end_col = vim.api.nvim_win_get_width(0)
  }
end

local function parse_lilypond_line(line)
  return line:gsub("^(.-):(%d+):(.*)$", function(f, r, m)
    return f:gsub("././", vim.fn.stdpath("cache") .. "/nvls/") .. ":" .. (tonumber(r) + 3) .. ":" .. m
  end)
end

local function add_diagnostic_entry(file_diagnostics, content)
  if not file_diagnostics[content.filename] then
    file_diagnostics[content.filename] = {}
  end

  table.insert(file_diagnostics[content.filename], {
    severity = vim.diagnostic.severity.ERROR,
    message = content.message,
    lnum = content.row - 1,
    col = content.col - 1,
    end_col = content.end_col
  })
end

local function set_diagnostics(file_diagnostics)
  local ns = vim.api.nvim_create_namespace("nvls-diagnostics")
  for filename, diagnostics in pairs(file_diagnostics) do
    local bfnr = vim.fn.bufnr(filename, true)
    stored_diagnostics[filename] = diagnostics
    vim.diagnostic.set(ns, bfnr, diagnostics, {})
  end
end

function M.set(lines, errorfm, type)
  local file_diagnostics = {}
  local filtered_lines = {}

  for _, line in pairs(lines) do
    local content = get_content(line, type)
    if content then
      add_diagnostic_entry(file_diagnostics, content)

      if content.filename ~= vim.fn.expand("%:p") then
        if type == "lilypond-book" then
          line = parse_lilypond_line(line)
        end
        table.insert(filtered_lines, line)
      end
    end
  end

  if next(file_diagnostics) == nil then
    vim.diagnostic.reset()
    stored_diagnostics = {}
  else
    set_diagnostics(file_diagnostics)
  end

  vim.fn.setqflist({}, " ", {
    title = type,
    lines = filtered_lines,
    efm = errorfm,
  })

  vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})

  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
      local filename = vim.fn.expand("%:p")
      local ns = vim.api.nvim_create_namespace("nvls-diagnostics")
      local bfnr = vim.fn.bufnr(filename)

      if stored_diagnostics[filename] then
        vim.diagnostic.set(ns, bfnr, stored_diagnostics[filename], {})
      end
    end
  })

end

return M
