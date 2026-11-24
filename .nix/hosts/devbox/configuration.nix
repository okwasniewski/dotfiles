# Runner (Big Mac and any other): agents, mobile builds and local services, no desktop apps.
{ ... }:

{
  imports = [
    ../../common/backend.nix
    ../../common/headless.nix
    ../../common/mobile.nix
  ];

  homebrew.casks = [
    "google-chrome"
    "t3-code@nightly"
  ];
}
