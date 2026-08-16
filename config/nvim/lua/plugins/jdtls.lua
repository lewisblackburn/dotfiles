return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    -- Resolve JDKs at runtime.
    -- Homebrew's OpenJDK installation has the actual JDK under /libexec.
    local function java_home(version)
      if vim.fn.has "mac" == 1 then
        local home = vim.fn.trim(vim.fn.system { "/usr/libexec/java_home", "-v", version })

        if vim.v.shell_error == 0 and home ~= "" then return home end

        return nil
      end

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

    local jdk21 = java_home "21"

    -- Run JDTLS itself on Java 21.
    if jdk21 then opts.cmd[1] = jdk21 .. "/bin/java" end

    -- Use Java 21 as the default project runtime.
    if jdk21 then
      opts.settings = opts.settings or {}
      opts.settings.java = opts.settings.java or {}
      opts.settings.java.configuration = opts.settings.java.configuration or {}

      opts.settings.java.configuration.runtimes = {
        {
          name = "JavaSE-21",
          path = jdk21,
          default = true,
        },
      }
    end

    return opts
  end,
}
