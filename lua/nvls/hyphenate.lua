local Utils = require('nvls.utils')
local opts = require('nvls').get_nvls_options()
local lyopts = opts.lilypond.options
local nvls_hyphlang, lang

local M = {}

function M.quickLangInput()
  local value = nvls_hyphlang or lyopts.hyphenation_language
  vim.ui.input({
    prompt = "[NVLS] Hyphen language ? ",
    default = value
  }, function(input)
      nvls_hyphlang = input
  end)
end

function M.getHyphType()
  lang = nvls_hyphlang or lyopts.hyphenation_language
  local input = Utils.extract_from_sel(vim.fn.getpos("'<"), vim.fn.getpos("'>"))
  if lang == "en_DEFAULT" then
    M.hyphenator(input)
  else
    M.pyphen(input)
  end
end

function M.hyphenator(input)
  local hyphs = require('nvls.hyphs')
  for i, j in pairs(hyphs) do
    input = input:gsub("%f[%w_]" .. i .. "s?%f[^%w_]", j)
  end
  vim.fn.execute("set paste")
  vim.fn.execute("normal gvc" .. input)
  vim.fn.execute("normal g`<")
  vim.fn.execute("set nopaste")
end

function M.pyphen(input)
  if vim.fn.has('python3') == 0 then
    Utils.message('python3 is not available', 'ERROR')
    do return end
  end
  input = input:gsub("[\n\r]", " ")
  vim.fn.execute('py3 import pyphen')
  vim.fn.execute('py3 import vim')
  vim.fn.execute('py3 import re')
  vim.fn.execute(string.format('py3 def py_vim_string_replace(str):return str.replace("%s", b, 1)', input))
  vim.fn.execute(string.format('py3 dic = pyphen.Pyphen(lang="%s")', lang))
  vim.fn.execute(string.format('py3 a = "%s"', input))
  vim.fn.execute([[py3 b = dic.inserted(a, hyphen = ' -- ')]])
  vim.fn.execute([[py3 b = re.sub('  -- ', ' ', b)]])
  vim.fn.execute([[py3 b = re.sub('" -- ', '"', b)]])
  vim.fn.execute("'<,'>py3do return py_vim_string_replace(line)")
end

return M
