local Utils = require('nvls.errors.utils')
local unpack = unpack or table.unpack
local debug = require('nvls').debug
local opts = require("nvls").get_nvls_options()

local ns = vim.api.nvim_create_namespace("nvls-diagnostics")

local M = {}

local function load_errorformat(filetype)
  local success, efm = pcall(require, "nvls.errors." .. filetype)
  return success and efm or nil
end

local cmd_to_ft = {
  lualatex = "latex",
  texi2pdf = "texinfo",
  lilypond = "lilypond",
  ["lilypond-book"] = "lilypond"
}

local function filtered_lines(cmd, line)
  local ft = cmd_to_ft[cmd]
  if ft and opts[ft] and opts[ft].options.errors.filtered_lines then
    for _, pattern in ipairs(opts[ft].options.errors.filtered_lines) do
      if line:find(pattern) then return true end
    end
  end
  return false
end

local function is_error_start(cmd, line)
  local patterns = {
    lilypond = { "[^:]+:" },
    lualatex = {
      "[^:]+:%d+:",
      "LaTeX Error:"
    },
    texi2pdf = {
      "[^:]+:%d+:",
      "LaTeX Error:"
    },
    ["lilypond-book"] = { "[^:]+:" },
  }
  for _, pattern in ipairs(patterns[cmd]) do
    if line:match(pattern) then
      return true
    end
  end
  return false
end

local function is_multiline(cmd, line)
  local rules = {
    lilypond = {
      "^%s",
      "\\version%s\"[%d%.]+\""
    },
    lualatex = {
      "^%s",
      "^<recently read>%s",
      "^l%.%d+",
      "^.+:"
    },
    texi2pdf = {
      "^%s+",
      "^<recently read>%s",
      "^l%.%d+",
      "^.+:",
      "^?%s"
    },
    ["lilypond-book"] = {
      "^%s",
      "\\version%s\"[%d%.]+\""
    }
  }
  for _, pattern in ipairs(rules[cmd] or {}) do
    if line:match(pattern) then
      return true
    end
  end
  return false
end

local function is_end_of_errors(cmd, line)
  local end_patterns = {
    lilypond = {},
    lualatex = {
      "Output written on",
      "Transcript written on",
      "%(see the transcript file for additional information%)",
      "^###",
      "^%d+ words of node memory still in use",
    },
    texi2pdf = {
      "Output written on",
      "Transcript written on",
      "%(see the transcript file for additional information%)",
      "^###",
      "^%d+ words of node memory still in use",
    },
    ["lilypond-book"] = {}
  }
  for _, pattern in ipairs(end_patterns[cmd]) do
    if line:match(pattern) then return true end
  end
  return false
end

M.diagnostics_store = {}

function M.process(cmd, stderr_output)

  for bufnr, _ in pairs(M.diagnostics_store) do
    vim.diagnostic.reset(ns, bufnr)
  end

  M.diagnostics_store = {}

  local ft_errorformats = load_errorformat(cmd)
  if not ft_errorformats then return end

  local errors = {}
  local append_last = false

  for _, line in ipairs(vim.split(stderr_output, "[\r\n]+")) do
    line = line:gsub(" ", "")
    if not filtered_lines(cmd, line) then
      if is_end_of_errors(cmd, line) then break end
      if is_error_start(cmd, line) then
        table.insert(errors, line)
        append_last = true
      elseif append_last and is_multiline(cmd, line) then
        errors[#errors] = errors[#errors] .. "|" .. line
      else
        append_last = false
      end
    end
  end

  errors = Utils.remove_duplicates(errors)

  local qf_list = {}
  local diagnostics = {}

  for _, err in ipairs(errors) do
    err = err:gsub("%s+", " ")
    debug.errors = (debug.errors or "") .. "\n" .. err

    for _, efm in ipairs(ft_errorformats) do
      local matches = { err:match(efm.pattern) }
      if #matches > 0 then
        local entry = efm.rule(unpack(matches))
        table.insert(qf_list, entry)

        local ft = cmd_to_ft[cmd]
        if ft and opts[ft] and opts[ft].options.errors.diagnostics then
          if entry.filename then
            local severity_map = {
              E = vim.diagnostic.severity.ERROR,
              W = vim.diagnostic.severity.WARN,
              I = vim.diagnostic.severity.INFO,
              N = vim.diagnostic.severity.HINT
            }
            local bufnr = entry.filename and vim.fn.bufnr(entry.filename, true) or 0
            local severity = severity_map[entry.type] or vim.diagnostic.severity.ERROR
            table.insert(diagnostics, {
              bufnr = bufnr,
              severity = severity,
              message = entry.text,
              lnum = entry.lnum - 1,
              col = (entry.col or 1) - 1,
              end_col = (entry.end_col or entry.col or 1)
            })
          end
        end

        break
      end
    end
  end

  if #qf_list > 0 then
    local ft = cmd_to_ft[cmd]
    local filtered_qf_list = qf_list

    if ft and opts[ft] and opts[ft].options.errors.quickfix == "external" then
      local current_bufnr = vim.api.nvim_get_current_buf()
      filtered_qf_list = vim.tbl_filter(function(entry)
        local entry_bufnr = entry.filename and vim.fn.bufnr(entry.filename, true) or nil
        return entry_bufnr and entry_bufnr ~= current_bufnr
      end, qf_list)
    end

    if #filtered_qf_list > 0 then
      vim.fn.setqflist(filtered_qf_list, 'r')
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
    end
  end

  for bufnr, _ in pairs(M.diagnostics_store) do
    vim.diagnostic.reset(ns, bufnr)
  end

  if #diagnostics > 0 then
    diagnostics = Utils.diagnostics_priority(diagnostics)
    for _, diag in ipairs(diagnostics) do
      M.diagnostics_store[diag.bufnr] = M.diagnostics_store[diag.bufnr] or {}
      table.insert(M.diagnostics_store[diag.bufnr], diag)
    end

    for bufnr, diags in pairs(M.diagnostics_store) do
      vim.diagnostic.set(ns, bufnr, diags)
    end
end
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local bufnr = args.buf
    if M.diagnostics_store[bufnr] then
      vim.diagnostic.set(ns, bufnr, M.diagnostics_store[bufnr])
    end
  end
})

return M
