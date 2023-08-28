local texMap      = vim.api.nvim_buf_set_keymap
local texHi       = vim.api.nvim_set_hl
local texCmd      = vim.api.nvim_create_user_command
local texAutoCmd  = vim.api.nvim_create_autocmd
local g, fn       = vim.g, vim.fn
local Config = require('nvls.config')
local Utils = require('nvls.utils')
local Viewer = require('nvls.viewer')

local nvls_options = require('nvls').get_nvls_options()

texCmd('Viewer', function()
  tex = Config.fileInfos("tex")
  Viewer.open(tex.pdf, tex.name .. ".pdf")
end, {})

texCmd('LaTexCmp',  function()
  fn.execute('write')
  tex = Config.fileInfos("tex")
  Utils.message(string.format('Compiling %s.tex...', tex.name))
  require('nvls.tex').SelectMakePrgType()
end, {})

texCmd('ToggleSyn', function()
  require('nvls.tex').ToggleLilypondSyntax()
end, {})

local acmd = nvls_options.latex.options.lilypond_syntax_au

texAutoCmd(acmd, {
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
texMap(0, 'n', lysyn, "<cmd>ToggleSyn<cr>", {noremap = true})
texMap(0, 'n', cmp,   "<cmd>LaTexCmp<cr>",  {noremap = true})
texMap(0, 'n', view,  "<cmd>Viewer<cr>",    {noremap = true})
if clean or g.nvls_clean_tex_files == 1 then
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
