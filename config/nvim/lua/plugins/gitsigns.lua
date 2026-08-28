-- Lightweight inline git blame via gitsigns (bundled with AstroNvim).
-- Blames only the current line, lazily, so it's cheap on CPU.
--
-- No blame mapping here on purpose: AstroNvim already provides <Leader>gl
-- (blame line) and <Leader>gL (full blame), and <Leader>gb is its git branch
-- picker — binding blame there would shadow it.
---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 300, -- ms after the cursor settles before querying (keeps it cheap)
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "  <author>, <author_time:%R> · <summary>",
  },
  keys = {
    { "<Leader>gB", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle line blame" },
  },
}
