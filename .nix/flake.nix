{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        bat
        cmake
        coreutils
        curl
        direnv
        eza
        btop
        lazydocker
        ffmpeg
        fzf
        git
        delta
        lazygit
        neovim
        ninja
        nmap
        nodejs
        ripgrep
        ruby
        scrcpy
        starship
        tree
        watchman
        yarn
        zoxide
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
          "nvm"
          "python@3.9"
          "rbenv"
          "swiftlint"
          "tmux"
          "xcode-build-server"
          "opencode"
          "pnpm"
        ];
        casks = [
          "1password"
          "balenaetcher"
          "android-platform-tools"
          "google-chrome"
          "cleanshot"
          "font-fira-code-nerd-font"
          "fork"
          "ghostty"
          "minisim"
          "obsidian"
          "raycast"
          "spotify"
          "xcodes-app"
        ];
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableBashCompletion = true;
      };

      environment.variables = {
        ANDROID_HOME = "$HOME/Library/Android/sdk";
        LANG = "en_US.UTF-8";
        EDITOR = "nvim";
        VISUAL = "nvim";
        REACT_EDITOR = "nvim";
      };

      nix.settings.experimental-features = "nix-command flakes";

      system.primaryUser = "okwasniewski";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
