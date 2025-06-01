local M = {}

local function count_blocks(line)
  local opens, closes = 0, 0
  for _ in line:gmatch("<<") do opens = opens + 1 end
  for _ in line:gmatch(">>") do closes = closes + 1 end
  for _ in line:gmatch("{") do opens = opens + 1 end
  for _ in line:gmatch("}") do closes = closes + 1 end
  return opens, closes
end

local function is_comment_or_blank(line)
  local stripped = line:match("^%s*(.-)%s*$")
  return stripped == "" or stripped:match("^%%")
end

local function is_scheme_block(line, prevline)
  return line:match("#'%s*%(") or (prevline and prevline:match("#'%s*%($"))
end

function M.lilypond()
  local sw = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or 2
  local curr = vim.fn.line('.')
  local indent_level = 0

  for i = 1, curr - 1 do
    local line = vim.fn.getline(i)
    if not is_comment_or_blank(line) then
      local opens, closes = count_blocks(line)
      indent_level = indent_level + opens - closes
      if indent_level < 0 then indent_level = 0 end
    end
  end

  local indent = indent_level * sw

  local curr_line = vim.fn.getline(curr)
  local prev_line = vim.fn.getline(curr-1)
  if not is_comment_or_blank(curr_line) then
    local opens, closes = count_blocks(curr_line)
    if closes > opens then
      indent = indent - sw * (closes - opens)
    end
    if indent < 0 then indent = 0 end
  end

  if is_scheme_block(curr_line, prev_line) then
    indent = vim.fn.lispindent(curr)
  else

    local lnum = vim.fn.prevnonblank(curr - 1)
    for _, id in ipairs(vim.fn.synstack(lnum, 1)) do
      local name = vim.fn.synIDattr(id, "name")
      if name:match("^scheme") or name == "lilyScheme" then
        indent = vim.fn.lispindent(curr)
        break
      end
    end
  end

  return indent
end

return M
