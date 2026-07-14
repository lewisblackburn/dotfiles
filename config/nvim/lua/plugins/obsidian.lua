-- Point the astrocommunity obsidian-nvim pack at my real vault and mirror the
-- settings from Obsidian's own .obsidian config.
local vault = vim.env.HOME .. "/Documents/vault"

return {
  "obsidian-nvim/obsidian.nvim",
  -- The pack only loads for */obsidian-vault/*.md; load for my vault instead.
  event = {
    "BufReadPre " .. vault .. "/**.md",
    "BufNewFile " .. vault .. "/**.md",
  },
  opts = function(_, opts)
    opts.workspaces = { { name = "vault", path = vault } }

    -- Daily notes: daily/YYYY/MM/YYYY-MM-DD.md with the daily template.
    opts.daily_notes = {
      folder = "daily",
      date_format = "%Y/%m/%Y-%m-%d",
      template = "daily note template.md",
    }

    -- Templates live in templates/.
    opts.templates = {
      subdir = "templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    }

    -- Pasted/linked images go to attachments/.
    opts.attachments = { img_folder = "attachments" }

    -- Let markview.nvim handle the pretty rendering; disable obsidian's own
    -- conceal UI so the two don't fight.
    opts.ui = { enable = false }

    return opts
  end,
}
