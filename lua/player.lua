local lilyPopup = require("nui.popup")

local lilyPlayer = lilyPopup({
  enter = true,
  focusable = true,
  border = {
    text = { top = "[" .. vim.g.nvls_short .. ".mp3]" },
    style = "single",
  },
    position = {
    row = '2%',
    col = '99%',
  },
  size = {
    width = 37,
    height = 1,
  },
  buf_options = {
    modifiable = false,
    readonly = true,
  },
  win_options = {
    winhighlight = "Normal:Normal,FloatBorder:Normal",
  },
})

lilyPlayer:mount()

vim.api.nvim_buf_call(lilyPlayer.bufnr, function() 
  vim.fn.execute("term mpv --msg-level=cplayer=no,ffmpeg=no " ..
    "--loop --config-dir=/tmp/ " .. vim.g.lilyAudioFile)
end)

local nrm = { noremap = true }

lilyPlayer:map('n', '<Esc>', function() lilyPlayer:unmount() end, nrm)
lilyPlayer:map('n', 'q',     function() lilyPlayer:unmount() end, nrm)
lilyPlayer:map('t', 'q',     function() lilyPlayer:unmount() end, nrm)
lilyPlayer:map('t', '<A-Space>', "<cmd>stopinsert<cr><C-w>w",     nrm)
lilyPlayer:map('n', '<A-Space>', "<cmd>stopinsert<cr><C-w>w",     nrm)
lilyPlayer:map('n', 'h',         "i<Left><cmd>stopinsert<cr>",    nrm)
lilyPlayer:map('n', 'l',         "i<Right><cmd>stopinsert<cr>",   nrm)
lilyPlayer:map('n', '<S-l>',     "i<S-Right><cmd>stopinsert<cr>", nrm)
lilyPlayer:map('n', '<S-h>',     "i<S-Left><cmd>stopinsert<cr>",  nrm)
lilyPlayer:map('n', 'p',         "ip<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', '{',         "i{<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', '}',         "i}<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', 'j',         "i[<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', 'k',         "i]<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', '<A-l>',     "il<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', ']',         "i]<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', '[',         "i[<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', ':',         "",                              nrm)
