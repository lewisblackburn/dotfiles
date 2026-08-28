-- Shrink the sidekick.nvim CLI window from the astrocommunity defaults.
return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      win = {
        split = { width = 40, height = 12 }, -- was ~half the screen
        float = { width = 0.5, height = 0.5 }, -- was 0.9 x 0.9
      },
    },
  },
}
