return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "telekasten" }, -- Add telekasten
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        if opts.ensure_installed ~= "all" then
          opts.ensure_installed =
            require("astrocore").list_insert_unique(opts.ensure_installed, { "html", "markdown", "markdown_inline" })
        end
      end,
    },
  },
  opts = {
    file_types = { "markdown", "telekasten" }, -- Add telekasten here too
    -- Tell render-markdown to use markdown parser for telekasten files
    custom_handlers = {},
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)

    -- Map telekasten filetype to use markdown parser
    vim.treesitter.language.register("markdown", "telekasten")
  end,
}
