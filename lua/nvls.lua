local shellescape = vim.fn.shellescape

local default = {
  lilypond = {
    mappings = {
      player = "<F3>",
      compile = "<F5>",
      open_pdf = "<F6>",
      switch_buffers = "<A-Space>",
      insert_version = "<F4>"
    },
    options = {
      pitches_language = "default"
    },
  },
  latex = {
    mappings = {
      compile = "<F5>",
      open_pdf = "<F6>",
      lilypond_syntax = "<F3>"
    },
    options = {
      clean_logs = false
    },
  },
  player = {
    mappings = {
      quit = "q",
      play_pause = "p",
      loop = "<A-l>",
      backward = "h",
      small_backward = "<S-h>",
      forward = "l",
      small_forward = "<S-l>",
      decrease_speed = "j",
      increase_speed = "k",
      halve_speed = "<S-j>",
      double_speed = "<S-k>"
    },
    options = {
      row = "2%",
      col = "99%",
      width = "37",
      height = "1",
      border_style = "single"
    },
  },
}

local M = {}

M.setup = function(opts)
	opts = opts or {}
	vim.g.nvls_options = vim.tbl_deep_extend('keep', opts, default)
end

function M.make(makeprg,errorfm)
  local lines = {""}
  local cmd = vim.fn.expandcmd(makeprg)
  local function on_event(job_id, data, event)
    if event == "stdout" or event == "stderr" then
      if data then
        vim.list_extend(lines, data)
      end
    end

    if event == "exit" then
      vim.fn.setqflist({}, " ", {
        title = cmd,
        lines = lines,
        efm = errorfm,
      })
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
      if vim.b.nvls_cmd == "lilypond-book" then
        require('tex').lytexCmp()
      elseif vim.b.nvls_cmd == "fluidsynth" then
        vim.fn.execute('stopinsert')
        print(' ')
        dofile(vim.b.lilyplay)
      else
        print(' ')
      end
    end
  end
  local job_id =
    vim.fn.jobstart(
      cmd,
      {
        on_stderr = on_event,
        on_stdout = on_event,
        on_exit = on_event,
        stdout_buffered = true,
        stderr_buffered = true,
      }
    )
end

function M.viewer(file)
  vim.fn.jobstart('xdg-open ' .. file)
end

return M
