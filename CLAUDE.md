# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal NixOS + Home Manager dotfiles. The flake lives in `nixos/landseal/`; the
repo root also holds the raw config files (`.config/`, `.bashrc`, `.p10k.zsh`,
`.vimrc`) that Home Manager symlinks into place.

## Version control: jj (Jujutsu)

This repo is driven with **jj**, colocated with git (both `.jj/` and `.git/`
exist). Use `jj` commands, not `git`, for normal work:
- `jj st` / `jj log` — status and history
- `jj describe -m "..."` — set the current change's message
- `jj new` — start a new change
- `jj bookmark set main -r @-` then `jj git push` — advance and push `main`
The git CLI still works for read-only inspection, but jj owns the working copy.
Signing is configured in Nix (`signing.behavior = "drop"` in jj, SSH key in git).

## Build / apply

Rebuild a host from the flake (run from anywhere; adjust the `#host`):

```sh
sudo nixos-rebuild switch --flake /home/landseal/dotfiles/nixos/landseal#laptop
```

Hosts (flake outputs in `nixos/landseal/flake.nix`): `laptop`, `steambox`.
`laptop` tracks `nixpkgs-unstable`; **`steambox` is pinned to `nixpkgs-2605`**
(NixOS 26.05) via a separate `lib.nixosSystem`. `steambox` runs on the *desktop*
hardware, so it imports `hosts/desktop-hardware-configuration.nix` — that
"desktop"-named file is kept even though there is no longer a `desktop` host.

Other common commands:
- `nix flake update` (in `nixos/landseal/`) — bump all inputs
- `nix flake check` / `nixos-rebuild build --flake ...#host` — evaluate/build without switching
- `home-manager` is **not** standalone here — it runs as a NixOS module, so it is
  applied by `nixos-rebuild`, never by a separate `home-manager switch`.

## Architecture

Module layering, top down:

- **`flake.nix`** defines the two `nixosConfigurations` and injects `inputs`
  through `specialArgs`. `allowUnfree` is set once in `commonModules`.
  - **Per-host input pinning.** `laptop` gets the plain (unstable) `inputs`.
    `steambox` is pinned-stable (26.05), so it gets `steamboxInputs` instead — the
    same attrset with every unstable-following input swapped for a `*-2605` variant
    (`nixpkgs`, `home-manager`, `zen-browser`, `firefox-addons`, `silentSDDM`;
    `nixCats` is shared — it has no `nixpkgs` input to pin and builds its plugins
    against the host `nixpkgs` via `nixpkgs_version`). Because the shared modules
    reference these *by name*
    (`inputs.home-manager`, `inputs.zen-browser`, …), the whole `landseal`
    home-manager tree flavors to 26.05 for steambox with **no per-module changes**.
    When adding a flake input that the shared HM tree consumes, add a matching
    `*-2605` variant and thread it through `steamboxInputs`, or steambox breaks on a
    home-manager/nixpkgs version mismatch.
- **`laptop.nix` / `steambox.nix`** are the per-host entry points.
  Each imports its `hosts/*-hardware-configuration.nix`, `nix.nix`,
  `users/landseal.nix`, and a host-specific set of feature modules (window
  managers, power, audio, etc.). Host-only concerns (bootloader, hibernation,
  TLP, LUKS, autologin) live directly in these files.
- **`users/landseal.nix`** defines the user, locale/timezone, and — importantly —
  wires Home Manager in (`home-manager.nixosModules.home-manager`,
  `useGlobalPkgs`, and `users.landseal = ../home-manager/landseal.nix`). It also
  imports `programs/programs.nix` and `programs/fonts.nix` (system-level).
- **`home-manager/landseal.nix`** is the per-user config: user packages, enabled
  `programs.*`, and the dotfile wiring described below. It imports the
  `home-manager/programs/*.nix` modules.

Two parallel `programs/` trees — don't confuse them:
- `nixos/landseal/programs/` — **system-level** (`programs.nix`, `fonts.nix`, `steam.nix`, ...)
- `nixos/landseal/home-manager/programs/` — **user-level** (`zsh.nix`, `git.nix`, `jj.nix`, `claude-code.nix`, ...)

### How raw dotfiles connect to Nix

`home-manager/landseal.nix` defines `dots = ../../..` (the repo root) and maps
files from there into `$HOME`:
- `home.file` for top-level dotfiles (`.bashrc`, `.vimrc`, `.p10k.zsh`)
- `xdg.configFile` for whole `.config/<app>` directories (`hypr`, `niri`, `kitty`,
  `nvim`, `waybar`, `walker`, `mako`, `tmux`, `sunsetr`)

So editing e.g. `.config/niri/config.kdl` in the repo and running `nixos-rebuild`
re-links it into `~/.config`. To add a new app's config, drop it under `.config/`
**and** add the corresponding `confdir`/`dotfile` entry here, or it won't be linked.

`git.nix`/`jj.nix` are functions taking `{ gitUser, gitEmail }` and are imported
with explicit `(import ./programs/git.nix { ... })` so the identity is set in one place.

## Conventions

- Nix files use 2-space indent (see the `# vim: set tabstop=2 ...` modeline atop most files).
- **Per-host boilerplate is intentionally repeated, not hoisted.** Each host entry
  file (`laptop.nix`, `steambox.nix`) declares its own `networking`,
  `hardware.bluetooth.enable`, and `system.stateVersion` rather than sharing a common
  module. This is deliberate: every machine explicitly states its hardware assumptions,
  and Nix surfaces conflicts per-host (e.g. a machine with no bluetooth). Do not "DRY"
  these into a shared module. Likewise a value set both inline and by a feature module
  (e.g. `hardware.bluetooth.enable` in both `steambox.nix` and `audio.nix`) is fine when
  they agree — leave the explicit per-host declaration in place.
- `hosts/*-hardware-configuration.nix` are the original hardware scans — never edit them.
- Wifi via `nmtui`/`nmcli`; Bluetooth via `overskride`. These are intentionally not declarative.
- `claude-code` is installed via the `claude-code` flake input (user-level in
  `home-manager/programs/claude-code.nix`); `cache/claude.nix` adds its cachix
  substituter. Keep these in sync if the install method changes.
