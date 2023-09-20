local Config = require('nvls.config')
local Utils = require('nvls.utils')
local Viewer = require('nvls.viewer')

local opts = require('nvls').get_nvls_options().latex

vim.api.nvim_create_user_command('Viewer', function()
  local tex = Config.fileInfos("tex")
  Viewer.open(tex.pdf, tex.name .. ".pdf")
end, {})

vim.api.nvim_create_user_command('LaTexCmp',  function()
  vim.fn.execute('write')
  local tex = Config.fileInfos("tex")
  Utils.message(string.format('Compiling %s.tex...', tex.name))
  require('nvls.tex').SelectMakePrgType()
end, {})

vim.api.nvim_create_user_command('ToggleSyn', function()
  require('nvls.tex').ToggleLilypondSyntax()
end, {})

vim.api.nvim_create_autocmd(opts.options.lilypond_syntax_au, {
  callback = function() require('nvls.tex').DetectLilypondSyntax() end,
  group = vim.api.nvim_create_augroup(
    "DetectSyntax",
    { clear = true }
  ),
  pattern = "*.tex"
})

Utils.map(opts.mappings.lilypond_syntax, "<cmd>ToggleSyn<cr>")
Utils.map(opts.mappings.compile, "<cmd>LaTexCmp<cr>")
Utils.map(opts.mappings.open_pdf, "<cmd>Viewer<cr>")

if opts.options.clean_logs or vim.g.nvls_clean_tex_files == 1 then
  vim.api.nvim_create_autocmd( 'VimLeave', {
    callback = function() Utils.clear_tmp_files("tex") end,
    group = vim.api.nvim_create_augroup(
      "RemoveOutFiles",
      { clear = true }
    ),
    pattern = '*.tex'
  })
end

local tex_include_dir = opts.options.include_dir or nil

if tex_include_dir ~= "" and tex_include_dir ~= nil then
  if type(tex_include_dir) == "table" then
    tex_include_dir = table.concat(tex_include_dir, ":")
  end
  vim.cmd([[let $TEXINPUTS = $TEXINPUTS . ":]] .. tex_include_dir .. [["]])
end
