local Utils = require('nvls.errors.utils')

return {
  {
    pattern = "([^:]+):(%d+):(%d+): (%w+): (.+): [«`'](.-)['`»]",
    rule = function(file, lnum, col, loglevel, msg, pattern)
      pattern = pattern:gsub("[«»]", "")
      return {
        filename = file,
        lnum = tonumber(lnum),
        col = tonumber(col),
        type = Utils.qf_type(loglevel),
        text = string.format("%s: `%s`", msg, pattern),
        pattern = Utils.format_pattern(pattern),
        end_col = tonumber(col) + #pattern - 1
      }
    end
  },
  {
    pattern = "([^:]+):(%d+):(%d+): (%w+): [«`'](.-)['`»] (.*)",
    rule = function(file, lnum, col, loglevel, pattern, msg)
      pattern = pattern:gsub("[«»]", "")
      return {
        filename = file,
        lnum = tonumber(lnum),
        col = tonumber(col),
        type = Utils.qf_type(loglevel),
        text = string.format("`%s` %s", pattern, msg),
        pattern = Utils.format_pattern(pattern),
        end_col = tonumber(col) + #pattern - 1
      }
    end
  },
  --{
  --  pattern = "([^:]+):(%d+):(%d+): (%w+): syntax error, unexpected (.*)",
  --  rule = function(file, lnum, col, loglevel, pattern)
  --    local unexpected, end_msg
  --    local last_line = pattern:match(".*|%s(%w+)$")
  --    local msg = string.format("syntax error, unexpected %s", last_line or pattern)

  --    if pattern:match("expecting") then
  --      unexpected, end_msg = pattern:match("([^,]+), expecting (.*)$")
  --      msg = string.format("syntax error, unexpected %s, expecting %s", unexpected, end_msg)
  --    end

  --    pattern = unexpected or last_line

  --    return {
  --      filename = file,
  --      lnum = tonumber(lnum),
  --      col = tonumber(col),
  --      type = Utils.qf_type(loglevel),
  --      text = msg,
  --      pattern = Utils.format_pattern(unexpected or last_line),
  --      end_col = pattern and (tonumber(col) + #pattern - 1) or Utils.get_end_col(file, lnum, col)
  --    }
  --  end
  --},
  {
    pattern = "([^:]+):(%d+):(%d+): (%w+): (.+)|.+|%s+(.*%S)%s*$",
    rule = function(file, lnum, col, loglevel, msg, pattern)
      if msg:match("not a note name") then
        pattern = msg:match("name:%s*(%S+)")
        msg = "not a note name"
      end
      col = tonumber(col) or 0
      return {
        filename = file,
        lnum = tonumber(lnum),
        col = col,
        type = Utils.qf_type(loglevel),
        text = string.format("%s: `%s`", msg, pattern),
        pattern = Utils.format_pattern(pattern),
        end_col = tonumber(col) + #pattern - 1
      }
    end
  },
  {
    pattern = "([^:]+):(%d+):(%d+): (%w+): (.+): (.*)",
    rule = function(file, lnum, col, loglevel, msg, pattern)
      return {
        filename = file,
        lnum = tonumber(lnum),
        col = tonumber(col),
        type = Utils.qf_type(loglevel),
        text = string.format("%s: %s", msg, pattern),
        pattern = Utils.format_pattern(pattern),
        end_col = tonumber(col) + #pattern - 1
      }
    end
  },
  {
    pattern = "([^:]+):(%d+):(%d+): (%w+): (.+)",
    rule = function(file, lnum, col, loglevel, msg)
      col = tonumber(col) or 0
      return {
        filename = file,
        lnum = tonumber(lnum),
        col = col,
        type = Utils.qf_type(loglevel),
        text = msg,
        end_col = Utils.get_end_col(file, lnum, col)
      }
    end
  },
  {
    pattern = "([^:]+):(%d+): (%w+):%s*(.*)",
    rule = function(file, lnum, loglevel, msg)
      local message, version = msg:match("^(.-)(\\version%s\"[%d%.]+\")$")
      local end_col
      if version then
        msg = string.format("%s %s", message:gsub("|","") , version)
        end_col = Utils.get_end_col(file, lnum, 1)
      end
      return {
        filename = file,
        lnum = tonumber(lnum),
        type = Utils.qf_type(loglevel),
        text = msg,
        end_col = end_col
      }
    end
  },
  {
    pattern = "(%w+): (.*)",
    rule = function(loglevel, msg)
      return {
        type = Utils.qf_type(loglevel),
        lnum = 1,
        text = msg,
        module = "[stdout]",
      }
    end
  }
}
