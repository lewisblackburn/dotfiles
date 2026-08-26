-- GraphQL language support.
--
-- NOTE: astrocommunity has no `pack.graphql`, so this mirrors what a community
-- pack would do (see `astrocommunity.pack.prisma` for the same shape):
-- treesitter parser + `graphql-lsp` installed via Mason.
--
-- `graphql-lsp` only attaches in projects with a GraphQL config file
-- (`.graphqlrc*`, `.graphql.config.*`, `graphql.config.*`).

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    optional = true,
    ---@type AstroCoreOpts
    opts = {
      treesitter = { ensure_installed = { "graphql" } },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "graphql" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "graphql-language-service-cli" })
    end,
  },
}
