local texMap      = vim.api.nvim_buf_set_keymap
local texHi       = vim.api.nvim_set_hl
local texCmd      = vim.api.nvim_create_user_command
local texAutoCmd  = vim.api.nvim_create_autocmd
local shellescape = vim.fn.shellescape
local expand      = vim.fn.expand
texPdf = shellescape(expand('%:p:r') .. '.pdf')
vim.b.tmpOutDir = expand('%:p:h') .. '/tmpOutDir/'

texCmd('Viewer', function() require('nvls').viewer(texPdf) end, {})

texCmd('LaTexCmp',  function() 
    vim.fn.execute('write')
    require('tex').SelectMakePrgType() 
  end,    
{})

texCmd('ToggleSyn', function() 
  require('tex').DetectLilypondSyntax() 
end, {})

texCmd('Cleaner', function() 
    vim.fn.execute('!rm -rf ' ..
      '%:r:S.log %:r:S.aux %r:S.out tmp-ly/ ' ..
      shellescape(vim.b.tmpOutDir))
end, {})

texAutoCmd("BufEnter", {
  callback = function() require('tex').DetectLilypondSyntax() end,
  group = vim.api.nvim_create_augroup(
    "DetectSyntax", 
    { clear = true }
  ),
  pattern = "*.tex"
})

texHi(0, 'Snip', { ctermfg = "white", fg = "white", bold = true })

if not vim.g.nvls_loaded_setup then
  require('nvls').setup()
end
