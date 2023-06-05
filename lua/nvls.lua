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
      del_next_hyphen = "<leader>dh",
      del_prev_hyphen = "<leader>dH",
    },
    options = {
      pitches_language = "default",
      hyphenation_language = "en_DEFAULT",
      output = "pdf",
      main_file = "main.ly",
      main_folder = "%:p:h",
      include_dir = nil,
      diagnostics = false,
    },
  },
  latex = {
    mappings = {
      compile = "<F5>",
      open_pdf = "<F6>",
      lilypond_syntax = "<F3>"
    },
    options = {
      clean_logs = false,
      main_file = "main.tex",
      main_folder = "%:p:h",
      include_dir = nil,
      lilypond_syntax_au = "BufEnter",
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
      winhighlight = "Normal:Normal,FloatBorder:Normal",
      mpv_flags = {
        "--msg-level=cplayer=no,ffmpeg=no,alsa=no",
        "--loop",
        "--config-dir=/dev/null"
      }
    },
  },
}

local default_hi = {
  lilyString = { link = "String" },
  lilyDynamic = { bold = true },
  lilyComment = { link = "Comment" },
  lilyNumber = { link = "Number" },
  lilyVar = { link = "Tag" },
  lilyBoolean = { link = "Boolean" },
  lilySpecial = { bold = true },
  lilyArgument = { link = "Type" },
  lilyScheme = { link = "Special" },
  lilyLyrics = { link = "Special" },
  lilyMarkup = { bold = true },
  lilyFunction = { link = "Statement" },
  lilyArticulation = { link = "PreProc" },
  lilyContext = { link = "Type" },
  lilyGrob = { link = "Include" },
  lilyTranslator = { link = "Type" },
  lilyPitch = { link = "Function" },
  lilyChord = { 
    ctermfg = "lightMagenta", 
    fg = "lightMagenta", 
    bold = true 
  },
}

local M = {}

M.setup = function(opts)
  opts = opts or {}
  nvls_options = vim.tbl_deep_extend('keep', opts, nvls_options or default)
  vim.g.nvls_language = nvls_options.lilypond.options.pitches_language
  M.syntax()
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
      if ctrl == "lilypond-book" then
        require('nvls.tex').lytexCmp()
      elseif ctrl == "fluidsynth" then
        vim.fn.execute('stopinsert')
        print(' ')
        require('nvls.lilypond').player(lilyAudioFile, nvls_file_name .. ".mp3")
      elseif ctrl == "tmpplayer" then
        vim.fn.execute('stopinsert')
        print(' ')
        require('nvls.lilypond').player(tmpOutDir .. '/tmp.mp3', "QuickPlayer")
      elseif ctrl == "lilypond" then
        if nvls_options.lilypond.options.diagnostics == true then
          M.showDiagnostics(lines,errorfm,ctrl)
        else
          vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
        end
        print(' ')
      else
          vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
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

function M.shellescape(file)
  file = file:gsub(" ","\\ ")
  file = file:gsub("%(","\\%(")
  file = file:gsub("%)","\\%)")
  return file
end

function M.syntax()
  local hi = default_hi
  if nvls_options and nvls_options.lilypond and nvls_options.lilypond.highlights then
    hi = vim.tbl_extend('keep', nvls_options.lilypond.highlights, default_hi)
  end
  for i, j in pairs(hi) do
    vim.api.nvim_set_hl(0, i, j)
  end
end

function M.viewer(file)
  local uname = io.popen("uname")
  local kernel = uname:read("*a")
  uname:close()
  if kernel ~= "Linux\n" and kernel ~= "Darwin" then
    print("[NVLS] Function not supported on your system")
  do return end
  end

  if kernel == "Darwin\n" then
    vim.fn.jobstart("open " .. file)
  else
    vim.fn.jobstart("xdg-open " .. file)
  end
end

function M.showDiagnostics(lines,errorfm,ctrl)
  local filtered_lines = {}
  local diagnostics = {}
  local ns = vim.api.nvim_create_namespace("lilypond-diagnostics")
  for _, line in pairs(lines) do
    local filename, row, col, message = string.match(line,'^([^%s].+):(%d+):(%d+): (.+)$')
    if filename then
      local bfnr = vim.fn.bufnr(vim.fn.expand(filename))
      message = string.gsub(message, '^error: ', '')
      table.insert(diagnostics, {
        severity = vim.diagnostic.severity.ERROR,
        message = message,
        lnum = tonumber(row) - 1,
        col = tonumber(col) -1,
      })
      vim.diagnostic.set(ns, bfnr, diagnostics, {})
    end
    if filename ~= vim.fn.expand("%:p") then
      table.insert(filtered_lines, line)
    end
  end

  vim.fn.setqflist({}, " ", {
    title = ctrl,
    lines = filtered_lines,
    efm = errorfm,
  })

  vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
end

return M
