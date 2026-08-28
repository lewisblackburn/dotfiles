-- Synchronously install/update treesitter parsers in a headless nvim.
--
-- Run as:  nvim --headless -c "luafile lib/nvim/treesitter-sync.lua" -c qa
--
-- Why this exists: nvim-treesitter's `main` branch — the one AstroNvim v6
-- tracks — removed :TSUpdateSync, and its :TSUpdate is asynchronous, so a
-- headless nvim exits before any parser finishes compiling. The Lua API is the
-- only way to block until the work is actually done.

local ok, ts = pcall(require, "nvim-treesitter")
if not ok then
  vim.notify("nvim-treesitter not available", vim.log.levels.ERROR)
  vim.cmd "cq"
  return
end

-- Prefer installing the parsers the config asks for: on a fresh machine nothing
-- is installed yet, so update() alone would be a no-op.
local langs
local cfg_ok, lazy_cfg = pcall(require, "lazy.core.config")
if cfg_ok then
  local spec = lazy_cfg.plugins["nvim-treesitter"]
  if spec and type(spec.opts) == "table" and type(spec.opts.ensure_installed) == "table" then
    langs = spec.opts.ensure_installed
  end
end

local job
if langs and #langs > 0 then
  vim.notify(("installing %d treesitter parsers"):format(#langs))
  job = ts.install(langs)
else
  vim.notify "updating installed treesitter parsers"
  job = ts.update()
end

-- 10 minutes: a cold run compiles every parser from source.
if job and job.wait then job:wait(600000) end

local installed = ts.get_installed and ts.get_installed() or {}
vim.notify(("treesitter: %d parsers installed"):format(#installed))
