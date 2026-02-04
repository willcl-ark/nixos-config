# nixos-config

NixOS and home-manager configuration using the dendritic pattern with [flake-parts](https://github.com/hercules-ci/flake-parts) and [import-tree](https://github.com/vic/import-tree).

Every `.nix` file under `modules/` is a flake-parts module, auto-imported by import-tree. Features are split per-file and contribute to named `deferredModule` slices, which are assembled into final configurations in `modules/configurations/`.

## Build

```
just build       # build
just switch      # build and switch
just dry-run     # test without applying
nix fmt          # format
```

## Structure

```
modules/
  configurations/   # assemble slices into nixosConfigurations / homeConfigurations
  system/           # nix settings, boot, networking, security, users
  hardware/         # hardware-configuration, nvidia
  services/         # borg, bgt, tor, apcupsd, guix, seedbox
  desktop/          # niri, audio, bluetooth, greetd, portals
  home/             # fish, git, gpg, ghostty, tmux, email, theming
  integrations/     # home-manager, sops, catppuccin wiring
secrets/            # encrypted secrets (sops-nix)
```
