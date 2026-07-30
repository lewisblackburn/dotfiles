-- Run Java services without IntelliJ.
--
-- The astrocommunity java pack already wires jdtls into nvim-dap and fills
-- `dap.configurations.java` with a "Launch <MainClass>" entry per main class it
-- finds, using the classpath jdtls already resolved. That covers everything
-- except the two things a real run configuration needs: an active Spring
-- profile and environment variables. This adds those on top.
local M = {}

-- Last launch per project root, so a re-run doesn't ask again.
local last = {}

local function root()
  return vim.fs.root(0, { "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts", ".git" }) or vim.fn.getcwd()
end

---Parse a dotenv-style file: `KEY=value`, optionally `export`-prefixed and/or
---quoted. Blank lines, comments and trailing inline comments are dropped.
---@param path string
---@return table<string, string>
local function read_env_file(path)
  local vars = {}
  if vim.fn.filereadable(path) ~= 1 then return vars end
  for _, line in ipairs(vim.fn.readfile(path)) do
    line = vim.trim(line)
    if line ~= "" and not vim.startswith(line, "#") then
      local key, value = line:match "^export%s+([%w_.]+)%s*=%s*(.*)$"
      if not key then
        key, value = line:match "^([%w_.]+)%s*=%s*(.*)$"
      end
      if key then
        local quoted = value:match '^"(.*)"$' or value:match "^'(.*)'$"
        vars[key] = quoted or vim.trim((value:gsub("%s+#.*$", "")))
      end
    end
  end
  return vars
end

---Env vars for a launch: `.env`, then `.env.<profile>` layered on top.
---@param profile string?
---@return table<string, string> vars, string[] files the files that were read
local function env_for(profile)
  local dir, vars, files = root(), {}, {}
  for _, name in ipairs { ".env", profile and (".env." .. profile) or nil } do
    local path = dir .. "/" .. name
    if vim.fn.filereadable(path) == 1 then
      table.insert(files, name)
      for key, value in pairs(read_env_file(path)) do
        vars[key] = value
      end
    end
  end
  return vars, files
end

---Spring profiles the project defines, from its `application-<profile>.*`
---resource files. Checked at the root and one level down for multi-module repos.
---@return string[]
local function profiles()
  local found, seen = {}, {}
  for _, glob in ipairs { "/src/main/resources/", "/*/src/main/resources/" } do
    for _, path in ipairs(vim.fn.glob(root() .. glob .. "application-*.*", false, true)) do
      local name = vim.fn.fnamemodify(path, ":t"):match "^application%-(.+)%.%w+$"
      if name and not seen[name] then
        seen[name] = true
        table.insert(found, name)
      end
    end
  end
  table.sort(found)
  return found
end

---The launch configs jdtls generated for this project's main classes.
---@return table[]
local function main_classes()
  local ok, dap = pcall(require, "dap")
  if not ok then return {} end
  return vim.tbl_filter(function(config) return config.mainClass ~= nil end, dap.configurations.java or {})
end

---@param config table a jdtls-generated launch config
---@param profile string? active Spring profile, nil to launch without one
local function launch(config, profile)
  local env, files = env_for(profile)
  if profile then env.SPRING_PROFILES_ACTIVE = profile end

  local vm_args = config.vmArgs or ""
  if profile then vm_args = vim.trim(vm_args .. " -Dspring.profiles.active=" .. profile) end

  last[root()] = { config = config, profile = profile }

  local dap = require "dap"
  local function start()
    dap.run(vim.tbl_extend("force", vim.deepcopy(config), {
      vmArgs = vm_args,
      env = env,
      cwd = root(),
      -- Real terminal, so application stdout/stderr is readable as it runs
      -- rather than being buried in the dap REPL.
      console = "integratedTerminal",
    }))
  end

  -- Launching while something is already running is nearly always a restart.
  if dap.session() then
    dap.terminate(nil, nil, start)
  else
    start()
  end

  require("astrocore").notify(
    ("%s | profile: %s | env: %s"):format(
      config.mainClass,
      profile or "none",
      #files > 0 and table.concat(files, ", ") or "none"
    )
  )
end

---@param items string[]
---@param prompt string
---@param on_choice fun(choice: string)
local function select(items, prompt, on_choice)
  if #items == 1 then return on_choice(items[1]) end
  vim.ui.select(items, { prompt = prompt }, function(choice)
    if choice then on_choice(choice) end
  end)
end

local function pick_profile(on_choice)
  local items = profiles()
  table.insert(items, "<none>")
  table.insert(items, "<other…>")
  select(items, "Spring profile", function(choice)
    if choice == "<none>" then
      on_choice(nil)
    elseif choice == "<other…>" then
      vim.ui.input({ prompt = "Spring profile: " }, function(input)
        if input and input ~= "" then on_choice(input) end
      end)
    else
      on_choice(choice)
    end
  end)
end

---Pick a main class and a profile, then launch it under the debugger.
function M.run()
  local configs = main_classes()
  if #configs == 0 then
    require("astrocore").notify(
      "No main classes found. Open a file in the project and let jdtls finish indexing.",
      vim.log.levels.WARN
    )
    return
  end

  local names = vim.tbl_map(function(config) return config.mainClass end, configs)
  select(names, "Main class", function(name)
    for _, config in ipairs(configs) do
      if config.mainClass == name then
        return pick_profile(function(profile) launch(config, profile) end)
      end
    end
  end)
end

---Re-launch the last main class/profile for this project, without prompting.
function M.rerun()
  local previous = last[root()]
  if not previous then return M.run() end
  launch(previous.config, previous.profile)
end

return M
