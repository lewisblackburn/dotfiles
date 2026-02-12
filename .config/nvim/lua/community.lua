-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- Themes
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- Web
  { import = "astrocommunity.pack.typescript-all-in-one" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.eslint" },
  { import = "astrocommunity.pack.prettier" },
  { import = "astrocommunity.pack.mdx" },
  { import = "astrocommunity.pack.tailwindcss" },
  -- Java
  { import = "astrocommunity.pack.java" },
  -- GraphQL / API / Backend tools
  { import = "astrocommunity.pack.prisma" },
  { import = "astrocommunity.pack.proto" },
  -- Misc
  { import = "astrocommunity.code-runner.sniprun" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.xml" },
  { import = "astrocommunity.pack.lua" },
}
