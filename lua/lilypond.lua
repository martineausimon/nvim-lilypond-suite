local lilyMidiFile = vim.fn.shellescape(vim.fn.expand('%:p:r') .. '.midi')
local lilyAudioFile = vim.fn.shellescape(vim.fn.expand('%:p:r') .. '.mp3')
vim.g.lilyAudioFile = lilyAudioFile

local M = {}

function M.lilyPlayer()
	if vim.fn.empty(vim.fn.glob("%:r.midi")) == 0 then
		vim.fn.execute('!rm -rf ' .. lilyAudioFile .. ' && ' ..
			'fluidsynth -T raw -F - ' .. lilyMidiFile .. 
			' -s | ffmpeg -f s32le -i - ' .. lilyAudioFile
		)
		dofile(vim.b.lilyplay)
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
