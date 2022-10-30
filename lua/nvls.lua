local shellescape = vim.fn.shellescape

local default = {
  lilypond = {
    mappings = {
      player = "<F3>",
      compile = "<F5>",
      open_pdf = "<F6>",
      switch_buffers = "<A-Space>",
      insert_version = "<F4>",
      hyphenation = "<F12>",
      hyphenation_change_lang = "<F11>",
      insert_hyphen = "<leader>ih",
      add_hyphen = "<leader>ah",
      del_next_hyphen = "<leader>dfh",
      del_prev_hyphen = "<leader>dFh",
      del_selected_hyphen = "<leader>dh"
    },
    options = {
      pitches_language = "default",
      hyphenation_language = "en_DEFAULT",
      output = "pdf",
      main_file = "main.ly",
      main_folder = "%:p:h"
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
      border_style = "single",
      winhighlight = "Normal:Normal,FloatBorder:Normal"
    },
  },
}

local M = {}

M.setup = function(opts)
  opts = opts or {}
  vim.g.nvls_options = vim.tbl_deep_extend('keep', opts, vim.g.nvls_options or default)
end

function M.make(makeprg,errorfm,ctrl)
  ctrl = ctrl or nil
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
      if ctrl == "lilypond-book" then
        require('nvls.tex').lytexCmp()
      elseif ctrl == "fluidsynth" then
        vim.fn.execute('stopinsert')
        print(' ')
        require('nvls.lilypond').player()
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
