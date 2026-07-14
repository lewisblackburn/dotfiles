-- Shrink the sidekick.nvim CLI window from the astrocommunity defaults.
return {
  "folke/sidekick.nvim",
  opts = function(_, opts)
    opts.cli = opts.cli or {}
    opts.cli.win = opts.cli.win or {}

    -- Split layouts (left/right/top/bottom): fixed, small.
    opts.cli.win.split = vim.tbl_deep_extend("force", opts.cli.win.split or {}, {
      width = 40, -- was ~half the screen
      height = 12, -- was ~half the screen
    })

    -- Float layout: fraction of the screen (was 0.9 x 0.9).
    opts.cli.win.float = vim.tbl_deep_extend("force", opts.cli.win.float or {}, {
      width = 0.5,
      height = 0.5,
    })

    return opts
  end,
}
