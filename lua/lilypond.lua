local M = {}

function M.lilyPlayer()
  if vim.fn.empty(vim.fn.glob("%:r.midi")) == 0 then
    print('Converting ' .. vim.fn.expand('%:r') .. '.midi to mp3...') 
    vim.b.nvls_cmd = "fluidsynth"
    vim.b.nvls_makeprg = 'rm -rf ' .. vim.g.lilyAudioFile .. ' && ' ..
      vim.b.nvls_cmd .. ' -T raw -F - ' .. vim.g.lilyMidiFile .. 
      ' -s | ffmpeg -f s32le -i - ' .. vim.g.lilyAudioFile
    vim.b.nvls_efm = " " 
    require('nvls').make()
  else
    if vim.fn.empty(vim.fn.glob("%:r.mp3")) > 0 then
      print("[LilyPlayer] No mp3 file in working directory")
      do return end
    else
      dofile(vim.b.lilyplay)
    end
  end
end

return M
