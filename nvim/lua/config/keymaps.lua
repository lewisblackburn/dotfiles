-- LazyVim's defaults: https://www.lazyvim.org/keymaps

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- alt+shift+h/j/k/l resizes splits, same keys as tmux panes (ctrl+arrows belong to macOS).
vim.keymap.set("n", "<M-H>", "<cmd>vertical resize -4<cr>", { desc = "Narrower split" })
vim.keymap.set("n", "<M-L>", "<cmd>vertical resize +4<cr>", { desc = "Wider split" })
vim.keymap.set("n", "<M-J>", "<cmd>resize -2<cr>", { desc = "Shorter split" })
vim.keymap.set("n", "<M-K>", "<cmd>resize +2<cr>", { desc = "Taller split" })
