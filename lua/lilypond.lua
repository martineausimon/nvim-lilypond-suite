local g = vim.g
local b = vim.b

local M = {}

function M.lilyPlayer()
  if vim.fn.empty(
    vim.fn.glob(vim.fn.expand('%:p:h') 
    .. '/' .. g.nvls_short .. '.midi')) == 0 then
    print('Converting ' .. vim.g.nvls_short .. '.midi to mp3...') 
    b.nvls_cmd = "fluidsynth"
    b.nvls_makeprg = 'rm -rf ' .. g.lilyAudioFile .. ' && ' ..
      b.nvls_cmd .. ' -T raw -F - ' .. g.lilyMidiFile .. 
      ' -s | ffmpeg -f s32le -i - ' .. g.lilyAudioFile
    b.nvls_efm = " " 
    require('nvls').make()
  else
    if vim.fn.empty(
      vim.fn.glob(vim.fn.expand('%:p:h') 
        .. '/' .. g.nvls_short .. '.mp3')) > 0 then
      print("[LilyPlayer] No mp3 file in working directory")
      do return end
    else
      dofile(vim.b.lilyplay)
    end
  end
end

function M.DefineMainFile()
  local expand = vim.fn.expand

  if vim.fn.empty(vim.fn.glob('%:p:h' .. '/.lilyrc')) == 0 then
    dofile(expand('%:p:h') .. '/.lilyrc')
    if not g.nvls_main then 
      print('error in .lilyrc')
    end
    g.nvls_main = "'" .. g.nvls_main .. "'"
  else
    if vim.fn.empty(vim.fn.glob(expand('%:p:h') .. '/main.ly')) == 0 then
      g.nvls_main = "'" .. expand('%:p:h') .. "/main.ly'"
    else
      g.nvls_main = expand('%:p:S')
    end
  end

  local name,out = g.nvls_main:gsub("%.(ly')", "'")
  if out == 0 then
    name,out = g.nvls_main:gsub("%.(ily')", "'")
  end
  g.nvls_main_name = name
  g.nvls_short = g.nvls_main_name:match('/([^/]+)$'):gsub("'", "")

end

return M
