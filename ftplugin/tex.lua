local texMap      = vim.api.nvim_buf_set_keymap
local texHi       = vim.api.nvim_set_hl
local texCmd      = vim.api.nvim_create_user_command
local texAutoCmd  = vim.api.nvim_create_autocmd
local shellescape = vim.fn.shellescape
local expand      = vim.fn.expand
local g, b, fn    = vim.g, vim.b, vim.fn
texPdf = shellescape(expand('%:p:r') .. '.pdf')
tmpOutDir = expand('%:p:h') .. '/tmpOutDir/'

texCmd('Viewer', function() require('nvls').viewer(texPdf) end, {})

texCmd('LaTexCmp',  function() 
    fn.execute('write')
    require('nvls.tex').SelectMakePrgType() 
  end,    
{})

texCmd('ToggleSyn', function() 
  require('nvls.tex').DetectLilypondSyntax() 
end, {})

texCmd('Cleaner', function() 
    fn.execute('!rm -rf ' ..
      '%:r:S.log %:r:S.aux %r:S.out tmp-ly/ ' ..
      shellescape(tmpOutDir))
end, {})

texAutoCmd("BufEnter", {
  callback = function() require('nvls.tex').DetectLilypondSyntax() end,
  group = vim.api.nvim_create_augroup(
    "DetectSyntax", 
    { clear = true }
  ),
  pattern = "*.tex"
})

texHi(0, 'Snip', { ctermfg = "white", fg = "white", bold = true })

if not nvls_options then
  require('nvls').setup()
end

local cmp = nvls_options.latex.mappings.compile
local view = nvls_options.latex.mappings.open_pdf
local lysyn = nvls_options.latex.mappings.lilypond_syntax
local clean = nvls_options.latex.options.clean_logs
texMap(0, 'n', lysyn, ":ToggleSyn<cr>", {noremap = true})
texMap(0, 'n', cmp,   ":LaTexCmp<cr>",  {noremap = true})
texMap(0, 'n', view,  ":Viewer<cr>",    {noremap = true})
if clean or g.nvls_clean_tex_files == 1 then
  vim.api.nvim_create_autocmd( 'VimLeave', {
    command = 'Cleaner',
    group = vim.api.nvim_create_augroup(
      "RemoveOutFiles", 
      { clear = true }
    ),
    pattern = '*.tex'
  })
end

