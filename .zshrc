# Interactive shell config. PATH and exported environment live in .zprofile
# so non-interactive login shells (herdr command bindings) get them too.

# Aliases
alias ls="eza -a --no-user --no-time"
alias cat="bat"
alias lg="lazygit"
alias :q="exit"
alias vim="nvim"
alias oc="OPENCODE_EXPERIMENTAL_PLAN_MODE=1 opencode"

# Agents skip permission prompts (interactive shells only, scripts unaffected)
alias claude="claude --dangerously-skip-permissions"
alias codex="codex --dangerously-bypass-approvals-and-sandbox"

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

## React Native Aliases
alias pod-install-new="bundle install && RCT_NEW_ARCH_ENABLED=1 bundle exec pod install"
alias pod-install-old="bundle install && bundle exec pod install"

# Setup aliases for nix
alias nix-rebuild="sudo darwin-rebuild switch --flake $HOME/.nix#default"

set -o vi
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions, full compinit only when the dump is older than 24h
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zinit cdreplay -q

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

[ -z "$DISABLE_ZOXIDE" ] && eval "$(zoxide init --cmd cd zsh)"

eval "$(starship init zsh)"

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Herdr completion, cached until the binary changes
if command -v herdr >/dev/null 2>&1; then
  _herdr_comp="${XDG_CACHE_HOME:-$HOME/.cache}/herdr-completion.zsh"
  if [ ! -f "$_herdr_comp" ] || [ "$(command -v herdr)" -nt "$_herdr_comp" ]; then
    mkdir -p "${_herdr_comp:h}" && herdr completion zsh > "$_herdr_comp"
  fi
  source "$_herdr_comp"
  unset _herdr_comp
fi

[ -f "$HOME/.daytona.completion_script.zsh" ] && source "$HOME/.daytona.completion_script.zsh"
