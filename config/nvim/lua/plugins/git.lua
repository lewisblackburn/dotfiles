-- Git diff viewing / navigation via diffview.nvim.
--
-- Deliberately NOT on <Leader>gd: AstroNvim binds that buffer-locally to
-- gitsigns' diffthis, so a global mapping there is shadowed inside every git
-- buffer. <Leader>gv is free, which means no on_attach override is needed.
---@type LazySpec
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    {
      "<Leader>gv",
      function()
        -- diffview is lazy-loaded on `cmd`; requiring the module pulls it in
        -- via lazy's loader, so this is safe on the very first press.
        local ok, lib = pcall(require, "diffview.lib")
        if ok and lib.get_current_view() then
          vim.cmd.DiffviewClose()
        else
          vim.cmd.DiffviewOpen()
        end
      end,
      desc = "Diffview: toggle diff",
    },
    { "<Leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history (current file)" },
  },
}
