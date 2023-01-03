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
      del_selected_hyphen = "<leader>dh"
    },
    options = {
      pitches_language = "default",
      hyphenation_language = "en_DEFAULT",
      output = "pdf",
      main_file = "main.ly",
      main_folder = "%:p:h",
      include_dir = "$HOME"
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
      winhighlight = "Normal:Normal,FloatBorder:Normal",
      mpv_flags = {
        "--msg-level=cplayer=no,ffmpeg=no",
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
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
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
  vim.fn.jobstart('xdg-open ' .. file)
end

return M
