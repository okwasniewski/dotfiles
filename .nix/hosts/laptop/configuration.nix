{ pkgs, user, ... }:

{
  environment.systemPackages = with pkgs; [
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
      "aside"
      "chatgpt"
      "cleanshot"
      "cotypist"
      "discord"
      "figma"
      "font-geist-mono"
      "font-inter"
      "font-lato"
      "font-lexend"
      "font-stack-sans-notch"
      "grammarly-desktop"
      "grok-bot"
      "hermes-desktop"
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
      "rode-central"
      "screen-studio"
      "spotify"
      "superhuman"
      "telegram"
      "whatsapp"
      "willow-voice"
      "zed"
      "zoom"
      "zulu@21"
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Fantastical" = 975937182;
      "Numbers" = 409203825;
      "Parcel" = 375589283;
      "Pure Paste" = 1611378436;
      "reMarkable" = 1276493162;
      "Spark" = 1176895641;
      "Yubico Authenticator" = 1497506650;
    };
  };

  system.defaults.dock = {
    persistent-apps = [
      { app = "/Applications/Spark.app"; }
      { app = "/Applications/Aside.app"; }
      { app = "/Applications/Bear.app"; }
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
}
