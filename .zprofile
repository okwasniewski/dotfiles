# Environment and PATH for every login shell, interactive or not.
#
# This must not live in .zshrc: `zsh -lc ...` is a login but non-interactive
# shell, so it never sources .zshrc. herdr runs custom command bindings that
# way, and a launchd-started herdr server has no inherited PATH at all, so
# anything a popup or agent pane needs has to be resolvable from here.
#
# Sourced after /etc/zprofile, so these prepends stay ahead of the nix paths.

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby@3.4/bin:$PATH"

# Android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"
export PATH="$HOME/.grok/bin:$PATH"

# Environment
export LANG=en_US.UTF-8
export REACT_EDITOR=nvim
export EDITOR=nvim
export VISUAL=nvim
export XDG_CONFIG_HOME="$HOME/.config"

# Secrets, exported here so non-interactive tools (lazygit's commit message
# generator, agent panes) can see them too.
if [ -f "$HOME/.zsh_secrets" ]; then
  set -a
  . "$HOME/.zsh_secrets"
  set +a
fi
