return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    -- Resolve JDKs at runtime so this works on any machine, regardless of
    -- whether Java came from Temurin, Oracle, Homebrew or a distro package.
    -- macOS has java_home; on Linux we glob the usual /usr/lib/jvm layouts.
    local function java_home(version)
      if vim.fn.has "mac" == 1 then
        local home = vim.fn.trim(vim.fn.system { "/usr/libexec/java_home", "-v", version })
        if vim.v.shell_error == 0 and home ~= "" then return home end
        return nil
      end

      local brew = vim.env.HOMEBREW_PREFIX or "/home/linuxbrew/.linuxbrew"
      for _, pattern in ipairs {
        brew .. "/opt/openjdk@" .. version,
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

    local jdk21 = java_home "21"
    local jdk17 = java_home "17"

    -- Run the language server itself on Java 21 (jdtls requires 21+),
    -- overriding the pack's bare "java" (which may resolve to an older JDK).
    if jdk21 then opts.cmd[1] = jdk21 .. "/bin/java" end

    -- Compile/target projects against Java 17.
    if jdk17 then
      opts.settings = opts.settings or {}
      opts.settings.java = opts.settings.java or {}
      opts.settings.java.configuration = opts.settings.java.configuration or {}
      opts.settings.java.configuration.runtimes = {
        { name = "JavaSE-17", path = jdk17, default = true },
      }
    end

    return opts
  end,
}
