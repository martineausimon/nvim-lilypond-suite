local Utils = require('nvls.utils')
local Audio = require('nvls.audio')
local Mpv = require('nvls.mpv')
local Stack = require('nvls.stack')
local Marks = require('nvls.marks')
local Midi = require('nvls.midi')
local uv = vim.uv

local ns_id = vim.api.nvim_create_namespace("nvls_player_hl")

local players = {}

local old_guicursor = nil

local function hide_cursor()
  if vim.o.guicursor ~= "a:NvlsHiddenCursor" then
    old_guicursor = vim.o.guicursor
  end
  vim.o.guicursor = "a:NvlsHiddenCursor"
end

local function restore_cursor()
  if old_guicursor then
    vim.o.guicursor = old_guicursor
    old_guicursor = nil
  end
end

local function get_plopts()
  return require('nvls').get_nvls_options().player.options
end

local function format_time(seconds)
  if not seconds or seconds < 0 then seconds = 0 end
  local m = math.floor(seconds / 60)
  local s = math.floor(seconds % 60)
  return string.format("%02d:%02d", m, s)
end

local function shorten_name(name, win_width)
  local shortname = name:sub(9 - win_width)
  return shortname:len() < name:len() and "..." .. shortname or name
end

local function find_player(file_key)
  for _, p in ipairs(players) do
    if p.file_key == file_key then return p end
  end
  return nil
end

local function retitle(instance, name)
  if not name or not vim.api.nvim_win_is_valid(instance.win) then return end
  local cfg = vim.api.nvim_win_get_config(instance.win)
  cfg.title = '[' .. shorten_name(name, instance.win_width) .. ']'
  cfg.title_pos = 'center'
  vim.api.nvim_win_set_config(instance.win, cfg)
end

local function close_player(instance)
  if instance.closed then return end
  instance.closed = true

  for i, p in ipairs(players) do
    if p == instance then
      table.remove(players, i)
      break
    end
  end

  restore_cursor()

  if instance.buf and vim.api.nvim_buf_is_valid(instance.buf) then
    pcall(vim.api.nvim_del_augroup_by_name, "NvlsPlayerCursor_" .. instance.buf)
  end

  if instance.timer then
    instance.timer:stop()
    if not instance.timer:is_closing() then
      instance.timer:close()
    end
    instance.timer = nil
  end

  instance.mpv:quit()

  if instance.win and vim.api.nvim_win_is_valid(instance.win) then
    vim.api.nvim_win_close(instance.win, true)
  end

  Stack.relayout(players)
end

local M = {}

local function load_file(instance, file, name)
  instance.file_key = Marks.key_for(file)
  instance.marks = Marks.for_file(instance.file_key)

  local midi_file = Utils.change_extension(file, "midi")
  instance.measure_times = Midi.parse_measures(midi_file)

  instance.total_measures = 0
  for bar_num, _ in pairs(instance.measure_times) do
    if bar_num > instance.total_measures then
      instance.total_measures = bar_num
    end
  end

  retitle(instance, name)
  instance.mpv:play(file)
end

function M.convert()
  local file = require('nvls').get_file_infos()
  if vim.fn.filereadable(file.midi) == 1 then
    local midi_last = Utils.last_mod(file.midi)
    local audio_last = Utils.last_mod(file.audio)

    if (audio_last > midi_last) then
      M.load_or_open(file.audio, vim.fn.fnamemodify(file.audio, ":t"))
    else
      local old_audio = file.audio
      if type(old_audio) == "string" then
        os.remove(old_audio)
      end
      Audio.create(file.midi, file.audio_format, function(audio_out)
        M.load_or_open(audio_out, vim.fn.fnamemodify(audio_out, ":t"))
      end)
    end

  elseif vim.fn.filereadable(file.audio) == 1 then
    M.load_or_open(file.audio, vim.fn.fnamemodify(file.audio, ":t"))
  else
    Utils.message(string.format("Can't find %s.%s or %s.midi in working directory", file.name, file.audio_format, file.name), "ERROR")
  end
end

function M.refresh_if_open()
  local file = require('nvls').get_file_infos()
  local file_key = Marks.key_for(file.audio)
  if find_player(file_key) then
    M.convert()
  end
end

function M.load_or_open(file, name)
  local file_key = Marks.key_for(file)
  local existing = find_player(file_key)
  if existing then
    load_file(existing, file, name)
    return existing
  end
  return M.open(file, name)
end

function M.quickplayer()
  require('nvls.quickplayer').run()
  Utils.message("require('nvls.player').quickplayer() is depecated. Use require('nvls.quickplayer').run() instead.")
end

function M.open(file, name)
  local plopts = get_plopts()
  name = vim.fn.fnamemodify(file, ":t:r") == "tmp" and "Quickplayer" or (name or file)

  local win_width = Stack.num(plopts.width, 'x') or 46
  local win_height = math.max(Stack.num(plopts.height, 'y') or 2, 2)
  name = shorten_name(name, win_width)

  local border = plopts.border_style or "single"
  local base_row = Stack.num(plopts.row, 'y') or (vim.o.lines - win_height - 3)
  Stack.ensure_anchor(base_row)

  local has_top_border = border ~= "none" and border ~= "shadow"
  local next_row = Stack.get_next_row()
  -- Position de départ provisoire : Stack.relayout() la corrigera juste après.
  local row_pos = has_top_border and math.max(0, next_row - 1) or next_row
  local col_pos = Stack.num(plopts.col, 'x') or math.floor((vim.o.columns - win_width) / 2)

  local opts = {
    style = "minimal",
    relative = "editor",
    row = row_pos,
    col = col_pos,
    width = win_width,
    height = win_height,
    border = border,
    focusable = true,
    title = '[' .. name .. ']',
    title_pos = 'center',
    zindex = 100,
  }

  local winhl_active = plopts.winhighlight
  local winhl_inactive = plopts.winhighlight_inactive

  local instance = {
    win = nil,
    buf = vim.api.nvim_create_buf(false, true),
    timer = nil,
    mpv = Mpv.new(),
    win_height = win_height,
    win_width = win_width,
    col_pos = col_pos,
    has_top_border = has_top_border,
  }
  instance.win = vim.api.nvim_open_win(instance.buf, true, opts)
  table.insert(players, instance)
  Stack.relayout(players)

  local player_buf, player_win = instance.buf, instance.win

  vim.api.nvim_buf_set_option(player_buf, 'bufhidden', 'wipe')
  vim.api.nvim_win_set_option(player_win, 'winhighlight', winhl_active)

  local cursor_aug = vim.api.nvim_create_augroup("NvlsPlayerCursor_" .. player_buf, { clear = true })

  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = cursor_aug,
    buffer = player_buf,
    callback = hide_cursor,
  })

  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = cursor_aug,
    buffer = player_buf,
    callback = restore_cursor,
  })

  hide_cursor()

  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = cursor_aug,
    buffer = player_buf,
    callback = function()
      vim.api.nvim_win_set_option(player_win, 'winhighlight', winhl_active)
    end,
  })

  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = cursor_aug,
    buffer = player_buf,
    callback = function()
      if vim.api.nvim_win_is_valid(player_win) then
        vim.api.nvim_win_set_option(player_win, 'winhighlight', winhl_inactive)
      end
    end,
  })

  local status_msg = ""
  local status_timer_id = nil

  local function set_status(msg, timeout)
    status_msg = msg
    if status_timer_id then
      pcall(function()
        status_timer_id:stop()
        if not status_timer_id:is_closing() then
          status_timer_id:close()
        end
      end)
      status_timer_id = nil
    end

    if timeout and timeout > 0 then
      status_timer_id = vim.defer_fn(function()
        status_msg = ""
        status_timer_id = nil
      end, timeout)
    end
  end

  local nvls_options = require('nvls').get_nvls_options()
  local opt = nvls_options.player.mappings or {}
  local lyopt = nvls_options.lilypond.mappings or {}

  local function map(key, fn)
    if key and key ~= "" then
      if type(fn) == "string" then
        vim.keymap.set('n', key, fn, { buffer = player_buf, silent = true, noremap = true })
      else
        vim.keymap.set('n', key, fn, { buffer = player_buf, silent = true })
      end
    end
  end

  local function quit() close_player(instance) end

  map('<esc>', quit)
  map('q', quit)
  map(opt.quit, quit)

  map('p', function() instance.mpv:toggle_pause() end)
  map('<space>', function() instance.mpv:toggle_pause() end)
  map(opt.play_pause, function() instance.mpv:toggle_pause() end)

  local seek_step = plopts.seek_step or 5
  local seek_step_small = plopts.seek_step_small or 1
  local speed_step = plopts.speed_step or 0.1
  local speed_multiply = plopts.speed_multiply or 2.0

  map(opt.backward, function() instance.mpv:seek(-seek_step); set_status(string.format("seek -%ds", seek_step), 1000) end)
  map(opt.forward, function() instance.mpv:seek(seek_step); set_status(string.format("seek +%ds", seek_step), 1000) end)
  map(opt.small_backward, function() instance.mpv:seek(-seek_step_small); set_status(string.format("seek -%ds", seek_step_small), 1000) end)
  map(opt.small_forward, function() instance.mpv:seek(seek_step_small); set_status(string.format("seek +%ds", seek_step_small), 1000) end)

  map(opt.halve_speed, function() instance.mpv:send({"multiply", "speed", 1 / speed_multiply}) end)
  map(opt.double_speed, function() instance.mpv:send({"multiply", "speed", speed_multiply}) end)
  map(opt.decrease_speed, function() instance.mpv:send({"add", "speed", -speed_step}) end)
  map(opt.increase_speed, function() instance.mpv:send({"add", "speed", speed_step}) end)

  map(opt.loop, function()
    instance.mpv:send({"ab-loop"})
  end)
  map(lyopt.switch_buffers, "<cmd>wincmd w<cr>")

  local refresh_ui

  load_file(instance, file)

  local function jump_to_m(m_num)
    if instance.total_measures == 0 then
      set_status("mesures indisponibles", 2000)
      return
    end

    local target_m = math.max(1, math.min(m_num, instance.total_measures))
    local target_time = instance.measure_times[target_m]

    if target_time then
      instance.mpv:seek_absolute(target_time)
      set_status(string.format("go to bar %d", target_m), 2000)
    end
    refresh_ui()
  end

  map('G', function()
    local count = vim.v.count
    jump_to_m(count > 0 and count or instance.total_measures)
  end)

  map('gg', function()
    local count = vim.v.count
    jump_to_m(count > 0 and count or 1)
  end)

  map('m', function()
    set_status("set mark...")
    refresh_ui()

    local ch = vim.fn.getcharstr()
    if ch == "\27" or not ch:match("^%w$") then
      set_status("", 0)
    else
      instance.marks.set(ch, instance.mpv.state.time_pos)
      set_status(string.format("set mark [%s]", ch), 2000)
    end
    refresh_ui()
  end)

  map("'", function()
    set_status("jump to..." .. instance.marks.list())
    refresh_ui()

    local ch = vim.fn.getcharstr()
    if ch == "\27" then
      set_status("", 0)
    else
      local pos = instance.marks.get(ch)
      if pos then
        instance.mpv:seek_absolute(pos)
        set_status(string.format("jump to [%s]", ch), 2000)
      else
        set_status(string.format("no mark [%s]", ch), 2000)
      end
    end
    refresh_ui()
  end)

  map('dm', function()
    set_status("del mark..." .. instance.marks.list())
    refresh_ui()

    local ch = vim.fn.getcharstr()
    if ch == "\27" then
      set_status("", 0)
    elseif instance.marks.get(ch) then
      instance.marks.delete(ch)
      set_status(string.format("del mark [%s]", ch), 2000)
    else
      set_status(string.format("no mark [%s]", ch), 2000)
    end
    refresh_ui()
  end)

  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = player_buf,
    callback = function() close_player(instance) end,
    once = true,
  })

  refresh_ui = function()
    if not vim.api.nvim_buf_is_valid(player_buf) then return end

    local state = instance.mpv.state
    local duration = state.duration
    local time_pos = state.time_pos
    local percent = duration > 0 and (time_pos / duration) or 0

    local icon = state.pause and (plopts.icon_pause or "󰏤") or (plopts.icon_play or "󰐊")
    local bar_char = plopts.bar_char or "━"

    local current_m = 1
    for m, t in ipairs(instance.measure_times) do
      if time_pos >= t then current_m = m else break end
    end
    local total_m = instance.total_measures

    local prefix = string.format(" %s %s [%d] ", icon, format_time(time_pos), current_m)
    local suffix = string.format(" [%d] %s ", total_m, format_time(duration))

    local used_space = vim.fn.strdisplaywidth(prefix) + vim.fn.strdisplaywidth(suffix)
    local bar_width = math.max(1, win_width - used_space)
    local filled_len = math.floor(bar_width * percent + 0.5)

    local bar = bar_char:rep(bar_width)
    local line1 = prefix .. bar .. suffix

    local line2 = ""
    if status_msg and status_msg ~= "" then
      line2 = string.format(" %s", status_msg)
    else
      local speed = state.speed or 1.0
      local speed_str = string.format("speed: %gx", speed)

      local loop_str = ""
      local loop_a = state['ab-loop-a']
      if loop_a and loop_a ~= "no" then
        local loop_b = state['ab-loop-b']
        if loop_b and loop_b ~= "no" then
          loop_str = string.format(" | loop: %s - %s", format_time(tonumber(loop_a)), format_time(tonumber(loop_b)))
        else
          loop_str = string.format(" | loop: %s ...", format_time(tonumber(loop_a)))
        end
      end

      line2 = string.format(" %s%s", speed_str, loop_str)
    end

    vim.api.nvim_buf_set_option(player_buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(player_buf, 0, -1, false, { line1, line2 })
    vim.api.nvim_buf_set_option(player_buf, 'modifiable', false)

    vim.api.nvim_buf_clear_namespace(player_buf, ns_id, 0, -1)

    local start_col = #prefix
    local char_bytes = #bar_char
    local filled_bytes = filled_len * char_bytes
    local bar_bytes = bar_width * char_bytes

    if filled_len > 0 then
      vim.api.nvim_buf_add_highlight(player_buf, ns_id, 'Normal', 0, start_col, start_col + filled_bytes)
    end
    if filled_len < bar_width then
      vim.api.nvim_buf_add_highlight(player_buf, ns_id, 'NonText', 0, start_col + filled_bytes, start_col + bar_bytes)
    end

    vim.cmd("redraw")
  end

  instance.timer = uv.new_timer()
  instance.timer:start(0, plopts.refresh_interval_ms or 150, vim.schedule_wrap(refresh_ui))
end

return M
