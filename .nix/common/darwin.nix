{
  self,
  pkgs,
  user,
  ...
}:

{
  imports = [
    ./nix.nix
    ./packages.nix
  ];

  environment.systemPackages = with pkgs; [
    pam-reattach
    xcbeautify
  ];

  system.primaryUser = user;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    taps = [
      "oven-sh/bun"
      "xcodesorg/made"
    ];
    brews = [
      "ccache"
      "cloudflared"
      "cocoapods"
      "folly"
      "opencode"
      "stripe-cli"
      "pnpm"
      "python@3.13"
      "ruby@3.4"
      "swiftlint"
      "swiftformat"
      "mole"
      "tmux"
      "oven-sh/bun/bun"
      "xcode-build-server"
      "postgresql@16"
    ];
    casks = [
      "1password"
      "android-platform-tools"
      "android-studio"
      "claude-code"
      "docker-desktop"
      "font-fira-code-nerd-font"
      "ghostty"
      "google-chrome"
      "raycast"
      "tailscale-app"
      "xcodes-app"
      "zulu"
    ];
    masApps = {
      "Bear" = 1091189122;
      "DevCleaner" = 1388020431;
      "Slack" = 803453959;
      "Things" = 904280696;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  system.defaults = {
    dock.tilesize = 35;
    dock.magnification = true;
    dock.largesize = 60;
    dock.show-process-indicators = true;
    dock.show-recents = false;
    dock.mru-spaces = false;
    dock.autohide = true;

    finder.AppleShowAllExtensions = true;
    finder.FXEnableExtensionChangeWarning = false;
    finder.FXPreferredViewStyle = "Nlsv";
    finder.ShowPathbar = true;
    finder.FXDefaultSearchScope = "SCcf";
    finder.FXRemoveOldTrashItems = true;

    screencapture.location = "~/Downloads";

    NSGlobalDomain.AppleScrollerPagingBehavior = true;
    NSGlobalDomain.NSTableViewDefaultSizeMode = 2;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.AppleIconAppearanceTheme = "ClearDark";
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
    NSGlobalDomain.AppleShowAllFiles = true;

    WindowManager.EnableStandardClickToShowDesktop = false;

    CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Disable 'Cmd + Space' for Spotlight Search
          "64" = {
            enabled = false;
          };
          # Disable 'Cmd + Alt + Space' for Finder search window
          "65" = {
            # Set to false to disable
            enabled = true;
          };
          # Disable 'Cmd + Shift + 3' for screenshots
          "28" = {
            enabled = false;
          };
          # Disable 'Cmd + Shift + 4' for screenshot selection
          "30" = {
            enabled = false;
          };
          # Disable 'Cmd + Shift + 5' for screenshots
          "184" = {
            enabled = false;
          };
        };
      };
    };
  };

  system.activationScripts.postActivation.text = ''
    # Activate system settings without logout
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
