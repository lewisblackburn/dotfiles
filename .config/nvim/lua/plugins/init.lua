return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  { import = "nvchad.blink.lazyspec" },
  
  -- Git blame (GitLens-like) - optimized
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 100, -- faster response (was 500ms)
        ignore_whitespace = true,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
      -- Performance optimizations
      max_file_length = 10000,
      update_debounce = 50,
    },
  },
  
  -- TODO comments with more keywords
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    opts = {
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO", "NOTES" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        MARK = { icon = " ", color = "default", alt = { "BOOKMARK", "MARKER" } },
        REVIEW = { icon = " ", color = "warning", alt = { "CHECK", "VERIFY" } },
      },
      -- Highlight whole comment line
      highlight = {
        multiline = true,
        before = "",
        keyword = "wide",
        after = "fg",
      },
    },
  },
}
