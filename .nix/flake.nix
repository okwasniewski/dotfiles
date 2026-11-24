{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      mkDarwin =
        { host, user }:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs self user; };
          modules = [
            ./common/darwin.nix
            ./hosts/${host}/configuration.nix
          ];
        };
    in
    {
      darwinConfigurations = {
        laptop = mkDarwin {
          host = "laptop";
          user = "okwasniewski";
        };
        # Every runner shares this one profile, so the account name is the same on all of them.
        devbox = mkDarwin {
          host = "devbox";
          user = "bigmac";
        };
      };
    };
}
