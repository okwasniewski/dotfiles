{ self, pkgs, ... }:

let
  user = "okwasniewski";
in
{
  imports = [
    ../../common/nix.nix
    ../../common/packages.nix
  ];

  environment.systemPackages = with pkgs; [
    pam-reattach
    xcbeautify
    yt-dlp
  ];

  system.primaryUser = user;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    taps = [
      "max-sixty/worktrunk"
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
      "mole"
      "tmux"
      "max-sixty/worktrunk/wt"
      "xcode-build-server"
    ];
    casks = [
      "1password"
      "android-platform-tools"
      "android-studio"
      "balenaetcher"
      "busycal"
      "claude-code"
      "cleanshot"
      "ghostty"
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
      "logitech-options"
      "proxyman"
      "raycast"
      "handy"
      "discord"
      "spotify"
      "tailscale-app"
      "telegram"
      "private-internet-access"
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
    dock.persistent-apps = [
      { app = "/Applications/Spark.app"; }
      { app = "/Applications/Google Chrome.app"; }
      { app = "/Applications/BusyCal.app"; }
      { app = "/Applications/Obsidian.app"; }
      { app = "/Applications/Things3.app"; }
      { app = "/Applications/Ghostty.app"; }
      { app = "/Applications/Spotify.app"; }
      { app = "/Applications/Discord.app"; }
    ];

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
