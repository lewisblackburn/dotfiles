-- Shared Diffview toggle, used by both the diffview spec and the gitsigns
-- on_attach override (which has to re-map <Leader>gd buffer-locally).
local M = {}

---Open Diffview, or close it if a view is already showing.
function M.toggle()
  -- diffview is lazy-loaded on `cmd`; requiring the module pulls it in via
  -- lazy's loader, so this is safe on the very first press.
  local ok, lib = pcall(require, "diffview.lib")
  if ok and lib.get_current_view() then
    vim.cmd.DiffviewClose()
  else
    vim.cmd.DiffviewOpen()
  end
end

return M
