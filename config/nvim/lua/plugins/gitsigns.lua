-- Lightweight inline git blame via gitsigns (bundled with AstroNvim)
-- Blames only the current line, lazily, so it's cheap on CPU.
---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 300, -- ms after cursor settles before querying (keeps it cheap)
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "  <author>, <author_time:%R> · <summary>",
  },
  keys = {
    { "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Git blame line" },
    { "<leader>gB", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle line blame" },
  },
}
