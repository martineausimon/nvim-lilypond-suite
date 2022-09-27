local lilyPopup = require("nui.popup")

local lilyPlayer = lilyPopup({
  enter = true,
  focusable = true,
  border = {
    text = { top = "[" .. vim.g.nvls_short .. ".mp3]" },
    style = vim.g.nvls_options.player.options.border_style,
  },
    position = {
    row = vim.g.nvls_options.player.options.row,
    col = vim.g.nvls_options.player.options.col,
  },
  size = {
    width = vim.g.nvls_options.player.options.width,
    height = vim.g.nvls_options.player.options.height,
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

--lilyPlayer:map('n', '<Esc>', function() lilyPlayer:unmount() end, nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.player.mappings.quit,
  function() lilyPlayer:unmount() end, nrm)
lilyPlayer:map('t', 
  vim.g.nvls_options.player.mappings.quit,
  function() lilyPlayer:unmount() end, nrm)
lilyPlayer:map('t', 
  vim.g.nvls_options.lilypond.mappings.switch_buffers,
  "<cmd>stopinsert<cr><C-w>w",     nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.lilypond.mappings.switch_buffers,
  "<cmd>stopinsert<cr><C-w>w",     nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.player.mappings.backward,
  "i<Left><cmd>stopinsert<cr>",    nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.player.mappings.forward,
  "i<Right><cmd>stopinsert<cr>",   nrm)
lilyPlayer:map('n',
  vim.g.nvls_options.player.mappings.small_forward,
  "i<S-Right><cmd>stopinsert<cr>", nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.player.mappings.small_backward,
  "i<S-Left><cmd>stopinsert<cr>",  nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.player.mappings.play_pause,
  "ip<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.player.mappings.halve_speed,
  "i{<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.player.mappings.double_speed,
  "i}<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.player.mappings.decrease_speed,
  "i[<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.player.mappings.increase_speed,
  "i]<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', 
  vim.g.nvls_options.player.mappings.loop,
  "il<cmd>stopinsert<cr>",         nrm)
lilyPlayer:map('n', ':',         "",                              nrm)
