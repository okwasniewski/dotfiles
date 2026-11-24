# The main runner: a devbox that also hosts T3 Code and local services.
{ ... }:

{
  imports = [
    ../devbox/configuration.nix
    ../../common/backend.nix
  ];

  homebrew.casks = [
    "google-chrome"
    "t3-code@nightly"
  ];
}
