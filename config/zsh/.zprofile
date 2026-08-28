
# Homebrew, if present (Apple Silicon, Intel, or Linuxbrew). Brew is the main
# source of CLI tools on Fedora too, so this matters on both platforms — dnf
# only covers the system layer there (see packages/fedora.txt).
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [ -x "$_brew" ]; then eval "$("$_brew" shellenv)"; break; fi
done
unset _brew

# mise shims, so the managed runtimes resolve in NON-interactive shells too:
# a GUI-launched nvim, cron, `zsh -lc ...`. The `mise activate` line in .zshrc
# only rewrites PATH at an interactive prompt, so without this a Mason LSP
# (vtsls, eslint, the html/css/json servers - all Node scripts) started from a
# non-interactive nvim can't find node at all.
#
# .zshrc's activate runs after this and prepends the real install paths, which
# take precedence; the shims are just the floor. This is the layout mise
# documents for exactly this split.
[ -d "$HOME/.local/share/mise/shims" ] && export PATH="$HOME/.local/share/mise/shims:$PATH"
