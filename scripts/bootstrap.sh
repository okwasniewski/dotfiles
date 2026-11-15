#!/usr/bin/env bash
# Bootstrap a Mac mini as a headless remote workhorse.
# Idempotent - safe to re-run. Run interactively (needs sudo and a few prompts).
# Headless system settings live in .nix/hosts/macmini, this script only covers
# what nix-darwin cannot: installing nix itself, stow, secrets, FileVault.
#
#   curl -fsSL https://raw.githubusercontent.com/okwasniewski/dotfiles/main/scripts/bootstrap-macmini.sh | bash
#   or: ~/dotfiles/scripts/bootstrap-macmini.sh
set -uo pipefail

DOTFILES="$HOME/dotfiles"
HOST="macmini"
step() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }

step "Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Finish the Command Line Tools install, then re-run this script."
  exit 1
fi

step "Clone dotfiles"
[ -d "$DOTFILES/.git" ] || git clone https://github.com/okwasniewski/dotfiles.git "$DOTFILES"

# Piped through curl, stdin is the script itself. Re-run from the clone so prompts can read the terminal.
[ -t 0 ] || exec bash "$DOTFILES/scripts/bootstrap-macmini.sh" </dev/tty

step "Homebrew (nix-darwin manages packages, but needs brew itself)"
[ -x /opt/homebrew/bin/brew ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

step "Lix"
if [ ! -e /nix/var/nix/profiles/default/bin/nix ]; then
  curl -sSf -L https://install.lix.systems/lix | sh -s -- install --no-confirm
fi
# shellcheck disable=SC1091
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

step "Machine-local overrides (headless box: local ssh key, no 1Password)"
mkdir -p "$HOME/.ssh" "$HOME/.config"
chmod 700 "$HOME/.ssh"
[ -f "$HOME/.ssh/local_config" ] || printf 'Host *\n  IdentityAgent none\n' >"$HOME/.ssh/local_config"
grep -qs '^export DARWIN_HOST=' "$HOME/.zshrc.local" || echo "export DARWIN_HOST=$HOST" >>"$HOME/.zshrc.local"
[ -f "$DOTFILES/.config/git/local" ] || printf '[core]\n\tpager = cat\n[commit]\n\tgpgsign = false\n' >"$DOTFILES/.config/git/local"

step "SSH key"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" -C "$(whoami)@$(hostname -s)"
  echo "ADD THIS KEY TO GITHUB (https://github.com/settings/keys):"
  cat "$HOME/.ssh/id_ed25519.pub"
fi
ssh-keygen -F github.com >/dev/null 2>&1 || ssh-keyscan -t ed25519 github.com >>"$HOME/.ssh/known_hosts" 2>/dev/null

step "nix-darwin ($HOST)"
if [ ! -e /run/current-system ]; then
  for f in /etc/zshrc /etc/zprofile /etc/bashrc; do
    [ -f "$f" ] && [ ! -L "$f" ] && sudo mv "$f" "$f.before-nix-darwin"
  done
fi
nix build "$DOTFILES/.nix#darwinConfigurations.$HOST.system" -o "$DOTFILES/result" &&
  sudo "$DOTFILES/result/sw/bin/darwin-rebuild" switch --flake "$DOTFILES/.nix#$HOST"
export PATH="/run/current-system/sw/bin:/opt/homebrew/bin:$HOME/.local/bin:$PATH"

step "Stow dotfiles"
stow -d "$DOTFILES" -t "$HOME" -R .
ln -sfn AGENTS.md "$HOME/CLAUDE.md"
chmod 600 "$DOTFILES/.ssh/config"

step "CLIs for agents"
[ "$(npm config get prefix)" = "$HOME/.npm-global" ] || npm config set prefix "$HOME/.npm-global"
npm ls -g things-cli >/dev/null 2>&1 || GIT_CONFIG_GLOBAL=/dev/null npm install -g github:flaviocopes/things-cli
mkdir -p "$HOME/.local/bin"
[ -x /Applications/Bear.app/Contents/MacOS/bearcli ] && ln -sfn /Applications/Bear.app/Contents/MacOS/bearcli "$HOME/.local/bin/bearcli"

step "FileVault off + auto-login (so the box survives reboots unattended)"
if fdesetup isactive >/dev/null 2>&1; then
  sudo fdesetup disable
  echo "Decryption runs in the background. Re-run this script once 'fdesetup status' says Off to enable auto-login."
elif ! defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser >/dev/null 2>&1; then
  sudo sysadminctl -autologin set -userName "$(whoami)" -password -
fi

step "Manual steps left"
cat <<'TODO'
- Sign in to the App Store, then re-run (masApps: Things, Bear, Slack, DevCleaner)
- Open Tailscale.app, log in, enable "Run on login"
- Add the printed SSH key to GitHub if it was just generated
- Launch Things + Bear once
- Grant Automation consent: run
    osascript -e 'tell application "Things3" to get count of to dos of list "Inbox"'
  over SSH, then approve the prompt on screen (or via Screen Sharing)
- Reboot once FileVault is off and auto-login is set, confirm SSH comes back
TODO
