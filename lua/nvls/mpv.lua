local uv = vim.uv

local Mpv = {}
Mpv.__index = Mpv

local instance_id = 0

function Mpv.new()
  instance_id = instance_id + 1

  local self = setmetatable({}, Mpv)

  self.socket_path = string.format(
    "%s/nvls_mpv_%d_%d.sock",
    vim.fn.stdpath("cache"), vim.fn.getpid(), instance_id
  )
  self.handle = nil
  self.pipe = nil
  self.buffer = ""

  self.state = {
    duration = 0,
    time_pos = 0,
    pause = false,
    speed = 1.0,
    ['ab-loop-a'] = nil,
    ['ab-loop-b'] = nil,
  }

  return self
end

function Mpv:send(cmd)
  if self.pipe and not self.pipe:is_closing() then
    local ok, json = pcall(vim.fn.json_encode, { command = cmd })
    if not ok or not json then return end
    local msg = json .. "\n"
    pcall(self.pipe.write, self.pipe, msg)
  end
end

function Mpv:seek_absolute(seconds)
  self:send({ "set_property", "time-pos", seconds })
end

function Mpv:handle_message(line)
  local ok, data = pcall(vim.fn.json_decode, line)
  if not ok or not data then return end

  if data.event == "property-change" then
    if data.name == "time-pos" then
      self.state.time_pos = data.data or 0
    elseif data.name == "duration" then
      self.state.duration = data.data or 0
    elseif data.name == "pause" then
      self.state.pause = data.data or false
    elseif data.name == "speed" then
      self.state.speed = data.data or 1.0
    elseif data.name == "ab-loop-a" then
      self.state['ab-loop-a'] = data.data
    elseif data.name == "ab-loop-b" then
      self.state['ab-loop-b'] = data.data
    end
  elseif data.event == "end-file" then
    self.state.time_pos = 0
    self.state.pause = true
  end
end

function Mpv:start(on_ready)
  if self.handle then
    if on_ready then on_ready() end
    return
  end

  pcall(os.remove, self.socket_path)

  self.handle = uv.spawn("mpv", {
    args = {
      "--idle",
      "--no-video",
      "--keep-open=yes",
      "--input-ipc-server=" .. self.socket_path,
    },
    detached = true,
  }, function(code, signal)
    if self.pipe and not self.pipe:is_closing() then
      pcall(self.pipe.close, self.pipe)
    end
    self.pipe = nil

    if self.handle and not self.handle:is_closing() then
      pcall(self.handle.close, self.handle)
    end
    self.handle = nil
  end)

  vim.defer_fn(function()
    if not self.handle then return end

    self.pipe = uv.new_pipe(false)
    self.pipe:connect(self.socket_path, function(err)
      if err then
        -- échec de connexion : fermer la pipe et avertir
        if self.pipe and not self.pipe:is_closing() then
          pcall(self.pipe.close, self.pipe)
        end
        self.pipe = nil
        vim.schedule(function()
          vim.notify("[NVLS] mpv: cannot connect to ipc socket: " .. tostring(err), vim.log.levels.WARN, {})
        end)
        return
      end

      self.pipe:read_start(function(read_err, chunk)
        if read_err then
          if self.pipe and not self.pipe:is_closing() then
            pcall(self.pipe.close, self.pipe)
          end
          self.pipe = nil
          return
        end
        if chunk and #chunk > 0 then
          self.buffer = self.buffer .. chunk
          -- Découpage ligne par ligne pour garantir un JSON complet
          while true do
            local newline_pos = self.buffer:find("\n")
            if not newline_pos then break end

            local line = self.buffer:sub(1, newline_pos - 1)
            self.buffer = self.buffer:sub(newline_pos + 1)

            vim.schedule(function() self:handle_message(line) end)
          end
        end
      end)

      vim.schedule(function()
        self:send({ "observe_property", 1, "time-pos" })
        self:send({ "observe_property", 2, "duration" })
        self:send({ "observe_property", 3, "pause" })
        self:send({ "observe_property", 4, "speed" })
        self:send({ "observe_property", 5, "ab-loop-a" })
        self:send({ "observe_property", 6, "ab-loop-b" })
        if on_ready then on_ready() end
      end)
    end)
  end, 250)
end

function Mpv:play(file)
  self:start(function()
    self:send({ "loadfile", file, "replace" })
  end)
end

function Mpv:toggle_pause() self:send({ "cycle", "pause" }) end
function Mpv:seek(amount) self:send({ "seek", amount }) end

function Mpv:quit()
  self:send({ "quit" })

  if self.pipe and not self.pipe:is_closing() then
    pcall(self.pipe.shutdown, self.pipe)
    pcall(self.pipe.close, self.pipe)
  end
  self.pipe = nil

  pcall(os.remove, self.socket_path)
end

return Mpv
