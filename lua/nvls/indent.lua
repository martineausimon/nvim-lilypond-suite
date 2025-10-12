local M = {}

local lilyInScheme_decay = 0

local function contains(tbl, val)
  for _, v in ipairs(tbl) do
    if v == val then return true end
  end
  return false
end

local function is_comment_or_blank(line)
  return line:match("^%s*$") or line:match("^%s*%%")
end

local function count_blocks(line)
  local opens, closes = 0, 0
  opens = opens + select(2, line:gsub("<<", ""))
  closes = closes + select(2, line:gsub(">>", ""))
  opens = opens + select(2, line:gsub("{", ""))
  closes = closes + select(2, line:gsub("}", ""))
  return opens, closes
end

local function count_lilyInScheme_blocks(line)
  local opens, closes = 0, 0
  opens = opens + select(2, line:gsub("#{", ""))
  closes = closes + select(2, line:gsub("#}", ""))
  return opens, closes
end

local function calculate_indent_level(curr)
  local indent_level = 0

  for i = 1, curr - 1 do
    local line = vim.fn.getline(i)
    if not is_comment_or_blank(line) then
      local opens, closes = count_blocks(line)
      indent_level = indent_level + opens - closes
      if indent_level < 0 then indent_level = 0 end
    end
  end

  local line = vim.fn.getline(curr)
  if not is_comment_or_blank(line) then
    if line:match("^%s*}") or line:match("^%s*>>") or line:match("^%s*#}") then
      indent_level = indent_level - 1
      if indent_level < 0 then indent_level = 0 end
    end
  end

  return indent_level
end

function M.lilypond()
  local sw = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or 2
  local curr = vim.fn.line('.')

  local stack = vim.fn.synstack(curr, 1)
  local names = {}
  for _, id in ipairs(stack) do
    table.insert(names, vim.fn.synIDattr(id, "name"))
  end

  local curr_line = vim.fn.getline(curr)
  local opens_lilyInScheme, closes_lilyInScheme = count_lilyInScheme_blocks(curr_line)

  if opens_lilyInScheme > closes_lilyInScheme then
    lilyInScheme_decay = vim.fn.lispindent(curr)
    return lilyInScheme_decay
  elseif names[1] == "lilyScheme" and contains(names, "lilyInScheme") then
    return (calculate_indent_level(curr) * sw) + lilyInScheme_decay
  elseif names[1] == "lilyScheme" then
    return vim.fn.lispindent(curr)
  else
    return calculate_indent_level(curr) * sw
  end
end

return M
