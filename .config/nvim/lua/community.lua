-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.eslint" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.html-markdown" },
  { import = "astrocommunity.pack.html-mdx" },
  { import = "astrocommunity.pack.html-prettier" },
  { import = "astrocommunity.pack.html-sql" },
  { import = "astrocommunity.pack.html-tailwindcss" },
  { import = "astrocommunity.pack.html-typescript-all-in-one" },
  -- import/override with your plugins folder
}
