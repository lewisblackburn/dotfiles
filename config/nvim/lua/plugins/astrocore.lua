-- AstroCore is the central place for vim options, mappings and autocommands.
-- Keep custom mappings here rather than in individual plugin specs: one file to
-- read, and no risk of two specs binding the same key.
-- Configuration documentation: `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        number = true,
        relativenumber = true,
        signcolumn = "yes", -- always reserve the column so text doesn't jump
        wrap = false,
        spell = false,
      },
    },
    mappings = {
      n = {
        -- Split resizing. AstroNvim's default is <C-Up/Down/Left/Right>, which
        -- macOS grabs for Mission Control before the terminal ever sees it.
        -- (iTerm2's left Option is set to Esc+, so Alt+hjkl arrives intact.)
        ["<A-h>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" },
        ["<A-j>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" },
        ["<A-k>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" },
        ["<A-l>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" },

        -- Java run configurations (lua/utils/java.lua), hung off the existing
        -- <Leader>d debugger group.
        ["<Leader>dj"] = { function() require("utils.java").run() end, desc = "Java: run (pick class + profile)" },
        ["<Leader>dJ"] = { function() require("utils.java").rerun() end, desc = "Java: re-run last" },

        -- Bring the DAP console back after the program exits (lua/utils/dap.lua).
        ["<Leader>dl"] = { function() require("utils.dap").show_console() end, desc = "Show Console Output" },
      },
    },
  },
}
