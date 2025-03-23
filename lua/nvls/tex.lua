local Utils = require('nvls.utils')
local Job = require('nvls.job')
local opts = require('nvls').get_nvls_options().latex
local file = require('nvls').get_file_infos()

local lilypond_opts = require('nvls').get_nvls_options().lilypond

local M = {}

function M.ToggleLilypondSyntax()
  if vim.g.lytexSyn == 1 then
    vim.g.lytexSyn = 0
    vim.cmd('set syntax=tex')
  else
  M.DetectLilypondSyntax()
  end
end

function M.DetectLilypondSyntax()
  if Utils.has(file.main, "\\begin{lilypond}") or Utils.has(file.main, "\\lilypond") then
    vim.b.current_syntax = nil
    vim.cmd('syntax include @lilypond syntax/lilypond.vim')
    vim.cmd([[
      syn match litexCmd "\\lilypond\>\(\s\|\n\)\{}"
      \ nextgroup=litexOpts,litexReg
      \ transparent
      hi def link litexCmd texStatement
    ]])
    vim.cmd([[
      syn match texInputFile "\\lilypondfile\=\(\[.\{-}\]\)\=\s*{.\{-}}"
      \ contains=texStatement,texInputCurlies,texInputFileOpt
    ]])
    vim.cmd([[
      syn region litexOpts
      \ matchgroup=texDelimiter
      \ start="\["
      \ end="\]\(\n\|\s\)\{}"
      \ contained
      \ contains=texComment,@texMathZones,@NoSpell
      \ nextgroup=litexReg
      ]])
    vim.cmd([[
      syntax region litexReg
      \ matchgroup=Delimiter
      \ start="{"
      \ end="}" 
      \ contained
      \ contains=@lilypond,@lilyMatchGroup
    ]])
    vim.cmd([[ 
      syntax region litexReg
      \ start="\\begin{lilypond}" 
      \ end="\\end{lilypond}" 
      \ contains=litexOpts,@lilypond,@lilyMatchGroup
      \ keepend
    ]])
    vim.g.lytexSyn = 1
  end
end

local function compile_lilypond_book()

  local lilypondbook_args = {
    "--output=" .. file.tmp,
    '--pdf',
    file.main
  }

  local lualatex_args = {
    "--file-line-error",
    "--output-directory=" .. file.folder,
    "--shell-escape",
    "--interaction=nonstopmode",
    vim.fs.joinpath(file.tmp, file.name .. ".tex")
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
  Job:add("lualatex", lualatex_args, file.tmp)
end

local function compile_lualatex()
  local lualatex_args = {
    "--file-line-error",
    string.format("--output-directory=%s", file.folder),
    "--shell-escape",
    "--interaction=nonstopmode",
    file.main
  }

  Job:add("lualatex", lualatex_args)
end

function M.SelectMakePrgType()
  if (Utils.has(file.main, "\\begin{lilypond}") or Utils.has(file.main, "\\lilypond")) and not Utils.has(file.main, "\\usepackage{lyluatex}") then
    compile_lilypond_book()
  else
    compile_lualatex()
  end
end

return M
