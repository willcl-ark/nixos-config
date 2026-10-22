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

## mod-bot

The desktop starts `mod-bot.service` at boot using the committed source in
`/home/will/src/core/mod-bot`. It records manual bans and posts confirmed LLM
reports; banning and unblocking stay manual.

Run `sops secrets/will.yaml` and add these top-level keys:

```yaml
github_mod_bot_token: YOUR_GITHUB_TOKEN
telegram_mod_bot_token: YOUR_TELEGRAM_BOT_TOKEN
```

The GitHub token needs discussion posting access to `bitcoin-core/meta`.
Sops-nix renders a root-only environment file and restarts the service when its
credentials change. The operator ID is configured in `modules/services/mod-bot.nix`.

Apply with `just switch`. Stop any bot running in a terminal before activation
so only one process polls Telegram. View logs with `journalctl -u mod-bot -f`.
After committing bot changes, run `nix flake update mod-bot` here and rebuild.
