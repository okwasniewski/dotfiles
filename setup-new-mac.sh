#Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

#Upgrade brew
brew upgrade

#Install packages
brew install git
brew install yarn
brew install node
brew install nvm
brew install mariadb
brew install php@7.4
brew install zsh-completions
brew install neofetch
brew install composer

#Casks
brew install --cask google-chrome
brew install --cask brave-browser
brew install --cask figma
brew install --cask visual-studio-code
brew install --cask fig
brew install --cask obsidian
brew install --cask 1password
brew install --cask raycast
brew install --cask raindropio
brew install --cask cleanshot
brew install --cask iina
brew install --cask notion
brew install --cask iterm2
brew install --cask calibre
brew install --cask utm
brew install --cask insomnia

#Install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#Rosetta 2
softwareupdate --install-rosetta --agree-to-license

#React native
brew install watchman
brew install cocoapods
gem install ffi
brew install --cask adoptopenjdk/openjdk/adoptopenjdk8

echo "Installed all apps & utils!"