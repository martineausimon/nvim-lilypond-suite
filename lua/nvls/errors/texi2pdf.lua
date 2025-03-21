local Utils = require('nvls.errors.utils')

return {
  {
    pattern = "([^:]+):(%d+): LaTeX Error: (.+)[%.:]+| |l%.%d+%s+(.*)$",
    rule = function(file, lnum, msg, pattern)
      pattern = pattern:gsub("| ", "")
      msg = msg:gsub("|", "")
      col = tonumber(Utils.get_col(file, lnum, pattern))
      return {
        filename = file,
        lnum = tonumber(lnum),
        col = col,
        type = "E",
        text = string.format("%s: %s", msg, pattern),
        pattern = Utils.format_pattern(pattern),
        end_col = col + #pattern - 1
      }
    end
  },
  {
    pattern = "([^:]+):(%d+): Undefined control sequence%.%s*|?[l%.%d+|<recently read>]%s*.*%s(%S+)|.*$",
    rule = function(file, lnum, pattern)
      col = tonumber(Utils.get_col(file, lnum, pattern))
      pattern = pattern:gsub("| ", "")
      return {
        filename = file,
        lnum = tonumber(lnum),
        type = "E",
        col = col,
        text = string.format("Undefined control sequence: %s", pattern),
        pattern = Utils.format_pattern(pattern),
        end_col = col + #pattern - 1
      }
    end
  },
  {
    pattern = "! LaTeX Error: File [`']?([^`']+)['`] not found.",
    rule = function(pattern)
      return {
        type = "E",
        lnum = 1,
        text = "File '" .. pattern .. "' not found.",
        pattern = Utils.format_pattern(pattern),
        module = "[stdout]"
      }
    end
  },
  {
    pattern = "([^:]+):(%d+): (.+)",
    rule = function(file, lnum, msg)
      return {
        filename = file,
        lnum = tonumber(lnum),
        col = 0,
        type = "W",
        text = msg,
        end_col = Utils.get_end_col(file, lnum, 0)
      }
    end
  }
}
