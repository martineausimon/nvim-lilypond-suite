local lilyPopup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local key = vim.api.nvim_buf_set_keymap

local lilyPlayer = lilyPopup({
  enter = true,
  focusable = true,
  border = {
    style = "single",
  },
    position = {
    row = '2%',
    col = '99%',
  },
  size = {
    width = 36,
    height = 4,
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

lilyPlayer:on({ event.BufWinLeave }, function()
  vim.schedule(function()
      popup:unmount()
    end)
end)

vim.api.nvim_buf_call(lilyPlayer.bufnr, function() 
  vim.fn.execute("term mpv --loop --config-dir=/tmp/ " .. 
    vim.g.lilyAudioFile
  )
end)

key(lilyPlayer.bufnr, 'n', 'q',
  "<cmd>bw!<cr>", {noremap = true})
key(lilyPlayer.bufnr, 't', 'q',
  "<cmd>bw!<cr>", {noremap = true})
key(lilyPlayer.bufnr, 't', '<A-Space>',
  "<cmd>stopinsert<cr><C-w>w", {noremap = true})
key(lilyPlayer.bufnr, 'n', '<A-Space>',
  "<C-w>w", {noremap = true})
key(lilyPlayer.bufnr, 't', '<Esc>',
  "<cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', 'h',
  "i<Left><cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', 'l',
  "i<Right><cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', '<S-l>',
  "i<S-Right><cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', '<S-h>',
  "i<S-Left><cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', 'p',
  "ip<cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', '{',
  "i{<cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', '}',
  "i}<cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', 'j',
  "i[<cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', 'k',
  "i]<cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', '<A-l>',
  "il<cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', ']',
  "i]<cmd>stopinsert<cr>", {noremap = true})
key(lilyPlayer.bufnr, 'n', '[',
  "i[<cmd>stopinsert<cr>", {noremap = true})
