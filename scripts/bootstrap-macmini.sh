#!/usr/bin/env bash
# Bootstrap a Mac mini as a headless remote workhorse.
# Idempotent - safe to re-run. Run interactively (some steps need sudo / one-time GUI actions).
#
#   curl -fsSL https://raw.githubusercontent.com/okwasniewski/dotfiles/main/scripts/bootstrap-macmini.sh | bash
#   or: ~/dotfiles/scripts/bootstrap-macmini.sh
set -uo pipefail

DOTFILES="$HOME/dotfiles"
step() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }

step "Xcode Command Line Tools"
xcode-select -p >/dev/null 2>&1 || xcode-select --install

step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

step "Clone dotfiles"
[ -d "$DOTFILES/.git" ] || git clone https://github.com/okwasniewski/dotfiles.git "$DOTFILES"

step "Symlinks: home"
for f in .zshrc .zprofile .zsh_secrets .config .agents .nix AGENTS.md WORKFLOW.md; do
  [ -e "$DOTFILES/$f" ] && ln -sfn "dotfiles/$f" "$HOME/$f"
done
ln -sfn AGENTS.md "$HOME/CLAUDE.md"

step "Symlinks: ssh + claude"
mkdir -p "$HOME/.ssh" "$HOME/.claude"
chmod 700 "$HOME/.ssh"
ln -sfn ../dotfiles/.ssh/config "$HOME/.ssh/config"
for f in .mcp.json commands hooks settings.json settings.local.json skills; do
  [ -e "$DOTFILES/.claude/$f" ] && ln -sfn "../dotfiles/.claude/$f" "$HOME/.claude/$f"
done

step "Machine-local overrides (headless box: local ssh key, no 1Password)"
[ -f "$HOME/.ssh/local_config" ] || printf 'Host *\n  IdentityAgent none\n' > "$HOME/.ssh/local_config"
[ -f "$HOME/.zshrc.local" ] || touch "$HOME/.zshrc.local"
[ -f "$HOME/.config/git/local" ] || printf '[core]\n\tpager = cat\n[commit]\n\tgpgsign = false\n' > "$HOME/.config/git/local"

step "SSH key"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" -C "$(whoami)@$(hostname -s)"
  echo "ADD THIS KEY TO GITHUB (https://github.com/settings/keys):"
  cat "$HOME/.ssh/id_ed25519.pub"
fi

step "Headless power + remote access (sudo)"
sudo pmset -a sleep 0 displaysleep 10 womp 1 powernap 1 autorestart 1
sudo systemsetup -setremotelogin on 2>/dev/null
sudo launchctl enable system/com.apple.screensharing 2>/dev/null
sudo launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true

step "Daily dotfiles auto-pull (launchd)"
PLIST="$HOME/Library/LaunchAgents/dev.oskar.dotfiles-pull.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>dev.oskar.dotfiles-pull</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/git</string>
    <string>-C</string><string>$DOTFILES</string>
    <string>pull</string><string>--ff-only</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict><key>Hour</key><integer>9</integer><key>Minute</key><integer>0</integer></dict>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>/tmp/dotfiles-pull.log</string>
  <key>StandardErrorPath</key><string>/tmp/dotfiles-pull.log</string>
</dict>
</plist>
EOF
launchctl bootout "gui/$(id -u)/dev.oskar.dotfiles-pull" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"

step "Core tools"
brew install node gh 2>/dev/null || true
brew install --cask tailscale 2>/dev/null || true
npm ls -g things-cli >/dev/null 2>&1 || GIT_CONFIG_GLOBAL=/dev/null npm install -g github:flaviocopes/things-cli
[ -x /Applications/Bear.app/Contents/MacOS/bearcli ] && ln -sf /Applications/Bear.app/Contents/MacOS/bearcli /opt/homebrew/bin/bearcli

step "Manual steps left"
cat <<'TODO'
- System Settings > Users & Groups: enable auto-login (needed so SSH survives reboots)
- Keep FileVault OFF on this box (fdesetup status)
- Open Tailscale.app, log in, enable "Run on login"
- Add the printed SSH key to GitHub if it was just generated
- App Store: install Things 3 + Bear, launch each once
- Grant Automation consent: run
    osascript -e 'tell application "Things3" to get count of to dos of list "Inbox"'
  over SSH, then approve the prompt on screen (or via Screen Sharing)
TODO
