local Utils = require('nvls.utils')
local Job = require('nvls.job')
local opts = require('nvls').get_nvls_options().latex
local file = require('nvls').get_file_infos()

local lilypond_opts = require('nvls').get_nvls_options().lilypond

local M = {}

function M.ToggleLilypondSyntax()
  if vim.g.lytexiSyn == 1 then
    vim.g.lytexiSyn = 0
    vim.cmd('set syntax=texinfo')
  else
  M.DetectLilypondSyntax()
  end
end

function M.DetectLilypondSyntax()
  --TODO
  if Utils.has(file.main, "@lilypond") then
    vim.b.current_syntax = nil
    vim.cmd('syntax include @lilypond syntax/lilypond.vim')
    vim.cmd([[ 
      syntax region texinfoControlSequence
      \ start="@lilypond\s\{}\(\[.\{-}\]\)\{}\n" 
      \ end="@end\s\+lilypond"
      \ contains=litexiOpts,@lilypond,@lilyMatchGroup
      \ keepend
    ]])
    vim.cmd([[
      syn region litexiOpts
      \ matchgroup=Delimiter
      \ start="\["
      \ end="\]\(\n\|\s\)\{}"
      \ contained
      \ contains=@NoSpell
      ]])
    vim.g.lytexiSyn = 1
  end
end

local function compile_lilypond_book()

  local lilypondbook_args = {
    "--output=" .. file.tmp,
    '--pdf',
    file.main
  }

  local texinfo_args = {
    "--output=" .. Utils.change_extension(file.main, "pdf"),
    vim.fs.joinpath(file.tmp, file.name .. ".texi")
  }

  local backend = lilypond_opts.options.backend

  local include_args = Utils.format_include_dirs(lilypond_opts.options.include_dir)
  for _, arg in ipairs(include_args) do
    table.insert(lilypondbook_args, 1, "-I")
    table.insert(lilypondbook_args, 2, arg)
  end

  if backend then
    local dbackend = string.format("--process=lilypond -dbackend=%s", backend)
    table.insert(lilypondbook_args, 1, dbackend)
  end

  local lb_flags = opts.options.lb_flags

  if type(lb_flags) == "table" then
    for _, flag in ipairs(lb_flags) do
      table.insert(flag, 1)
    end
  elseif lb_flags and lb_flags ~= '' then
    table.insert(lilypondbook_args, lb_flags)
  end

  Job:check_and_clean_tmp()
  Job:add("lilypond-book", lilypondbook_args)
  Job:add("texi2pdf", texinfo_args, file.tmp)
end

local function compile_texinfo()
  local texinfo_args = {
    "--output=" .. Utils.change_extension(file.main, "pdf"),
    file.main
  }

  Job:add("texi2pdf", texinfo_args)
end

function M.SelectMakePrgType()
  if Utils.has(file.main, "@lilypond") then
    compile_lilypond_book()
  else
    compile_texinfo()
  end
end

return M

