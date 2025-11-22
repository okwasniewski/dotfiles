export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=~/Library/Android/sdk/tools:$PATH
export PATH=~/Library/Android/sdk/platform-tools:$PATH
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH=/opt/homebrew/bin:$PATH

# Aliases
alias ls="eza -a --no-user --no-time"
alias cat="bat"
alias lg="lazygit"
alias compress-video="sh $HOME/scripts/compress-video.sh"
alias :q="exit"
alias clear="clear && tmux clear-history"

## React Native Aliases
alias pod-install-new="bundle install && RCT_NEW_ARCH_ENABLED=1 bundle exec pod install"
alias pod-install-old="bundle install && bundle exec pod install"

## VPS
alias mikrus="ssh root@adam120.mikrus.xyz -p 10120"

# Load zsh secrets
[ -f "$HOME/.zsh_secrets" ] && source "$HOME/.zsh_secrets"

export LANG=en_US.UTF-8
export REACT_EDITOR=nvim
export EDITOR=nvim
export VISUAL=nvim
set -o vi

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

# Load completions
autoload -Uz compinit && compinit

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

eval "$(zoxide init --cmd cd zsh)"

eval "$(starship init zsh)"
