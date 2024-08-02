# Setup macOS defaults
./setup-macos.sh

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Upgrade brew
brew upgrade

# Install packages
brew bundle

## Sdk man
curl -s "https://get.sdkman.io" | bash

echo "Installed all apps & utils!"

# Run stow
stow .
