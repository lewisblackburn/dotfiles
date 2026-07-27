
# Homebrew, if present (Apple Silicon, Intel, or Linuxbrew). Skipped on
# machines without it — e.g. Fedora, where packages come from dnf.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [ -x "$_brew" ]; then eval "$("$_brew" shellenv)"; break; fi
done
unset _brew
