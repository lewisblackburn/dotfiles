-- Git diff viewing / navigation via diffview.nvim.
-- Uses <leader>gv (not gd) to avoid AstroNvim's gitsigns <leader>gd (diffthis).
---@type LazySpec
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    {
      "<leader>gv",
      function()
        if require("diffview.lib").get_current_view() then
          vim.cmd.DiffviewClose()
        else
          vim.cmd.DiffviewOpen()
        end
      end,
      desc = "Diffview: toggle diff",
    },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history (current file)" },
  },
}
