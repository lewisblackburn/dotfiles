---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    formatting = {
      format_on_save = {
        -- Java projects use their build tooling's formatter instead of LSP formatting.
        ignore_filetypes = { "java" },
      },
    },
  },
}
