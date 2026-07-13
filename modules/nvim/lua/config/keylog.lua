-- Keylogger for vim-habit analysis.
--
-- Captures every key pressed via vim.on_key(), aggregates plain Insert-mode
-- characters into a single count (so file contents / secrets are not stored
-- verbatim), and appends events as JSONL to a daily-rotated log file under
-- stdpath("state"). Terminal-mode input is never logged.
--
-- The log is meant to be read by tools/keylog-report (a Rust CLI) which
-- turns it into a digest; nothing here tries to be "the" analysis surface.

local M = {}

local uv = vim.uv or vim.loop

local FLUSH_INTERVAL_MS = 5000
local FLUSH_THRESHOLD = 200

-- Buffers/filetypes that are noise rather than signal (pickers, popups, etc).
local EXCLUDED_FILETYPES = {
  TelescopePrompt = true,
  which_key = true,
  toggleterm = true,
  [""] = true,
}

local state = {
  enabled = true,
  events = {}, -- pending event tables, flushed to disk periodically
  last_key_time_ms = nil,
  insert_run = 0,
  insert_run_delta_ms = 0,
  timer = nil,
}

local function log_dir()
  return vim.fn.stdpath("state") .. "/keylog"
end

local function log_path()
  return log_dir() .. "/keylog-" .. os.date("%Y-%m-%d") .. ".jsonl"
end

local function now_ms()
  return uv.now()
end

function M.flush()
  if #state.events == 0 then
    return
  end
  local dir = log_dir()
  vim.fn.mkdir(dir, "p")
  local fh = io.open(log_path(), "a")
  if not fh then
    state.events = {}
    return
  end
  for _, ev in ipairs(state.events) do
    fh:write(vim.json.encode(ev), "\n")
  end
  fh:close()
  state.events = {}
end

local function push_event(ev)
  table.insert(state.events, ev)
  if #state.events >= FLUSH_THRESHOLD then
    M.flush()
  end
end

-- Flush any pending run of aggregated Insert-mode characters as a single
-- {"key":"<insert-text>","count":N} event.
local function flush_insert_run(filetype)
  if state.insert_run <= 0 then
    return
  end
  push_event({
    timestamp = os.date("%Y-%m-%dT%H:%M:%S"),
    delta_ms = state.insert_run_delta_ms,
    mode = "i",
    key = "<insert-text>",
    count = state.insert_run,
    filetype = filetype or "",
  })
  state.insert_run = 0
  state.insert_run_delta_ms = 0
end

local function on_key(key, typed)
  if not state.enabled then
    return
  end

  local ok = pcall(function()
    local raw = typed
    if raw == nil or raw == "" then
      raw = key
    end
    if raw == nil or raw == "" then
      return
    end

    local mode = vim.api.nvim_get_mode().mode
    if mode:sub(1, 1) == "t" then
      -- Never log terminal-mode input (shell history, passwords, etc).
      return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
    if EXCLUDED_FILETYPES[ft] then
      return
    end

    local readable = vim.fn.keytrans(raw)
    if readable == "" then
      return
    end

    local t = now_ms()
    local delta = state.last_key_time_ms and (t - state.last_key_time_ms) or 0
    state.last_key_time_ms = t

    local is_insert = mode:sub(1, 1) == "i"
    local is_plain_char = is_insert and not readable:match("^<") and vim.fn.strchars(readable) == 1

    if is_plain_char then
      if state.insert_run == 0 then
        state.insert_run_delta_ms = delta
      end
      state.insert_run = state.insert_run + 1
      return
    end

    -- Any other key (including leaving Insert mode) flushes a pending run
    -- of aggregated characters first, then records itself individually.
    flush_insert_run(ft)

    push_event({
      timestamp = os.date("%Y-%m-%dT%H:%M:%S"),
      delta_ms = delta,
      mode = mode,
      key = readable,
      filetype = ft,
    })
  end)

  if not ok then
    -- Never let a logging failure break editor input.
    return
  end
end

local function current_filetype()
  return vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_get_current_buf() })
end

function M.setup()
  if vim.g.keylog_enabled == nil then
    vim.g.keylog_enabled = true
  end
  state.enabled = vim.g.keylog_enabled ~= false

  local ns = vim.api.nvim_create_namespace("my.keylog")
  vim.on_key(on_key, ns)

  local group = vim.api.nvim_create_augroup("my.keylog", { clear = true })

  state.timer = uv.new_timer()
  state.timer:start(
    FLUSH_INTERVAL_MS,
    FLUSH_INTERVAL_MS,
    vim.schedule_wrap(function()
      flush_insert_run(current_filetype())
      M.flush()
    end)
  )

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      flush_insert_run(current_filetype())
      M.flush()
    end,
  })

  vim.api.nvim_create_user_command("KeylogToggle", function()
    state.enabled = not state.enabled
    vim.g.keylog_enabled = state.enabled
    if not state.enabled then
      flush_insert_run(current_filetype())
      M.flush()
    end
    vim.notify("Keylog " .. (state.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
  end, { desc = "Toggle keystroke logging on/off" })

  vim.api.nvim_create_user_command("KeylogStatus", function()
    vim.notify(
      string.format("Keylog: %s\nPath: %s", state.enabled and "enabled" or "disabled", log_path()),
      vim.log.levels.INFO
    )
  end, { desc = "Show keylog status and today's log path" })

  vim.api.nvim_create_user_command("KeylogPath", function()
    local path = log_path()
    vim.fn.setreg("+", path)
    vim.notify("Copied to clipboard: " .. path, vim.log.levels.INFO)
  end, { desc = "Copy today's keylog path to the clipboard" })
end

M.setup()

return M
