{ pkgs, self, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    btop
    cmake
    coreutils
    curl
    delta
    direnv
    eza
    fd
    ffmpeg
    fzf
    gh
    git
    jq
    lazydocker
    lazygit
    neovim
    ninja
    nmap
    nodejs
    ripgrep
    ruby
    scrcpy
    sesh
    starship
    stow
    tree
    watchman
    yt-dlp
    yarn
    zoxide
    xcbeautify
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    taps = [
      "xcodesorg/made"
    ];
    brews = [
      "ccache"
      "cocoapods"
      "folly"
      "opencode"
      "pnpm"
      "python@3.9"
      "rbenv"
      "swiftlint"
      "tmux"
      "xcode-build-server"
    ];
    casks = [
      "1password"
      "android-platform-tools"
      "android-studio"
      "balenaetcher"
      "busycal"
      "claude"
      "cleanshot"
      "daisydisk"
      "docker"
      "firefox"
      "font-fira-code-nerd-font"
      "fork"
      "ghostty"
      "google-chrome"
      "home-assistant"
      "iina"
      "karabiner-elements"
      "screen-studio"
      "minisim"
      "obsidian"
      "opencloud"
      "postman"
      "private-internet-access"
      "proxyman"
      "raycast"
      "spotify"
      "tailscale-app"
      "telegram"
      "the-unarchiver"
      "whatsapp"
      "xcodes-app"
      "zed"
      "zoom"
      "zulu"
    ];
    masApps = {
      "Infuse" = 1136220934;
      "Keynote" = 409183694;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Slack" = 803453959;
      "Things" = 904280696;
      "Parcel" = 375589283;
      "Spark" = 1176895641;
      "DevCleaner" = 1388020431;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };

  nix.settings.experimental-features = "nix-command flakes";

  system.defaults = {
    dock.tilesize = 30;
    dock.magnification = true;
    dock.largesize = 60;
    dock.show-process-indicators = true;
    dock.mru-spaces = false;
    dock.autohide = true;

    finder.AppleShowAllExtensions = true;
    finder.FXEnableExtensionChangeWarning = false;
    finder.FXPreferredViewStyle = "Nlsv";
    finder.ShowPathbar = true;

    NSGlobalDomain.AppleScrollerPagingBehavior = true;
    NSGlobalDomain.NSTableViewDefaultSizeMode = 2;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;

    WindowManager.EnableStandardClickToShowDesktop = false;
  };

  system.primaryUser = "okwasniewski";
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
