# Dotfiles

1. Clone this repo to `~/`

```sh
git clone git@github.com:okwasniewski/dotfiles.git
```

2. Install Nix (Lix)

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

3. Build and activate nix-darwin

```sh
cd ~/dotfiles
nix build ./.nix#darwinConfigurations.default.system --extra-experimental-features "nix-command flakes"
./result/sw/bin/darwin-rebuild switch --flake ./.nix#default
```

4. Run `stow .` to symlink dotfiles

5. Fix SSH config permissions

```sh
chmod 600 ~/.ssh/config
```
