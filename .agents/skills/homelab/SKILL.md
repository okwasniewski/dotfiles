---
name: homelab
description: Inventory and SSH access for Oskar's tailnet devices (bigmac and devmac Mac minis, zima selfhost box, nas). Use when asked to jump on a box, update, check, or manage anything on the homelab / tailnet / bigmac / devmac / nas / zima.
---

# Homelab

All devices live in the tailnet with MagicDNS. SSH works directly by hostname,
auth via 1Password SSH agent (`IdentityAgent` set in `~/.ssh/config`). No
passwords needed, just `ssh <host> '<cmd>'`.

## Devices

- `bigmac` - BigMac, the main dev box (Mac mini, user `bigmac`, nix host
  `devbox-bigmac`). Agents run here, see `WORKFLOW.md` in the dotfiles.
- `devmac` - DevMac, second dev box (Mac mini, user `okwasniewski`, nix host
  `devbox-okwasniewski`). T3 Code Nightly runs as a background service, on
  T3 Connect.
- `zima` - selfhosting box (ZimaBoard, Ubuntu). Everything runs in Docker.
- `nas` - backups, photos, self-hosted cloud (Ubuntu, RAID1 storage on
  `/mnt/storage`). Services run in Docker.

Other tailnet devices (`macbook`, phones, TV) have no SSH - list with
`tailscale status`.

## Conventions

- Service details and compose configs live in the private `homelab` repo,
  cloned to `~/homelab` on zima and nas (`~/homelab/<host>/<service>/compose.yml`).
  Edit there, commit, push. Discover what runs where via `docker ps` on the box.
- Docker works without sudo on both Linux boxes. Update a service:
  `ssh zima 'cd ~/homelab/zima/<service> && docker compose pull && docker compose up -d'`
- `sudo` requires a password - for apt upgrades or reboots ask Oskar to run
  interactively (`! ssh -t zima 'sudo apt upgrade'`)
- Reboots only when Oskar confirms.
