{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    btop
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
    lazygit
    mosh
    neovim
    nodejs
    pam-reattach
    ripgrep
    sesh
    starship
    stow
    tree
    uv
    zoxide
    yazi
  ];
}
