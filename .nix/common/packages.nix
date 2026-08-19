{ pkgs, ... }:

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
    mosh
    neovim
    ninja
    nixd
    nmap
    nodejs
    ripgrep
    scrcpy
    sesh
    starship
    stow
    tree
    watchman
    yarn
    zoxide
    yazi
  ];
}
