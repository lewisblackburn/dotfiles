return { -- override blink.cmp plugin
  "Saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
    },
  },
}
