-- Don't throw away program output the moment the program dies (see
-- `lua/utils/dap.lua`), and add a way to pull the console back up on demand.
return {
  "rcarriga/nvim-dap-ui",
  optional = true,
  config = function(plugin, opts)
    require "astronvim.plugins.configs.nvim-dap-ui"(plugin, opts) -- AstroNvim's default setup
    require("utils.dap").setup_listeners() -- ...then override its close-on-exit listeners
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>dl"] = { function() require("utils.dap").show_console() end, desc = "Show Console Output" },
          },
        },
      },
    },
  },
}
