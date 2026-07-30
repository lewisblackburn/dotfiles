-- Lightweight inline git blame via gitsigns (bundled with AstroNvim)
-- Blames only the current line, lazily, so it's cheap on CPU.
---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  -- A function (not a table) so it runs *after* AstroNvim's own opts function
  -- and can wrap the on_attach it sets, rather than being overwritten by it.
  opts = function(_, opts)
    local astro_on_attach = opts.on_attach
    return require("astrocore").extend_tbl(opts, {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 300, -- ms after cursor settles before querying (keeps it cheap)
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "  <author>, <author_time:%R> · <summary>",
      on_attach = function(bufnr)
        if astro_on_attach then astro_on_attach(bufnr) end
        -- AstroNvim binds <Leader>gd buffer-locally to gitsigns.diffthis(), a
        -- plain vim diff split. That shadows diffview's global mapping in every
        -- git buffer, so replace it here with the real Diffview toggle.
        vim.keymap.set(
          "n",
          "<Leader>gd",
          function() require("utils.diffview").toggle() end,
          { buffer = bufnr, desc = "Diffview: toggle diff" }
        )
      end,
    })
  end,
  keys = {
    { "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Git blame line" },
    { "<leader>gB", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle line blame" },
  },
}
