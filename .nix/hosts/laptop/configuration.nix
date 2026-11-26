# The main machine: everything a devbox has, plus the desktop.
{ pkgs, user, ... }:

{
  imports = [
    ../../common/backend.nix
    ../../common/mobile.nix
  ];

  environment.systemPackages = with pkgs; [
    nixd
    nmap
    yt-dlp
  ];

  homebrew = {
    taps = [
      "nkzw-tech/tap"
    ];
    brews = [
      "awscli"
      "mpv"
      "switchaudio-osx"
    ];
    casks = [
      "1password"
      "aside"
      "chatgpt"
      "cleanshot"
      "cotypist"
      "discord"
      "figma"
      "font-fira-code-nerd-font"
      "font-geist-mono"
      "font-inter"
      "font-lato"
      "font-lexend"
      "font-stack-sans-notch"
      "ghostty"
      "google-chrome"
      "grammarly-desktop"
      "grok-bot"
      "insta360-link-controller"
      "karabiner-elements"
      "linear"
      "minisim"
      "nkzw-tech/tap/codiff"
      "notion"
      "opencloud"
      "openlogi"
      "paper-design"
      "plaud"
      "protonvpn"
      "raycast"
      "rode-central"
      "screen-studio"
      "spotify"
      "superhuman"
      "t3-code@nightly"
      "telegram"
      "whatsapp"
      "willow-voice"
      "zed"
      "zoom"
      "zulu@21"
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Craft" = 1487937127;
      "DevCleaner" = 1388020431;
      "Fantastical" = 975937182;
      "Parcel" = 375589283;
      "Pure Paste" = 1611378436;
      "reMarkable" = 1276493162;
      "Slack" = 803453959;
      "Spark" = 1176895641;
      "Things" = 904280696;
      "Yubico Authenticator" = 1497506650;
    };
  };

  system.defaults.dock = {
    persistent-apps = [
      { app = "/Applications/Spark.app"; }
      { app = "/Applications/Aside.app"; }
      { app = "/Applications/Craft.app"; }
      { app = "/Applications/Things3.app"; }
      { app = "/Applications/Ghostty.app"; }
      { app = "/Applications/Spotify.app"; }
      { app = "/Applications/Fantastical.app"; }
      { app = "/Applications/Discord.app"; }
      { app = "/Applications/Superhuman.app"; }
      { app = "/Applications/Slack.app"; }
      { app = "/Applications/Grok Bot.app"; }
      { app = "/Applications/T3 Code (Nightly).app"; }
    ];
    persistent-others = [
      { folder = "/Users/${user}/Downloads"; }
    ];
    # Quick Note
    wvous-br-corner = 14;
  };

  # Raycast and CleanShot take over these shortcuts.
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
    # Spotlight search (Cmd + Space)
    "64".enabled = false;
    # Finder search window (Cmd + Alt + Space)
    "65".enabled = true;
    # Screenshots (Cmd + Shift + 3, 4, 5)
    "28".enabled = false;
    "30".enabled = false;
    "184".enabled = false;
  };
}
