local lilyPopup = require("nui.popup")
local g = vim.g
local plopts = g.nvls_options.player.options

local lilyPlayer = lilyPopup({
  enter = true,
  focusable = true,
  border = {
    text = { top = "[" .. vim.g.nvls_short .. ".mp3]" },
    style = plopts.border_style,
  },
    position = {
    row = plopts.row,
    col = plopts.col,
  },
  size = {
    width = plopts.width,
    height = plopts.height,
  },
  buf_options = {
    modifiable = false,
    readonly = true,
  },
  win_options = {
    winhighlight = plopts.winhighlight,
  },
})

lilyPlayer:mount()

vim.api.nvim_buf_call(lilyPlayer.bufnr, function() 
  vim.fn.execute("term mpv --msg-level=cplayer=no,ffmpeg=no " ..
    "--loop --config-dir=/tmp/ " .. vim.g.lilyAudioFile)
end)

local M = {}

local nrm = { noremap = true }
local opt = g.nvls_options.player.mappings
local lyopt = g.nvls_options.lilypond.mappings

function M.map(key,cmd)
  lilyPlayer:map('n', key, cmd, nrm)
end

M.map(opt.quit,             function() lilyPlayer:unmount() end)
M.map(lyopt.switch_buffers, "<cmd>stopinsert<cr><C-w>w")
M.map(opt.backward,         "<cmd>stopinsert<cr>i<Left><cmd>stopinsert<cr>")
M.map(opt.forward,          "<cmd>stopinsert<cr>i<Right><cmd>stopinsert<cr>")
M.map(opt.small_forward,    "<cmd>stopinsert<cr>i<S-Right><cmd>stopinsert<cr>")
M.map(opt.small_backward,   "<cmd>stopinsert<cr>i<S-Left><cmd>stopinsert<cr>")
M.map(opt.play_pause,       "<cmd>stopinsert<cr>ip<cmd>stopinsert<cr>")
M.map(opt.halve_speed,      "<cmd>stopinsert<cr>i{<cmd>stopinsert<cr>")
M.map(opt.double_speed,     "<cmd>stopinsert<cr>i}<cmd>stopinsert<cr>")
M.map(opt.decrease_speed,   "<cmd>stopinsert<cr>i[<cmd>stopinsert<cr>")
M.map(opt.increase_speed,   "<cmd>stopinsert<cr>i]<cmd>stopinsert<cr>")
M.map(opt.loop,             "<cmd>stopinsert<cr>il<cmd>stopinsert<cr>")
M.map(':',                  "")
M.map('i',                  "")

return M
