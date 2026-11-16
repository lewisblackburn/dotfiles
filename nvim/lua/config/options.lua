-- LazyVim's defaults: https://www.lazyvim.org/configuration/general

-- Format only on <leader>cf, so work files aren't reformatted on save.
vim.g.autoformat = false

-- Prettier only in repos that have a Prettier config; others keep their own style.
vim.g.lazyvim_prettier_needs_config = true

-- Avro schemas are JSON.
vim.filetype.add({ extension = { avsc = "json" } })
