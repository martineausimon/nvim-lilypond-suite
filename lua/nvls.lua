local nvls_options

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
      backend = nil,
      main_file = "main.ly",
      main_folder = "%:p:h",
      include_dir = nil,
      pdf_viewer = nil,
      errors = {
        diagnostics = true,
        quickfix = "external",
        filtered_lines = {
          "compilation successfully completed",
          "search path"
        }
      },
    },
  },
  latex = {
    mappings = {
      compile = "<F5>",
      open_pdf = "<F6>",
      lilypond_syntax = "<F3>"
    },
    options = {
      lilypond_book_flags = nil,
      clean_logs = false,
      main_file = "main.tex",
      main_folder = "%:p:h",
      include_dir = nil,
      lilypond_syntax_au = "BufEnter",
      pdf_viewer = nil,
      errors = {
        diagnostics = true,
        quickfix = "external",
        filtered_lines = {
          "Missing character",
          "See the LaTeX manual or LaTeX Companion for explanation",
          "for immediate help.",
          "Overfull \\hbox",
          "^%s%.%.%.",
          "%s+%(.*%)"
        }
      },
    },
  },
  texinfo = {
    mappings = {
      compile = "<F5>",
      open_pdf = "<F6>",
      lilypond_syntax = "<F3>"
    },
    options = {
      lilypond_book_flags = "--pdf",
      clean_logs = false,
      main_file = "main.texi",
      main_folder = "%:p:h",
      include_dir = nil,
      lilypond_syntax_au = "BufEnter",
      pdf_viewer = nil,
      errors = {
        diagnostics = true,
        quickfix = "external",
        filtered_lines = {
          "Missing character",
          "See the LaTeX manual or LaTeX Companion for explanation",
          "for immediate help.",
          "Overfull \\hbox",
          "^%s%.%.%.",
          "%s+%(.*%)"
        }
      },
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
      row = 1,
      col = "99%",
      width = "37",
      height = "1",
      border_style = "single",
      winhighlight = "Normal:Normal,FloatBorder:Normal,FloatTitle:Normal",
      midi_synth = "fluidsynth",
      fluidsynth_flags = nil,
      timidity_flags = nil,
      ffmpeg_flags = nil,
      audio_format = "mp3",
      mpv_flags = {
        "--msg-level=cplayer=no,ffmpeg=no,alsa=no",
        "--loop",
        "--config-dir=/dev/null",
        "--no-video"
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

local tmp_folder = vim.fs.joinpath(vim.fn.stdpath("cache"), "nvls")

local M = {}

function M.setup(opts)
  opts = opts or {}
  nvls_options = vim.tbl_deep_extend('keep', opts, default)
  vim.g.nvls_language = nvls_options.lilypond.options.pitches_language
  M.syntax()
  vim.fn.mkdir(tmp_folder, 'p')
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

function M.get_nvls_options()
  return nvls_options or default
end

function M.get_file_infos()
  local opts = {
    player = nvls_options.player.options,
    tex = nvls_options.latex.options,
    texinfo = nvls_options.texinfo.options,
    lilypond = nvls_options.lilypond.options,
  }

  local audio_format = opts["player"].audio_format
  local midi_synth = opts["player"].midi_synth
  if midi_synth == "timidity" then
    audio_format = "wav"
  end

  local main_folder, main_file
  local current_filetype = vim.bo.filetype

  if opts[current_filetype] then
    main_folder = opts[current_filetype].main_folder
    main_file = opts[current_filetype].main_file
  end

  local main = vim.fn.expand('%:p')
  local main_path = vim.fs.joinpath(vim.fn.expand(main_folder), main_file)

  if vim.fn.filereadable(main_path) == 1 then
    main = main_path
  end

  local file = {
    name = vim.fn.fnamemodify(main, ":t:r"),
    pdf = require('nvls.utils').change_extension(main, "pdf"),
    audio = require('nvls.utils').change_extension(main, audio_format),
    audio_format = audio_format,
    midi = require('nvls.utils').change_extension(main, "midi"),
    midi_synth = midi_synth,
    main = main,
    folder = vim.fn.fnamemodify(main, ":h"),
    tmp = tmp_folder,
    output_fm = opts["lilypond"].output
  }

  return file
end

vim.api.nvim_create_user_command('Viewer', function()
  local file = M.get_file_infos()
  require('nvls.viewer').open(file.pdf, file.name .. ".pdf")
end, {})

M.debug = {}

vim.api.nvim_create_user_command("LilyDebug", function(opts)
  local target = opts.args

  local file = M.get_file_infos()
  local fileinfos = {
    ["main folder"] = file.folder,
    ["main file"] = file.main,
    ["output pdf file"] = file.pdf,
    ["tmp folder"] = file.tmp
  }
  if vim.bo.filetype == "lilypond" then
    fileinfos["audio file"] = file.audio
  end

  M.debug.fileinfos = vim.inspect(fileinfos)

  if M.debug[target] == nil then
    local available_targets = {}
    for k, _ in pairs(M.debug) do
      table.insert(available_targets, k)
    end
    require('nvls.utils').message("Unknown target, available targets: " .. table.concat(available_targets, ", "))
    return
  end

  vim.cmd("tabnew")
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(M.debug[target], "\n"))
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end, { nargs = 1 })

return M
