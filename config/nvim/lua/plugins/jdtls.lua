-- JDK resolution for jdtls.
--
-- mise owns Java on every platform (config/mise/config.toml pins temurin-17 and
-- temurin-21), so ask mise first. The system lookups and finally `exepath java`
-- are fallbacks for a machine where mise isn't set up — `exepath` alone always
-- resolves to whatever version is *active*, which is 17 under the global pin,
-- so it can't be the primary source when jdtls itself needs 21.
--
-- Both versions matter: jdtls runs on 21, and projects are compiled against 17.
-- Registering only one leaves the other unavailable to the language server.
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

      -- 3. Homebrew's openjdk (the real JDK lives under /libexec) and the usual
      --    Linux distro layouts.
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

    -- Run jdtls itself on 21 where we found it, otherwise whatever `java` is on
    -- PATH — jdtls failing to start at all is worse than running on 17.
    if jdk21 then
      opts.cmd[1] = jdk21 .. "/bin/java"
    else
      local java = vim.fn.exepath "java"
      if java ~= "" then opts.cmd[1] = java end
    end

    -- Register every JDK found as an execution environment, so a project's own
    -- target release is honoured instead of silently compiled against 21.
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
