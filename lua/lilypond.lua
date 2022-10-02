local g, b, fn = vim.g, vim.b, vim.fn
local expand = fn.expand
local main_file = g.nvls_options.lilypond.options.main_file
local main_folder = g.nvls_options.lilypond.options.main_folder

local M = {}

function M.lilyPlayer()
  if fn.empty(
    fn.glob(expand(main_folder) 
    .. '/' .. g.nvls_short .. '.midi')) == 0 then
    print('Converting ' .. g.nvls_short .. '.midi to mp3...') 
    b.nvls_cmd = "fluidsynth"
    local fluidsynth = 'rm -rf ' .. g.lilyAudioFile .. ' && ' ..
      b.nvls_cmd .. ' -T raw -F - ' .. g.lilyMidiFile .. 
      ' -s | ffmpeg -f s32le -i - ' .. g.lilyAudioFile
    local fluidsynthEfm = " " 
    require('nvls').make(fluidsynth,fluidsynthEfm)
  elseif fn.empty(
    fn.glob(expand(main_folder) 
      .. '/' .. g.nvls_short .. '.mp3')) > 0 then
    print("[LilyPlayer] No mp3 file in working directory")
    do return end
  else
    dofile(b.lilyplay)
  end
end

function M.DefineLilyVars()
  g.nvls_main = expand('%:p:S')

  if fn.empty(fn.glob(main_folder .. '/.lilyrc')) == 0 then
    dofile(expand(main_folder) .. '/.lilyrc')
    g.nvls_main = "'" .. expand(main_folder) .. "/" .. 
    main_file .. "'"

  elseif fn.empty(fn.glob(expand(main_folder) .. '/' .. 
    main_file)) == 0 then
      g.nvls_main = "'" .. expand(main_folder) .. "/" .. 
      main_file .. "'"
  end

  local name,out = g.nvls_main:gsub("%.(ly')", "'")
  if out == 0 then
    name,out = g.nvls_main:gsub("%.(ily')", "'")
  end
  g.nvls_main_name = name
  g.nvls_short = g.nvls_main_name:match('/([^/]+)$'):gsub("'", "")
  g.lilyMidiFile = expand(
    "'" .. g.nvls_main_name:gsub("'", "") .. ".midi'")
  g.lilyAudioFile = expand(
    "'" .. g.nvls_main_name:gsub("'", "") .. ".mp3'")
  b.nvls_cmd = "lilypond"
end

return M
