return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    -- Resolve JDKs via macOS java_home so this works on any machine,
    -- regardless of whether Java came from Temurin, Oracle, or Homebrew.
    local function java_home(version)
      local home = vim.fn.trim(vim.fn.system { "/usr/libexec/java_home", "-v", version })
      if vim.v.shell_error ~= 0 or home == "" then return nil end
      return home
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
