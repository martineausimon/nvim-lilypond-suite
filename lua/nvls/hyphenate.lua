local Utils = require('nvls.utils')
local nvls_options = require('nvls').get_nvls_options()

local fn = vim.fn

local M = {}

function M.quickLangInput()
  local Input = require("nui.input")
  local plopts = nvls_options.player.options

  if nvls_hyphlang then
    value = nvls_hyphlang
  else
    value = nvls_options.lilypond.options.hyphenation_language
  end

  local input = Input({
    position = "50%",
    size = {
      width = 15,
    },
    border = {
      style = plopts.border_style,
      text = {
        top = "[Language?]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = plopts.winhighlight,
    },
  }, {
    prompt = "> ",
    default_value = value,
    on_submit = function(value)
      nvls_hyphlang = value
    end,
  })

  input:mount()

  input:map("n", "<Esc>", function()
    input:unmount()
  end, { noremap = true })
end

function M.getHyphType()
  if nvls_hyphlang then lang = nvls_hyphlang
  else lang = nvls_options.lilypond.options.hyphenation_language
  end

  local input = Utils.extract_from_sel(fn.getpos("'<"), fn.getpos("'>"))
  if lang == "en_DEFAULT" then M.hyphenator(input)
  else M.pyphen(input)
  end
end

function M.hyphenator(input)
  local hyphs = require('nvls.hyphs')
  for i, j in pairs(hyphs) do
    input = input:gsub("%f[%w_]" .. i .. "s?%f[^%w_]", j)
  end
  fn.execute("set paste")
  fn.execute("normal gvc" .. input)
  fn.execute("normal g`<")
  fn.execute("set nopaste")
end

function M.pyphen(input)
  if fn.has('python3') == 0 then
    Utils.message('python3 is not available', 'ErrorMsg')
    do return end
  end
  input = input:gsub("[\n\r]", " ")
  fn.execute('py3 import pyphen')
  fn.execute('py3 import vim')
  fn.execute('py3 import re')
  fn.execute([[py3 def py_vim_string_replace(str):]] ..
  [[return str.replace("]] .. input .. [[", b, 1)]])
  fn.execute([[py3 dic = pyphen.Pyphen(lang=']] .. lang .. [[')]])
  fn.execute([[py3 a = "]] .. input .. [["]])
  fn.execute([[py3 b = dic.inserted(a, hyphen = ' -- ')]])
  fn.execute([[py3 b = re.sub('  -- ', ' ', b)]])
  fn.execute([[py3 b = re.sub('" -- ', '"', b)]])
  fn.execute("'<,'>py3do return py_vim_string_replace(line)")
end

return M
