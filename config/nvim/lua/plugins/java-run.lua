-- Run configurations for Java projects (see `lua/utils/java.lua`), hung off the
-- existing <Leader>d debugger group.
return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<Leader>dj"] = { function() require("utils.java").run() end, desc = "Java: run (pick class + profile)" },
        ["<Leader>dJ"] = { function() require("utils.java").rerun() end, desc = "Java: re-run last" },
      },
    },
  },
}
