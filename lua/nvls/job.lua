local Utils = require('nvls.utils')
local Errors = require('nvls.errors')
local uv = vim.uv
local lb_failed = false

local debug = require('nvls').debug

local commands = {}

local JobQueue = {
  queue = {},
  running = false,
}

function JobQueue:start_next()
  if self.running or #self.queue == 0 then
    if #self.queue == 0 then
      commands = {}
    end
    return
  end
  self.running = true
  local job = table.remove(self.queue, 1)
  self:run_job(job)
end

function JobQueue:run_job(job)
  Utils.message(string.format('Running %s', job.cmd))

  local output_data = {}

  local stdout, stderr = uv.new_pipe(false), uv.new_pipe(false)

  local function on_read(err, data)
    if err then table.insert(output_data, err) end
    if data then table.insert(output_data, data) end
  end

  local options = {
    args = job.args,
    stdio = { nil, stdout, stderr },
    cwd = job.cwd,
  }

  local handle = uv.spawn(job.cmd, options, function(code, signal)
    if handle then
      uv.read_stop(stdout)
      uv.read_stop(stderr)
      stdout:close()
      stderr:close()
      handle:close()
    end

    local result = {
      code = code,
      signal = signal,
      output = table.concat(output_data),
    }

    vim.schedule(function()
      table.insert(commands, string.format("[cwd: %s]\n%s %s", job.cwd or vim.fn.getcwd(), job.cmd, table.concat(job.args, " ")))
      debug.commands = table.concat(commands, "\n")
      debug.exit = string.format("%s exit with code %d, signal %d", job.cmd, code, signal)
      debug.stdout = result.output

      if code ~= 0 then
        if job.cmd == "lilypond-book" then lb_failed = true end
        self.queue = {}
      else
        vim.fn.setqflist({}, 'r')
        if job.callback then job.callback(result) end
      end

      print(' ')
      Errors.process(job.cmd, result.output)
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
      if code == 0 then self:start_next() end
    end)

    self.running = false
  end)

  if not handle then
    Utils.message(string.format('Failed to start process: %s', job.cmd), "ERROR")
    self.queue = {}
    return
  end

  uv.read_start(stdout, on_read)
  uv.read_start(stderr, on_read)
end

function JobQueue:add(cmd, args, cwd, callback)
  table.insert(self.queue, { cmd = cmd, args = args, cwd = cwd, callback = callback })
  self:start_next()
end

function JobQueue:check_and_clean_tmp()
  if lb_failed then
    vim.fn.delete(vim.fs.joinpath(vim.fn.stdpath("cache"), "nvls"), "rf")
    lb_failed = false
  end
end

return JobQueue
