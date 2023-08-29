local Config = require('nvls.config')
local Utils = require('nvls.utils')
local Viewer = require('nvls.viewer')
local map = Utils.map

local nvls_options = require('nvls').get_nvls_options()

vim.api.nvim_create_user_command('Viewer', function()
  tex = Config.fileInfos("tex")
  Viewer.open(tex.pdf, tex.name .. ".pdf")
end, {})

vim.api.nvim_create_user_command('LaTexCmp',  function()
  vim.fn.execute('write')
  tex = Config.fileInfos("tex")
  Utils.message(string.format('Compiling %s.tex...', tex.name))
  require('nvls.tex').SelectMakePrgType()
end, {})

vim.api.nvim_create_user_command('ToggleSyn', function()
  require('nvls.tex').ToggleLilypondSyntax()
end, {})

local acmd = nvls_options.latex.options.lilypond_syntax_au

vim.api.nvim_create_autocmd(acmd, {
  callback = function() require('nvls.tex').DetectLilypondSyntax() end,
  group = vim.api.nvim_create_augroup(
    "DetectSyntax",
    { clear = true }
  ),
  pattern = "*.tex"
})

local cmp = nvls_options.latex.mappings.compile
local view = nvls_options.latex.mappings.open_pdf
local lysyn = nvls_options.latex.mappings.lilypond_syntax
local clean = nvls_options.latex.options.clean_logs
map(lysyn, "<cmd>ToggleSyn<cr>")
map(cmp,   "<cmd>LaTexCmp<cr>")
map(view,  "<cmd>Viewer<cr>")
if clean or vim.g.nvls_clean_tex_files == 1 then
  vim.api.nvim_create_autocmd( 'VimLeave', {
    callback = function() Utils.clear_tmp_files("tex") end,
    group = vim.api.nvim_create_augroup(
      "RemoveOutFiles",
      { clear = true }
    ),
    pattern = '*.tex'
  })
end

local tex_include_dir = nvls_options.latex.options.include_dir or nil

if tex_include_dir ~= "" and tex_include_dir ~= nil then
  if type(tex_include_dir) == "table" then
    tex_include_dir = table.concat(tex_include_dir, ":")
  end
  vim.cmd([[let $TEXINPUTS = $TEXINPUTS . ":]] .. tex_include_dir .. [["]])
end
