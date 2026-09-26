# Dotfiles

1. Clone this repo to `~/`

```sh
git clone git@github.com:okwasniewski/dotfiles.git
```

2. Install Nix (Lix)

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

3. Build and activate nix-darwin (host: `laptop` or `macmini`)

```sh
cd ~/dotfiles
nix build ./.nix#darwinConfigurations.laptop.system --extra-experimental-features "nix-command flakes"
sudo ./result/sw/bin/darwin-rebuild switch --flake ./.nix#laptop
```

Mac mini: run `scripts/bootstrap-macmini.sh` instead, see `WORKFLOW.md`.

4. Run `stow .` to symlink dotfiles

5. Fix SSH config permissions

```sh
chmod 600 ~/.ssh/config
```
