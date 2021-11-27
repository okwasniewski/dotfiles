# New mac 💻

### 1. Install XCode

### 2. Setup SSH

- Generate key

```sh
ssh-keygen -t rsa -C "oskarkwasniewski@icloud.com"
```

- Copy key

```sh
pbcopy < .ssh/id_rsa.pub
```

- Paste key to Github (Settings > SSH and GPG keys > New SSH key)

### 3. Clone this repo

```sh
git clone git@github.com:okwasniewski/dotfiles.git ~/.dotfiles
```

### 4. Install apps

```sh
sh ~/.dotfiles/setup-new-mac.sh
```

### 4. Setup MacOS

```sh
source ~/.dotfiles/setup-macos.sh
```

### 5. Setup symlinks

```sh
source ~/.dotfiles/setup-symlinks.sh
```

## Install apps from appstore:

### Utils

- [Amphetamine](https://apps.apple.com/us/app/amphetamine/id937984704?mt=12)
- [The unarchiver](https://apps.apple.com/us/app/the-unarchiver/id425424353?mt=12)
- [Klokki slim](https://apps.apple.com/us/app/klokki-slim-time-tracking/id1459795140?mt=12)
- [Magnet](https://apps.apple.com/us/app/magnet/id441258766?mt=12)
- [Color slurp](https://apps.apple.com/us/app/colorslurp/id1287239339?mt=12)
- [DevCleaner for XCode](https://apps.apple.com/us/app/devcleaner-for-xcode/id1388020431?mt=12)
- [Monitor control](https://github.com/MonitorControl/MonitorControl)
- [RDM](https://github.com/usr-sse2/RDM)
- [Python - MiniForge](https://github.com/conda-forge/miniforge)

### Apps

- [Things 3](https://apps.apple.com/us/app/things-3/id904280696?mt=12)
- [Spark](https://apps.apple.com/us/app/spark-email-app-by-readdle/id1176895641?mt=12)
- [Microsoft Remote desktop](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466?mt=12)
- [Sequel Ace](https://apps.apple.com/us/app/sequel-ace/id1518036000?mt=12)
- [Adobe XD](https://helpx.adobe.com/xd/get-started.html)
- [Android Studio](https://developer.android.com/studio)
- [Aruba VIA](https://apps.apple.com/us/app/aruba-via/id1439900554?mt=12)
- [PHP Storm](https://www.jetbrains.com/phpstorm/)
- [Web Storm](https://www.jetbrains.com/webstorm/)
- [Affinity photo](https://affinity.serif.com/en-gb/photo/)
