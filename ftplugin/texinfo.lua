local Config = require('nvls.config')
local Utils = require('nvls.utils')

local opts = require('nvls').get_nvls_options().texinfo

vim.api.nvim_create_user_command('TexinfoCmp',  function()
  vim.fn.execute('write')
  local file = Config.fileInfos()
  Utils.message(string.format('Compiling %s...', Utils.shellescape(Utils.remove_path(file.main), false)))
  require('nvls.texinfo').SelectMakePrgType()
end, {})

vim.api.nvim_create_user_command('ToggleSyn', function()
  require('nvls.texinfo').ToggleLilypondSyntax()
end, {})

vim.api.nvim_create_autocmd(opts.options.lilypond_syntax_au, {
  callback = function() require('nvls.texinfo').DetectLilypondSyntax() end,
  group = vim.api.nvim_create_augroup(
    "DetectSyntax",
    { clear = true }
  ),
  pattern = { "*.texi", "*.texinfo" }
})

Utils.map(opts.mappings.lilypond_syntax, "<cmd>ToggleSyn<cr>")
Utils.map(opts.mappings.compile, "<cmd>TexinfoCmp<cr>")
Utils.map(opts.mappings.open_pdf, "<cmd>Viewer<cr>")

if opts.options.clean_logs or vim.g.nvls_clean_tex_files == 1 then
  vim.api.nvim_create_autocmd( 'VimLeave', {
    callback = function() Utils.clear_tmp_files() end,
    group = vim.api.nvim_create_augroup(
      "RemoveOutFiles",
      { clear = true }
    ),
    pattern = { "*.texi", "*.texinfo" }
  })
end

--local tex_include_dir = opts.options.include_dir or nil
--
--if tex_include_dir ~= "" and tex_include_dir ~= nil then
--  if type(tex_include_dir) == "table" then
--    tex_include_dir = table.concat(tex_include_dir, ":")
--  end
--  vim.cmd([[let $TEXINPUTS = $TEXINPUTS . ":]] .. tex_include_dir .. [["]])
--end

