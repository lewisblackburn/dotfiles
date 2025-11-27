return {
  "toppair/peek.nvim",
  lazy = true,
  build = "deno task --quiet build:fast",
  ft = { "markdown", "telekasten" },
  keys = {
    {
      "<leader>mo",
      function() require("peek").open() end,
      desc = "Open markdown preview",
      ft = { "markdown", "telekasten" },
    },
    {
      "<leader>mc",
      function() require("peek").close() end,
      desc = "Close markdown preview",
      ft = { "markdown", "telekasten" },
    },
  },
  dependencies = {
    "AstroNvim/astrocore",
    opts = {
      commands = {
        PeekOpen = { function() require("peek").open() end, desc = "Open preview window" },
        PeekClose = { function() require("peek").close() end, desc = "Close preview window" },
      },
    },
  },
  config = function()
    vim.treesitter.language.register("markdown", "telekasten")
    require("peek").setup {
      theme = "dark", -- or "light"
      filetype = { "markdown", "telekasten" },
    }
  end,
}
