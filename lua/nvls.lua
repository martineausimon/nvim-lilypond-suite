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
      pitch_languages = "default"
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
}

local key = vim.api.nvim_buf_set_keymap

local M = {}

M.setup = function(opts)

	opts = opts or {}
	M.opts = vim.tbl_deep_extend('keep', opts, default)

	vim.g.nvls_loaded_setup = true

	if vim.fn.expand('%:e') == "tex" then
	  local cmp = M.opts.latex.mappings.compile
	  local view = M.opts.latex.mappings.open_pdf
    local lysyn = M.opts.latex.mappings.lilypond_syntax
    local clean = M.opts.latex.options.clean_logs
    key(0, 'n', lysyn, ":ToggleSyn<cr>", {noremap = true})
    key(0, 'n', cmp,   ":LaTexCmp<cr>",  {noremap = true})
    key(0, 'n', view,  ":Viewer<cr>",    {noremap = true})
    if clean or vim.g.nvls_clean_tex_files == 1 then
      vim.api.nvim_create_autocmd( 'VimLeave', {
        command = 'Cleaner',
        group = vim.api.nvim_create_augroup(
          "RemoveOutFiles", 
          { clear = true }
        ),
        pattern = '*.tex'
      })
    end
  elseif vim.fn.expand('%:e') == "ly" then
	  local cmp = M.opts.lilypond.mappings.compile
	  local view = M.opts.lilypond.mappings.open_pdf
    local switch = M.opts.lilypond.mappings.switch_buffers
    local version = M.opts.lilypond.mappings.insert_version
    local play = M.opts.lilypond.mappings.player
    key(0, 'n', cmp,    ":LilyCmp<cr>",       {noremap = true})
    key(0, 'i', cmp,    "<esc>:LilyCmp<cr>a", {noremap = true})
    key(0, 'n', view,   ":Viewer<cr>",        {noremap = true})
    key(0, 'n', switch, "<C-w>w",             {noremap = true})
    key(0, 'i', switch, "<esc><C-w>w",        {noremap = true})
    key(0, 'n', play,   ":LilyPlayer<cr>",    {noremap = true})
    key(0, 'n', version,
      [[0O\version<space>]] .. 
      [[<Esc>:read<Space>!lilypond<Space>-v]] ..
      [[<Bar>grep<Space>LilyPond<Bar>cut<Space>-c<Space>14-20<cr>]] ..
      [[kJi"<esc>6la"<esc>]],
      {noremap = true, silent = true}
    )
    local lang = M.opts.lilypond.options.pitch_languages
    vim.g.nvls_language = lang
  end
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
