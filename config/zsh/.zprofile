
# Homebrew, if present (Apple Silicon, Intel, or Linuxbrew). Brew is the main
# source of CLI tools on Fedora too, so this matters on both platforms — dnf
# only covers the system layer there (see packages/fedora.txt).
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [ -x "$_brew" ]; then eval "$("$_brew" shellenv)"; break; fi
done
unset _brew
