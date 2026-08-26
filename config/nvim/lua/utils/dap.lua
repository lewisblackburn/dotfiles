-- Keep program output on screen after a run ends.
--
-- AstroNvim closes the whole dap UI on `terminated`/`exited`, which is tidy for
-- a clean run but hides the console exactly when it matters: a crash writes its
-- stack trace there and then the window vanishes. The buffer itself survives
-- (nvim-dap and dapui share one console buffer and reuse it), so this keeps it
-- on screen when the program dies badly, and gives a way to bring it back.
local M = {}

---The buffer nvim-dap streams program output into, if one exists yet.
---@return integer?
function M.console_buf()
  local ok, dap = pcall(require, "dap")
  local session = ok and dap.session()
  if session and session.term_buf and vim.api.nvim_buf_is_valid(session.term_buf) then return session.term_buf end
  -- No live session: fall back to the buffer left behind by the last run.
  -- dapui creates it with filetype `dapui_console`; nvim-dap then renames it.
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_valid(buf)
      and (vim.bo[buf].filetype == "dapui_console" or vim.api.nvim_buf_get_name(buf):match "%[dap%-terminal%]")
    then
      return buf
    end
  end
end

---Show the console output in a split below, or jump to it if already visible.
function M.show_console()
  local buf = M.console_buf()
  if not buf then
    require("astrocore").notify("No debug console output yet", vim.log.levels.WARN)
    return
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == buf then return vim.api.nvim_set_current_win(win) end
  end
  vim.cmd("botright " .. math.max(15, math.floor(vim.o.lines * 0.35)) .. "split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.cmd "normal! G" -- terminal buffers open wherever they were left; jump to the tail
end

---Replace AstroNvim's auto-open/close dapui listeners with ones that hold the
---console open when the program exits non-zero. Called from the dapui config,
---after AstroNvim's own has registered its handlers under the same keys.
function M.setup_listeners()
  local dap, dapui = require "dap", require "dapui"

  -- Set on `exited`, read on the `terminated` that follows it, cleared when the
  -- next session starts (both events fire per run, in that order).
  local exit_code

  local function on_stop()
    if exit_code and exit_code ~= 0 then
      require("astrocore").notify(("Program exited with code %d"):format(exit_code), vim.log.levels.WARN)
      M.show_console()
    else
      dapui.close()
    end
  end

  dap.listeners.after.event_initialized.dapui_config = function()
    exit_code = nil
    dapui.open()
  end
  dap.listeners.before.event_exited.dapui_config = function(_, body)
    exit_code = body and body.exitCode
    on_stop()
  end
  dap.listeners.before.event_terminated.dapui_config = function() on_stop() end
end

return M
