local texMap      = vim.api.nvim_buf_set_keymap
local texHi       = vim.api.nvim_set_hl
local texCmd      = vim.api.nvim_create_user_command
local texAutoCmd  = vim.api.nvim_create_autocmd
local shellescape = vim.fn.shellescape
local expand      = vim.fn.expand
vim.b.nvls_pdf    = shellescape(expand('%:p:r') .. '.pdf')
vim.b.tmpOutDir = expand('%:p:h') .. '/tmpOutDir/'

texCmd('Viewer', function() require('nvls').viewer() end, {})

texCmd('LaTexCmp',  function() 
    vim.fn.execute('write')
    require('tex').SelectMakePrgType() 
  end,    
{})

texCmd('ToggleSyn', function() 
  require('tex').DetectLilypondSyntax() 
end, {})

texAutoCmd("BufEnter", {
  callback = function() require('tex').DetectLilypondSyntax() end,
  group = vim.api.nvim_create_augroup(
    "DetectSyntax", 
    { clear = true }
  ),
  pattern = "*.tex"
})

texAutoCmd( 'VimLeave', {
  callback = function() 
    if vim.g.nvls_clean_tex_files == 1 then
      vim.fn.execute('!rm -rf ' ..
        '%:r:S.log %:r:S.aux %r:S.out tmp-ly/ ' ..
        shellescape(vim.b.tmpOutDir))
    else
      return
    end
  end,
  group = vim.api.nvim_create_augroup(
    "RemoveOutFiles", 
    { clear = true }
  ),
  pattern = '*.tex'
})

texHi(0, 'Snip', { ctermfg = "white", fg = "white", bold = true })

texMap(0, 'n', '<F3>', ":ToggleSyn<cr>", {noremap = true})
texMap(0, 'n', '<F5>', ":LaTexCmp<cr>",  {noremap = true})
texMap(0, 'n', '<F6>', ":Viewer<cr>",    {noremap = true})
