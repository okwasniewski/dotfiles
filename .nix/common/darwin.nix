# Every Mac: nix, shell, the CLI base and macOS defaults. Apps and toolchains
# live in the modules a host picks (mobile.nix, backend.nix, headless.nix).
{
  self,
  lib,
  pkgs,
  user,
  machineName,
  ...
}:

{
  imports = [
    ./nix.nix
    ./packages.nix
  ];

  system.primaryUser = user;

  # Shown in Finder, T3 Code and AirDrop; the lowercase form is the network and
  # Tailscale name (`ssh devmac`).
  networking = {
    computerName = machineName;
    hostName = lib.toLower machineName;
    localHostName = lib.toLower machineName;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    taps = [
      "oven-sh/bun"
    ];
    brews = [
      "cloudflared"
      "mole"
      "opencode"
      "oven-sh/bun/bun"
      "pnpm"
      "python@3.15"
      "tmux"
    ];
    casks = [
      "tailscale-app"
    ];
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
  };

  system.activationScripts.postActivation.text = ''
    # Activate system settings without logout
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
