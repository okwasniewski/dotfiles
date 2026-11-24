# Local services for web and backend work.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    lazydocker
  ];

  homebrew = {
    brews = [
      "postgresql@16"
      "stripe-cli"
    ];
    casks = [
      "docker-desktop"
    ];
  };
}
