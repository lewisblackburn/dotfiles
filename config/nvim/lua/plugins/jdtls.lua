-- JDK resolution for jdtls.
--
-- mise owns Java on every platform (config/mise/config.toml pins temurin-17 and
-- temurin-21), so ask mise first. The /usr/libexec/java_home and /usr/lib/jvm
-- lookups stay as a fallback for a machine where mise isn't set up yet.
--
-- Both versions matter: jdtls itself runs on 21, and projects are compiled
-- against 17 — registering only one leaves the other unavailable to the LSP.
return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    ---Resolve a JDK home for a major version, or nil.
    ---@param version string  major version, e.g. "21"
    ---@return string|nil
    local function java_home(version)
      -- 1. mise, the authoritative source.
      if vim.fn.executable "mise" == 1 then
        local home = vim.fn.trim(vim.fn.system { "mise", "where", "java@temurin-" .. version })
        if vim.v.shell_error == 0 and home ~= "" and vim.fn.isdirectory(home) == 1 then return home end
      end

      -- 2. macOS system registry (Temurin casks, system JDKs).
      if vim.fn.has "mac" == 1 then
        local home = vim.fn.trim(vim.fn.system { "/usr/libexec/java_home", "-v", version })
        if vim.v.shell_error == 0 and home ~= "" then return home end
      end

      -- 3. Homebrew's openjdk (the real JDK lives under /libexec) and the
      --    usual Linux distro layouts.
      local brew = vim.env.HOMEBREW_PREFIX or "/home/linuxbrew/.linuxbrew"
      for _, pattern in ipairs {
        brew .. "/opt/openjdk@" .. version .. "/libexec",
        "/usr/lib/jvm/java-" .. version .. "-openjdk*",
        "/usr/lib/jvm/java-" .. version .. "*",
        "/usr/lib/jvm/temurin-" .. version .. "*",
        "/usr/lib/jvm/jdk-" .. version .. "*",
      } do
        for _, dir in ipairs(vim.fn.glob(pattern, false, true)) do
          if vim.fn.executable(dir .. "/bin/javac") == 1 then return dir end
        end
      end

      return nil
    end

    local jdk21, jdk17 = java_home "21", java_home "17"

    -- Run jdtls itself on Java 21.
    if jdk21 then opts.cmd[1] = jdk21 .. "/bin/java" end

    -- Register every JDK we found as an execution environment, so a project's
    -- own target release is honoured instead of silently compiled against 21.
    local runtimes = {}
    if jdk21 then table.insert(runtimes, { name = "JavaSE-21", path = jdk21, default = true }) end
    if jdk17 then table.insert(runtimes, { name = "JavaSE-17", path = jdk17, default = jdk21 == nil }) end

    if #runtimes > 0 then
      opts.settings = opts.settings or {}
      opts.settings.java = opts.settings.java or {}
      opts.settings.java.configuration = opts.settings.java.configuration or {}
      opts.settings.java.configuration.runtimes = runtimes
    else
      vim.notify(
        "jdtls: no JDK found. Install them with:  ./install.sh --only 20-runtimes",
        vim.log.levels.WARN
      )
    end

    return opts
  end,
}
