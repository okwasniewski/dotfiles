#!/bin/zsh
# Read-only inventory of a Mac before migrating: apps and how recently they
# were used, Dock, Homebrew, mas, nix, global CLIs, login items, macOS defaults
# and dotfiles state. Prints values only for settings, never secrets.
# Usage: scripts/mac-inventory.sh > ~/Desktop/inventory-$(hostname -s).txt
setopt null_glob
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1
section() { printf '\n## %s\n' "$1"; }
has() { command -v "$1" >/dev/null 2>&1; }

section "machine"
scutil --get ComputerName
hostname -s
sysctl -n hw.model
sw_vers -productVersion
uname -m
echo "shell=$SHELL"
grep -h DARWIN_HOST ~/.zshrc.local 2>/dev/null

section "apps (path | bundle id | version | mas id | last used | use count)"
for app in /Applications/*.app /Applications/*/*.app ~/Applications/*.app /Applications/Setapp/*.app; do
  plist="$app/Contents/Info.plist"
  [ -f "$plist" ] || continue
  id=$(defaults read "$plist" CFBundleIdentifier 2>/dev/null)
  ver=$(defaults read "$plist" CFBundleShortVersionString 2>/dev/null)
  mas=-
  [ -d "$app/Contents/_MASReceipt" ] && mas=$(mdls -raw -name kMDItemAppStoreAdamID "$app" 2>/dev/null)
  used=$(mdls -raw -name kMDItemLastUsedDate "$app" 2>/dev/null | cut -c1-10)
  count=$(mdls -raw -name kMDItemUseCount "$app" 2>/dev/null)
  echo "$app | $id | $ver | $mas | $used | $count"
done

section "dock apps"
defaults read com.apple.dock persistent-apps 2>/dev/null | sed -n 's/.*"_CFURLString" = "\(.*\)";/\1/p'
section "dock others"
defaults read com.apple.dock persistent-others 2>/dev/null | sed -n 's/.*"_CFURLString" = "\(.*\)";/\1/p'
section "dock prefs"
for k in tile-size magnification largesize autohide autohide-delay orientation show-recents mru-spaces show-process-indicators minimize-to-application mineffect wvous-tl-corner wvous-tr-corner wvous-bl-corner wvous-br-corner; do
  echo "$k=$(defaults read com.apple.dock $k 2>/dev/null)"
done

section "running apps"
osascript -e 'tell application "System Events" to get name of every application process whose background only is false' 2>/dev/null | tr ',' '\n' | sed 's/^ //'

section "login items"
osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | tr ',' '\n' | sed 's/^ //'
section "user launch agents"
ls ~/Library/LaunchAgents 2>/dev/null

section "homebrew taps"
has brew && brew tap
section "homebrew formulae (on request)"
has brew && brew list --formula --installed-on-request -1
section "homebrew casks"
has brew && brew list --cask -1
section "mas"
has mas && mas list

section "nix"
readlink /run/current-system 2>/dev/null
has nix && nix profile list 2>/dev/null | sed -n 's/^Name: *//p'
ls /run/current-system/sw/bin 2>/dev/null | tr '\n' ' '; echo

section "global js packages"
has npm && npm ls -g --depth=0 2>/dev/null
ls ~/.npm-global/lib/node_modules 2>/dev/null
has pnpm && pnpm ls -g --depth=0 2>/dev/null
ls ~/.bun/install/global/node_modules 2>/dev/null
section "other tool bins"
for d in ~/.local/bin ~/.bun/bin ~/.cargo/bin ~/go/bin ~/.opencode/bin ~/Library/pnpm; do
  [ -d "$d" ] && echo "$d: $(ls "$d" | tr '\n' ' ')"
done
has uv && echo "uv tools: $(uv tool list 2>/dev/null | grep -v '^-' | tr '\n' ' ')"
has pipx && echo "pipx: $(pipx list --short 2>/dev/null | tr '\n' ' ')"

section "dev toolchains"
ls -d /Applications/Xcode*.app 2>/dev/null
xcode-select -p 2>/dev/null
xcrun simctl list runtimes 2>/dev/null | grep -v '^==' | sed 's/ (.*//'
ls ~/Library/Android/sdk 2>/dev/null | tr '\n' ' '; echo
ls ~/Library/Android/sdk/platforms ~/Library/Android/sdk/system-images 2>/dev/null | tr '\n' ' '; echo
/usr/libexec/java_home -V 2>&1 | sed -n 's/^ *//p' | head -5
has ruby && ruby -v
has node && echo "node $(node -v)"

section "home dotdirs and ~/.config (names only)"
ls -A ~ | grep '^\.' | tr '\n' ' '; echo
ls -A ~/.config | tr '\n' ' '; echo
section "symlinks into dotfiles"
for f in ~/.* ~/* ~/.config/*; do
  [ -L "$f" ] && echo "$f -> $(readlink "$f")"
done | grep -i dotfiles

section "dotfiles repo"
if [ -d ~/dotfiles/.git ]; then
  git -C ~/dotfiles status -sb | head -30
  git -C ~/dotfiles stash list
fi

section "local overrides (names only, no values)"
for f in ~/.zshrc.local ~/.zsh_secrets ~/.ssh/local_config ~/.config/git/local; do
  [ -f "$f" ] || { echo "$f: missing"; continue; }
  echo "$f: $(grep -oE '^(export +)?[A-Za-z_][A-Za-z0-9_]*=|^Host +.*|^\[[^]]*\]' "$f" | tr '\n' ' ')"
done
ls ~/.ssh 2>/dev/null | tr '\n' ' '; echo

section "macOS defaults"
for pair in \
  NSGlobalDomain:KeyRepeat NSGlobalDomain:InitialKeyRepeat NSGlobalDomain:AppleInterfaceStyle \
  NSGlobalDomain:AppleInterfaceStyleSwitchesAutomatically NSGlobalDomain:AppleShowAllFiles \
  NSGlobalDomain:AppleShowAllExtensions NSGlobalDomain:ApplePressAndHoldEnabled \
  NSGlobalDomain:com.apple.swipescrolldirection NSGlobalDomain:NSAutomaticSpellingCorrectionEnabled \
  NSGlobalDomain:NSAutomaticQuoteSubstitutionEnabled NSGlobalDomain:NSAutomaticDashSubstitutionEnabled \
  NSGlobalDomain:AppleIconAppearanceTheme NSGlobalDomain:_HIHideMenuBar \
  com.apple.finder:FXPreferredViewStyle com.apple.finder:ShowPathbar com.apple.finder:ShowStatusBar \
  com.apple.finder:NewWindowTarget com.apple.finder:FXDefaultSearchScope \
  com.apple.screencapture:location com.apple.screencapture:type \
  com.apple.AppleMultitouchTrackpad:Clicking com.apple.AppleMultitouchTrackpad:TrackpadThreeFingerDrag \
  com.apple.WindowManager:EnableStandardClickToShowDesktop com.apple.WindowManager:EnableTiledWindowMargins \
  com.apple.controlcenter:BatteryShowPercentage com.apple.menuextra.clock:IsAnalog; do
  echo "$pair=$(defaults read "${pair%%:*}" "${pair#*:}" 2>/dev/null)"
done

section "fonts (user)"
ls ~/Library/Fonts 2>/dev/null | sed 's/\.[^.]*$//' | sort -u | tr '\n' ' '; echo

section "top shell commands (first word only)"
LC_ALL=C sed 's/^: [0-9]*:[0-9]*;//' ~/.zsh_history 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -rn | head -60 | awk '{printf "%s:%s ", $2, $1}'; echo
