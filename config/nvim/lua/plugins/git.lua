-- Better git diff viewing / navigation via diffview.nvim
---@type LazySpec
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
  opts = {
    enhanced_diff_hl = true,
    view = {
      -- side-by-side diff for the working tree / commits
      default = { layout = "diff2_horizontal" },
      -- 3-way merge layout when resolving conflicts
      merge_tool = { layout = "diff3_mixed" },
    },
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open diff" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history (current file)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: repo history" },
  },
}
