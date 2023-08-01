local M = {}

function M.set(lines, errorfm, type)
  vim.diagnostic.reset()
  local file_diagnostics = {}
  local filtered_lines = {}

  for _, line in pairs(lines) do
    local filename, row, col, message = string.match(line,'^([^%s].+):(%d+):(%d+): (.+)$')
    if filename then
      message = string.gsub(message, '^error: ', '')
      if not file_diagnostics[filename] then
        file_diagnostics[filename] = {}
      end
      table.insert(file_diagnostics[filename], {
        severity = vim.diagnostic.severity.ERROR,
        message = message,
        lnum = tonumber(row) - 1,
        col = tonumber(col) -1,
      })
      if filename ~= vim.fn.expand("%:p") then
        table.insert(filtered_lines, line)
      end
    end
  end

  local ns = vim.api.nvim_create_namespace("lilypond-diagnostics")
  for filename, diagnostics in pairs(file_diagnostics) do
    local bfnr = vim.fn.bufnr(vim.fn.expand(filename))
    vim.diagnostic.set(ns, bfnr, diagnostics, {})
  end

  vim.fn.setqflist({}, " ", {
    title = type,
    lines = filtered_lines,
    efm = errorfm,
  })

  vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
end

return M
