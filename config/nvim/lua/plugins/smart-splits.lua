-- AstroNvim maps split resizing to <C-Up/Down/Left/Right>, which macOS grabs
-- for Mission Control before the terminal ever sees it. Use Alt+hjkl instead
-- (iTerm2's left Option is set to Esc+, so these arrive intact).
return {
  "mrjones2014/smart-splits.nvim",
  optional = true,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<A-h>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" },
            ["<A-j>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" },
            ["<A-k>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" },
            ["<A-l>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" },
          },
        },
      },
    },
  },
}
