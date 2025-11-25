return {
  "bullets-vim/bullets.vim",
  ft = { "markdown", "text" },
  config = function()
    vim.g.bullets_enabled_file_types = { "markdown", "text" }
    vim.g.bullets_enable_in_empty_buffers = 0
    vim.g.bullets_checkbox_markers = " x"
    vim.g.bullets_checkbox_partials_toggle = 1
  end,
}
