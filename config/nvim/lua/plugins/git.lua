-- Git diff viewing / navigation via diffview.nvim.
-- AstroNvim's gitsigns sets its own buffer-local <leader>gd (diffthis), which
-- shadows this global mapping in git buffers — see the on_attach override in
-- gitsigns.lua that replaces it.
---@type LazySpec
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", function() require("utils.diffview").toggle() end, desc = "Diffview: toggle diff" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history (current file)" },
  },
}
