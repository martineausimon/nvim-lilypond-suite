if vim.g.do_filetype_lua == 1 then
  vim.filetype.add({
    extension = {
      ly = 'lilypond',
      ily = 'lilypond',
    },
  })
  vim.filetype.add({
    pattern = { ['.lilyrc'] = 'lua' }
  })
  else
  vim.api.nvim_create_autocmd(
    { 'BufNewFile', 'BufRead' },
    {
      command = 'set ft=lilypond',
      pattern = { '*.ly', '*.ily' },
      group =  vim.api.nvim_create_augroup(
        'lilyFtdetect', { clear = true})
  })
  vim.api.nvim_create_autocmd(
    { 'BufNewFile', 'BufRead' },
    {
      command = 'set ft=lua',
      pattern = { '.lilyrc' },
      group =  vim.api.nvim_create_augroup(
        'lilyrcFtdetect', { clear = true})
  })
end
