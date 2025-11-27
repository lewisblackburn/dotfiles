-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
vim.env.LG_CONFIG_FILE = vim.fn.expand "~/.config/lazygit/config.yml"
