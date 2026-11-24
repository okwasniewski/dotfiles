# Runner: agents and mobile builds, no desktop apps.
{ ... }:

{
  imports = [
    ../../common/headless.nix
    ../../common/mobile.nix
  ];
}
