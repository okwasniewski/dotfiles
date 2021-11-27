export ZSH="/Users/okwasniewski/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
  git
  zsh-autosuggestions
  web-search
  sudo
  copydir
  copyfile
  copybuffer
  dirhistory
  macos
  )

source $ZSH/oh-my-zsh.sh

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH=$PATH:~/.composer/vendor/bin
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$PATH:/Users/okwasniewski/Library/Android/sdk/platform-tools"
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools


export PATH="/opt/homebrew/opt/php@7.4/bin:$PATH"
export PATH="/opt/homebrew/opt/php@7.4/sbin:$PATH"
