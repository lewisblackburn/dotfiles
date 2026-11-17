-- Everything added on top of LazyVim and its extras (see lazyvim.json).
local java = vim.fn.expand("~/.local/share/mise/installs/java")

return {
  -- Theme: Gruvbox, to match Ghostty, tmux and the prompt.
  { "ellisonleao/gruvbox.nvim" },
  { "LazyVim/LazyVim", opts = { colorscheme = "gruvbox" } },

  -- File explorer opens on the right.
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = { layout = { layout = { position = "right" } } },
        },
      },
    },
  },

  -- Indent with tabs or spaces to match whatever the file already uses.
  { "NMAC427/guess-indent.nvim", opts = {} },

  -- TypeScript server never formats: ESLint and Prettier use the repo's own rules.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      },
    },
  },

  -- Several servers answer K (Angular, TypeScript, Tailwind); stay quiet when only some have docs.
  { "folke/noice.nvim", opts = { lsp = { hover = { silent = true } } } },

  -- ctrl+h/j/k/l moves between nvim splits and tmux panes alike.
  {
    "christoomey/vim-tmux-navigator",
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left split" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower split" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper split" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right split" },
    },
  },

  -- Ctrl+Space never reaches nvim here, so ctrl+j opens completion in insert mode.
  {
    "saghen/blink.cmp",
    opts = { keymap = { ["<C-j>"] = { "show", "show_documentation", "hide_documentation" } } },
  },

  -- Java: jdtls itself needs Java 25 to start, while the projects build on 17 and 21.
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      table.insert(opts.cmd, "--java-executable=" .. java .. "/temurin-25/bin/java")
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          configuration = {
            runtimes = {
              { name = "JavaSE-17", path = java .. "/temurin-17" },
              { name = "JavaSE-21", path = java .. "/temurin-21", default = true },
            },
          },
        },
      })
    end,
  },
}
