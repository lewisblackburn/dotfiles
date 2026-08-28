-- Don't throw away program output the moment the program dies (see
-- `lua/utils/dap.lua`); <Leader>dl (in astrocore.lua) pulls the console back up.
return {
  "rcarriga/nvim-dap-ui",
  optional = true,
  config = function(plugin, opts)
    -- This reaches into an AstroNvim-internal module path, and then overwrites
    -- the dapui_config listeners that same config registers. Both are private
    -- API. pcall so an upstream rename falls back to stock dap-ui behaviour
    -- (console closes on exit) rather than breaking startup.
    local ok, astro_config = pcall(require, "astronvim.plugins.configs.nvim-dap-ui")
    if ok then
      astro_config(plugin, opts)
      require("utils.dap").setup_listeners() -- ...then override its close-on-exit listeners
    else
      vim.notify(
        "astronvim.plugins.configs.nvim-dap-ui moved — DAP console will close on exit.\n"
          .. "Update lua/plugins/dap-ui.lua.",
        vim.log.levels.WARN
      )
      require("dapui").setup(opts)
    end
  end,
}
