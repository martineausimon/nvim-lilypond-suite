local M = {}

local stack_next_row = nil
local stack_dir = 1

function M.num(value, axis)
  if not value then return nil end
  local factor = axis == "y" and vim.fn.winheight(0) or vim.fn.winwidth(0)
  local n = tonumber(value)
  if n then
    return math.floor(n + 0.5)
  elseif type(value) == "string" then
    local percentage = tonumber(value:match("(%d+%.?%d*)%%"))
    if percentage then
      local v = percentage / 100
      if v >= 0 and v <= 1 then
        return math.floor((v * factor) + 0.5)
      end
    end
  end
  return nil
end

function M.get_next_row()
  return stack_next_row
end

function M.ensure_anchor(base_row)
  if stack_next_row == nil then
    stack_next_row = base_row
    stack_dir = (base_row > vim.o.lines / 2) and -1 or 1
  end
end

function M.relayout(players)
  if #players == 0 then
    stack_next_row = nil
    return
  end

  local row_cursor = stack_next_row
  for _, p in ipairs(players) do
    local row_pos = p.has_top_border and math.max(0, row_cursor - 1) or row_cursor
    if p.win and vim.api.nvim_win_is_valid(p.win) then
      vim.api.nvim_win_set_config(p.win, {
        relative = "editor",
        row = row_pos,
        col = p.col_pos,
        width = p.win_width,
        height = p.win_height,
      })
    end
    row_cursor = row_cursor + stack_dir * (p.win_height + 2)
  end
end

return M
