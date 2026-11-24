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

      # Every runner is a devbox and differs only by its macOS account. Listing an
      # account here creates the `devbox-<account>` host that bootstrap.sh picks.
      devboxUsers = [
        "bigmac"
        "okwasniewski"
      ];
    in
    {
      darwinConfigurations = {
        laptop = mkDarwin {
          host = "laptop";
          user = "okwasniewski";
        };
      }
      // nixpkgs.lib.genAttrs' devboxUsers (user: {
        name = "devbox-${user}";
        value = mkDarwin {
          host = "devbox";
          inherit user;
        };
      });
    };
}
