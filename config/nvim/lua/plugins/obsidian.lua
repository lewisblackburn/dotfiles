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
  -- <Leader>O group for Obsidian actions (O = Obsidian; <Leader>n/o are taken).
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>O"] = { desc = "󱓼 Obsidian" },
            -- daily notes
            ["<Leader>Ot"] = { "<Cmd>Obsidian today<CR>", desc = "Today's daily note" },
            ["<Leader>Oy"] = { "<Cmd>Obsidian yesterday<CR>", desc = "Yesterday's daily note" },
            ["<Leader>Om"] = { "<Cmd>Obsidian tomorrow<CR>", desc = "Tomorrow's daily note" },
            ["<Leader>Od"] = { "<Cmd>Obsidian dailies<CR>", desc = "Browse daily notes" },
            -- navigate / find
            ["<Leader>Oo"] = { "<Cmd>Obsidian quick_switch<CR>", desc = "Quick switch note" },
            ["<Leader>Os"] = { "<Cmd>Obsidian search<CR>", desc = "Search vault (grep)" },
            ["<Leader>Ob"] = { "<Cmd>Obsidian backlinks<CR>", desc = "Backlinks to this note" },
            ["<Leader>Ol"] = { "<Cmd>Obsidian links<CR>", desc = "Links in this note" },
            ["<Leader>Og"] = { "<Cmd>Obsidian tags<CR>", desc = "Browse tags" },
            -- create / edit
            ["<Leader>On"] = { "<Cmd>Obsidian new<CR>", desc = "New note" },
            ["<Leader>OT"] = { "<Cmd>Obsidian template<CR>", desc = "Insert template" },
            ["<Leader>Or"] = { "<Cmd>Obsidian rename<CR>", desc = "Rename note (update links)" },
            ["<Leader>Op"] = { "<Cmd>Obsidian paste_img<CR>", desc = "Paste image to attachments" },
            ["<Leader>Ow"] = { "<Cmd>Obsidian workspace<CR>", desc = "Switch workspace" },
          },
          x = {
            ["<Leader>O"] = { desc = "󱓼 Obsidian" },
            ["<Leader>Oe"] = { "<Cmd>Obsidian extract_note<CR>", desc = "Extract selection to new note" },
            ["<Leader>Ol"] = { "<Cmd>Obsidian link<CR>", desc = "Link selection to a note" },
          },
        },
      },
    },
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

    -- Pasted/linked images go to attachments/ (attachments.img_folder -> attachments.folder).
    opts.attachments = { folder = "attachments" }

    -- Let markview.nvim handle the pretty rendering; disable obsidian's own
    -- conceal UI so the two don't fight.
    opts.ui = { enable = false }

    -- Clear deprecated opts the astrocommunity pack sets so obsidian.nvim
    -- stops warning. Completion is now the built-in obsidian-ls LSP, so the
    -- old completion table is dropped entirely.
    opts.completion = nil

    -- note_frontmatter_func -> frontmatter.func.
    opts.frontmatter = { func = opts.note_frontmatter_func }
    opts.note_frontmatter_func = nil

    -- follow_url_func -> vim.ui.open (now the default, so just drop the override).
    opts.follow_url_func = nil

    -- Opt into the new `Obsidian <cmd>` command style (mappings already use it).
    opts.legacy_commands = false

    return opts
  end,
}
