return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    local java = vim.fn.exepath "java"

    if java ~= "" then opts.cmd[1] = java end

    return opts
  end,
}
