local M = {}

function M.parse_measures(filepath)
  local f = io.open(filepath, "rb")
  if not f then return {} end
  local content = f:read("*a")
  f:close()

  if content:sub(1, 4) ~= "MThd" then return {} end

  local tpqn = (content:byte(13) * 256) + content:byte(14)
  local num_tracks = (content:byte(11) * 256) + content:byte(12)

  local max_ticks = 0
  local tempo_events = {}
  local timesig_events = {}
  local bar_events = {}

  local p = 15
  for t = 1, num_tracks do
    if p > #content or content:sub(p, p + 3) ~= "MTrk" then break end
    local track_len = 0
    for i = 1, 4 do track_len = (track_len * 256) + content:byte(p + 3 + i) end

    local track_end = p + 8 + track_len
    local ptr = p + 8
    local abs_tick = 0
    local last_status = 0

    while ptr < track_end do
      local delta = 0
      repeat
        local b = content:byte(ptr)
        ptr = ptr + 1
        delta = (delta * 128) + bit.band(b, 0x7F)
      until b < 0x80
      abs_tick = abs_tick + delta

      local status = content:byte(ptr)
      if status >= 0x80 then ptr = ptr + 1 else status = last_status end
      last_status = status

      if status == 0xFF then
        local meta_type = content:byte(ptr)
        ptr = ptr + 1
        local len = content:byte(ptr)
        ptr = ptr + 1

        if meta_type == 0x51 and len == 3 then
          local mpqn = (content:byte(ptr) * 65536) + (content:byte(ptr+1) * 256) + content:byte(ptr+2)
          table.insert(tempo_events, { tick = abs_tick, mpqn = mpqn })
        elseif meta_type == 0x58 and len >= 2 then
          local num = content:byte(ptr)
          local den = 2 ^ content:byte(ptr+1)
          table.insert(timesig_events, { tick = abs_tick, num = num, den = den })
        elseif meta_type == 0x01 or meta_type == 0x03 or meta_type == 0x06 then
          local text = content:sub(ptr, ptr + len - 1)
          local bar_num = text:match("BAR:(%d+)")
          if bar_num then
            table.insert(bar_events, { tick = abs_tick, bar = tonumber(bar_num) })
          end
        end
        ptr = ptr + len
      else
        local len = (status >= 0xC0 and status <= 0xDF) and 1 or 2
        ptr = ptr + len
      end

      if abs_tick > max_ticks then max_ticks = abs_tick end
    end
    p = track_end
  end

  if max_ticks == 0 then return {} end

  table.sort(tempo_events, function(a, b) return a.tick < b.tick end)

  local function tick_to_seconds(target_tick)
    local t_sec = 0.0
    local last_tick = 0
    local temp_mpqn = 500000
    local t_idx = 1

    while last_tick < target_tick do
      local next_change = target_tick
      if t_idx <= #tempo_events and tempo_events[t_idx].tick < next_change then
        next_change = tempo_events[t_idx].tick
      end

      local d_ticks = next_change - last_tick
      t_sec = t_sec + (d_ticks / tpqn) * (temp_mpqn / 1000000)

      last_tick = next_change
      if t_idx <= #tempo_events and tempo_events[t_idx].tick == next_change then
        temp_mpqn = tempo_events[t_idx].mpqn
        t_idx = t_idx + 1
      end
    end
    return t_sec
  end

  local measures = {}

  if #bar_events > 0 then
    table.sort(bar_events, function(a, b) return a.tick < b.tick end)
    for _, ev in ipairs(bar_events) do
      if not measures[ev.bar] then
        measures[ev.bar] = tick_to_seconds(ev.tick)
      end
    end
    return measures
  end

  table.sort(timesig_events, function(a, b) return a.tick < b.tick end)
  local measure_ticks = {}
  local cur_tick = 0
  local timesig_idx = 1
  local cur_num, cur_den = 4, 4

  while cur_tick < max_ticks do
    while timesig_idx <= #timesig_events and timesig_events[timesig_idx].tick <= cur_tick do
      cur_num = timesig_events[timesig_idx].num
      cur_den = timesig_events[timesig_idx].den
      timesig_idx = timesig_idx + 1
    end

    table.insert(measure_ticks, cur_tick)
    local m_len = tpqn * 4 * (cur_num / cur_den)
    cur_tick = cur_tick + m_len
  end

  for i, m_tick in ipairs(measure_ticks) do
    measures[i] = tick_to_seconds(m_tick)
  end

  return measures
end

return M
