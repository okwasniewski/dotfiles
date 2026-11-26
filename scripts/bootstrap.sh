#!/usr/bin/env bash
# Bootstrap a fresh Mac from these dotfiles: laptop (main machine) or devbox
# (any runner, under whatever account it has).
# Idempotent - safe to re-run. Run interactively (needs sudo and a few prompts).
# System settings and apps live in .nix, this script only covers what
# nix-darwin cannot: Homebrew and nix themselves, stow, machine-local files.
#
#   curl -fsSL https://raw.githubusercontent.com/okwasniewski/dotfiles/main/scripts/bootstrap.sh | bash -s laptop
#   or: ~/dotfiles/scripts/bootstrap.sh laptop
set -uo pipefail

HOST="${1:-}"
case "$HOST" in
laptop | devbox) ;;
*)
  echo "usage: bootstrap.sh laptop|devbox" >&2
  exit 1
  ;;
esac
DOTFILES="$HOME/dotfiles"
# One devbox profile, one flake host per account name.
FLAKE_HOST="$HOST"
[ "$HOST" = devbox ] && FLAKE_HOST="devbox-$(whoami)"
step() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }

step "Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Finish the Command Line Tools install, then re-run this script."
  exit 1
fi

step "Clone dotfiles"
if [ -d "$DOTFILES/.git" ]; then
  # A re-run should pick up fixes pushed since the first attempt. Best effort: offline or diverged is fine.
  # No global git config: it rewrites GitHub https to ssh, which needs the 1Password agent.
  GIT_CONFIG_GLOBAL=/dev/null git -C "$DOTFILES" pull --ff-only || echo "Could not update $DOTFILES, continuing with the local copy."
else
  git clone https://github.com/okwasniewski/dotfiles.git "$DOTFILES"
fi

# Piped through curl, stdin is the script itself. Re-run from the clone so prompts can read the terminal.
[ -t 0 ] || exec bash "$DOTFILES/scripts/bootstrap.sh" "$HOST" </dev/tty

step "sudo"
sudo -v || exit 1
# Homebrew, casks and mas all want root minutes apart: keep the ticket fresh so the password is asked once.
(while kill -0 $$ 2>/dev/null; do
  sudo -n true 2>/dev/null
  sleep 50
done) &

step "Lix"
if [ ! -e /nix/var/nix/profiles/default/bin/nix ]; then
  curl -sSf -L https://install.lix.systems/lix | sh -s -- install --no-confirm
fi
# The profile script reads unset variables (ZSH_VERSION), which aborts under `set -u`.
set +u
# shellcheck disable=SC1091
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
set -u

step "Check macOS user"
# A host hardcodes its user: a mismatch only surfaces as a failed activation half an hour in.
want_user=$(nix eval --raw "$DOTFILES/.nix#darwinConfigurations.$FLAKE_HOST.config.system.primaryUser")
if [ "$want_user" != "$(whoami)" ]; then
  if [ "$HOST" = devbox ]; then
    echo "No devbox host for the account '$(whoami)' yet." >&2
    echo "Add \"$(whoami)\" to devboxUsers in .nix/flake.nix, push, pull here and re-run." >&2
  else
    echo "Host '$HOST' is set up for user '$want_user', but this account is '$(whoami)'." >&2
    echo "Change the user in $DOTFILES/.nix/flake.nix or recreate the macOS account, then re-run." >&2
  fi
  exit 1
fi

step "Homebrew (nix-darwin manages packages, but needs brew itself)"
[ -x /opt/homebrew/bin/brew ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

step "Machine-local overrides"
# Real directories make stow link their contents one by one. Without them stow links the
# whole directory into the repo, and tool state (Claude sessions, tunnel credentials) lands
# in a public checkout.
mkdir -p "$HOME/.ssh" "$HOME/.config" "$HOME/.claude" "$HOME/.cloudflared"
chmod 700 "$HOME/.ssh" "$HOME/.cloudflared"
if [ "$HOST" != laptop ]; then
  # nix-rebuild reads the host from here. Rewritten, so a renamed host heals on the next run.
  touch "$HOME/.zshrc.local"
  grep -v '^export DARWIN_HOST=' "$HOME/.zshrc.local" >"$HOME/.zshrc.local.tmp"
  echo "export DARWIN_HOST=$FLAKE_HOST" >>"$HOME/.zshrc.local.tmp"
  mv "$HOME/.zshrc.local.tmp" "$HOME/.zshrc.local"
  # Runner: local ssh key instead of the 1Password agent, no commit signing.
  [ -f "$HOME/.ssh/local_config" ] || printf 'Host *\n  IdentityAgent none\n' >"$HOME/.ssh/local_config"
  [ -f "$DOTFILES/.config/git/local" ] || printf '[core]\n\tpager = cat\n[commit]\n\tgpgsign = false\n' >"$DOTFILES/.config/git/local"
  if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" -C "$(whoami)@$(hostname -s)"
    echo "ADD THIS KEY TO GITHUB (https://github.com/settings/keys):"
    cat "$HOME/.ssh/id_ed25519.pub"
  fi
fi
ssh-keygen -F github.com >/dev/null 2>&1 || ssh-keyscan -t ed25519 github.com >>"$HOME/.ssh/known_hosts" 2>/dev/null

step "nix-darwin ($FLAKE_HOST)"
if [ ! -e /run/current-system ]; then
  for f in /etc/zshrc /etc/zprofile /etc/bashrc; do
    [ -f "$f" ] && [ ! -L "$f" ] && sudo mv "$f" "$f.before-nix-darwin"
  done
  if [ "$HOST" = laptop ]; then
    # mas cannot sign in by itself, and one failed App Store install aborts the whole activation.
    open -a "App Store"
    read -r -p "Sign in to the App Store (just opened), then press Enter to continue. " _
  fi
fi
rebuild_ok=1
nix build "$DOTFILES/.nix#darwinConfigurations.$FLAKE_HOST.system" -o "$DOTFILES/result" &&
  sudo "$DOTFILES/result/sw/bin/darwin-rebuild" switch --flake "$DOTFILES/.nix#$FLAKE_HOST" || rebuild_ok=0
# result/sw/bin: activation links /run/current-system last, so after a failed
# Homebrew step stow and npm are only reachable through the build output.
export PATH="/run/current-system/sw/bin:$DOTFILES/result/sw/bin:/opt/homebrew/bin:$HOME/.local/bin:$PATH"

step "Stow dotfiles"
stow -d "$DOTFILES" -t "$HOME" -R .
ln -sfn AGENTS.md "$HOME/CLAUDE.md"
chmod 600 "$DOTFILES/.ssh/config"

step "CLIs for agents"
[ "$(npm config get prefix)" = "$HOME/.npm-global" ] || npm config set prefix "$HOME/.npm-global"
for pkg in @openai/codex unbox-ai; do
  npm ls -g "$pkg" >/dev/null 2>&1 || npm install -g "$pkg"
done
mkdir -p "$HOME/.local/bin"
command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash

if [ "$HOST" != laptop ]; then
  step "FileVault off + auto-login (so the box survives reboots unattended)"
  if fdesetup isactive >/dev/null 2>&1; then
    sudo fdesetup disable
    echo "Decryption runs in the background. Re-run this script once 'fdesetup status' says Off to enable auto-login."
  elif ! defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser >/dev/null 2>&1; then
    sudo sysadminctl -autologin set -userName "$(whoami)" -password -
  fi
fi

if [ "$rebuild_ok" = 0 ]; then
  printf '\n\033[1;31mdarwin-rebuild did not finish. Fix the error above and re-run this script.\033[0m\n'
  [ "$HOST" = laptop ] && echo "App Store installs fail until you are signed in to the App Store."
fi

step "Manual steps left"
echo "- Open Tailscale.app, log in, enable \"Run on login\""
echo "- Xcode via Xcodes.app, simulator runtimes, Android SDK via Android Studio"
if [ "$HOST" = laptop ]; then
  cat <<'TODO'
- 1Password: sign in, enable Settings > Developer > SSH agent (git signing and ssh use it)
- Secrets: recreate ~/dotfiles/.zsh_secrets from 1Password, then `exec zsh`
- Apps without a cask: Attio, Circleback, Oneleet, Rex, ZenNotes, Astro
- Claude Code MCP servers live in ~/.claude.json: re-add them with `claude mcp add --scope user`
- CLIs with their own installers (they bring their skills): yc, aside, terminal-browser
- Raycast: import the settings export from the old Mac
- Launch Things, Craft and Fantastical once
TODO
else
  cat <<'TODO'
- Add the printed SSH key to GitHub if it was just generated
- Reboot once FileVault is off and auto-login is set, confirm SSH comes back
TODO
fi
[ "$rebuild_ok" = 1 ]
