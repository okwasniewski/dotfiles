---
name: homelab
description: Inventory and SSH access for Oskar's tailnet devices (dev box Mac mini, zima selfhost box, nas). Use when asked to jump on a box, update, check, or manage anything on the homelab / tailnet / dev box / nas / zima.
---

# Homelab

All devices live in the tailnet with MagicDNS. SSH works directly by hostname,
auth via 1Password SSH agent (`IdentityAgent` set in `~/.ssh/config`). No
passwords needed, just `ssh <host> '<cmd>'`.

## Devices

- `oskars-macmini` - dev box (macOS, Apple Silicon). New Mac mini replacing it
  ~2026-10, update this file when it lands.
- `zima` - selfhosting box (ZimaBoard, Ubuntu). Everything runs in Docker.
- `nas` - backups, photos, self-hosted cloud (Ubuntu, RAID1 storage on
  `/mnt/storage`). Services run in Docker.

Other tailnet devices (phones, laptops, TV) have no SSH - list with
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
