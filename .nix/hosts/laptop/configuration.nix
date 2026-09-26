{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yt-dlp
  ];

  homebrew = {
    brews = [
      "mpv"
    ];
    casks = [
      "balenaetcher"
      "cleanshot"
      "daisydisk"
      "discord"
      "firefox"
      "fork"
      "handy"
      "home-assistant"
      "iina"
      "karabiner-elements"
      "minisim"
      "openlogi"
      "opencloud"
      "postman"
      "proxyman"
      "screen-studio"
      "spotify"
      "telegram"
      "the-unarchiver"
      "whatsapp"
      "zed"
      "zoom"
    ];
    masApps = {
      "Infuse" = 1136220934;
      "Keynote" = 409183694;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Parcel" = 375589283;
      "Spark" = 1176895641;
    };
  };

  system.defaults = {
    dock.persistent-apps = [
      { app = "/Applications/Spark.app"; }
      { app = "/Applications/Google Chrome.app"; }
      { app = "/Applications/Bear.app"; }
      { app = "/Applications/Things3.app"; }
      { app = "/Applications/Ghostty.app"; }
      { app = "/Applications/Spotify.app"; }
      { app = "/Applications/Discord.app"; }
    ];
  };
}
