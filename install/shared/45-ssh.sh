#!/usr/bin/env bash
# SSH: key generation and the agent, for the config 40-links already installed.
#
# Nothing secret is tracked — the repo holds config/ssh/config and nothing else.
# Keys are generated here per machine, which is the point: a key that travelled
# between machines in a git repo would be the wrong shape of convenient.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "SSH"

run mkdir -p "$HOME/.ssh/sockets"
dry || chmod 700 "$HOME/.ssh" "$HOME/.ssh/sockets"

# ControlPath sockets and machine-local hosts live outside the repo.
if [ ! -f "$HOME/.ssh/config.local" ]; then
  info "creating ~/.ssh/config.local for machine-specific hosts"
  run_sh "printf '# Machine-specific SSH hosts. Not tracked in the dotfiles repo.\n' > '$HOME/.ssh/config.local'"
fi

KEY="$HOME/.ssh/id_ed25519"
if [ -f "$KEY" ]; then
  ok "key present ($(ssh-keygen -lf "$KEY.pub" 2>/dev/null | awk '{print $1, $2}' || echo "$KEY"))"
else
  if ask "No SSH key found. Generate an ed25519 key?"; then
    # No -N "": a passphrase plus the agent is the sane default, and
    # AddKeysToAgent in config/ssh/config means you type it once per session.
    run ssh-keygen -t ed25519 -C "${USER}@$(hostname -s)" -f "$KEY"
    ok "key generated"
  else
    info "skipped — generate later with: ssh-keygen -t ed25519"
  fi
fi

# Load it into the agent so the first git push doesn't prompt.
if [ -f "$KEY" ] && ! dry; then
  if is_macos; then
    # --apple-use-keychain stores the passphrase, so it survives a reboot.
    ssh-add --apple-use-keychain "$KEY" >/dev/null 2>&1 && ok "key added to agent (keychain)" \
      || warn "couldn't add the key to the agent"
  else
    if [ -z "${SSH_AUTH_SOCK:-}" ]; then
      warn "no ssh-agent running — start one with: eval \"\$(ssh-agent -s)\""
    else
      ssh-add "$KEY" >/dev/null 2>&1 && ok "key added to agent" \
        || warn "couldn't add the key to the agent"
    fi
  fi
fi

if [ -f "$KEY.pub" ] && ! dry; then
  info "public key (add to GitHub with: gh ssh-key add $KEY.pub):"
  sed 's/^/      /' "$KEY.pub"
fi
exit 0
