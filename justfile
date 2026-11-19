set shell := ["bash", "-uc"]
os := os()
host := "desktop"
user := "will"

[private]
default:
    just --list

# Build the new configuration
[group('build')]
build hostname=host:
    nh os build --accept-flake-config -H {{hostname}} . --show-trace --diff always

# Build and activate the new configuration
[group('build')]
test hostname=host:
    nh os test --accept-flake-config -H {{hostname}} .

# Build and activate the new configuration, and make it the boot default
[group('build')]
[no-exit-message]
switch hostname=host:
    nh os switch --accept-flake-config --ask -H {{hostname}} .

# Update an existing NixOS host over SSH (not a first-install command)
[group('build')]
switch-remote hostname target:
    nh os switch --accept-flake-config --ask -H {{quote(hostname)}} --target-host {{quote(target)}} .

# First NUC installation: wipes its internal SSD; leaves installer running for checks
[group('deploy')]
deploy-nuc restore-dir identity=(env_var('HOME') / '.ssh/hetzner-temp'):
    #!/usr/bin/env bash
    set -euo pipefail
    restore_dir={{quote(restore-dir)}}
    test -r {{quote(identity)}}
    for path in home/will/plex home/will/nzbget home/bitcoin/.bitcoin var/lib/sonarr var/lib/radarr var/lib/tor var/lib/tailscale; do
        test -d "$restore_dir/$path" || { echo "Missing restore directory: $path" >&2; exit 1; }
    done
    for path in home/bitcoin/.bitcoin/bitcoin.conf home/will/nzbget/nzbget.conf var/lib/tailscale/tailscaled.state var/lib/tor/bitcoind/hs_ed25519_secret_key; do
        test -s "$restore_dir/$path" || { echo "Missing restore file: $path" >&2; exit 1; }
    done
    read -r -p 'Wipe the internal SSD on NUC 10.0.0.88 and restore this directory? Type WIPE-NUC: ' answer
    test "$answer" = WIPE-NUC
    nix run github:nix-community/nixos-anywhere -- \
        --flake .#nuc --target-host root@10.0.0.88 -i {{quote(identity)}} \
        --copy-host-keys --extra-files "$restore_dir" \
        --chown /home/will/plex 998:998 \
        --chown /home/will/nzbget 998:998 \
        --chown /home/bitcoin 1001:1001 \
        --chown /var/lib/sonarr 119:1002 \
        --chown /var/lib/radarr 1002:1002 \
        --chown /var/lib/tor 117:123 \
        --chown /var/lib/tailscale 0:0 \
        --build-on local --phases kexec,disko,install
    echo 'Installed without rebooting. Verify restored data and permissions under /mnt before reboot.'

# Build a VM for testing (pass -r style flag handled by nh)
[group('test')]
build-vm hostname=host:
    nh os build-vm --accept-flake-config --ask -r -H {{hostname}} .

# Show what would change without build
[group('test')]
dry-run hostname=host:
    nh os switch --accept-flake-config --dry -H {{hostname}} .

# Show what would change without build
[group('test')]
dry-run-guest hostname=host:
    nix-shell -p nixos-anywhere nixos-rebuild --command "nixos-rebuild dry-run --accept-flake-config --flake .#{{hostname}}"

# Update system and home-manager inputs
[group('maintenance')]
update:
    nix flake update

# Check NixOS configuration for errors
[group('check')]
check-config hostname=host:
    nh os test --accept-flake-config --dry -H {{hostname}} .

# Rebuild user environment (home-manager standalone)
[group('home')]
update-home:
    nh home switch --accept-flake-config -c {{user}}@{{os}} .

# Test rebuild user environment (home-manager build)
[group('home')]
build-home:
    nh home build --accept-flake-config -c {{user}}@{{os}} .

# Copy the current hardware configuration to the repo
[group('system')]
update-hardware:
    sudo cp /etc/nixos/hardware-configuration.nix hosts/desktop/hardware-configuration.nix

# nix-collect-garbage that also collects gcroots (matches auto-clean service)
[group('maintenance')]
clean:
    nh clean all --ask --keep-since 60d --keep 10

# Clean only the current user's profiles and gcroots (direnv etc., no sudo)
[group('maintenance')]
clean-user:
    nh clean user --ask --keep-since 60d --keep 10

# Aggressive trim of system generations only (leaves user/direnv gcroots alone)
[group('maintenance')]
clean-system:
    sudo nh clean profile /nix/var/nix/profiles/system --ask --keep-since 30d --keep 10 --no-gcroots

# Search nixpkgs (defaults to nixos-unstable)
[group('info')]
search +query:
    nh search {{query}}

# Build the new configuration and make it the boot default
[group('build')]
boot hostname=host:
    nh os boot --accept-flake-config -H {{hostname}} .

# List system generations
[group('info')]
generations:
    nh os info

# Rollback to the previous generation (or pass a specific gen id)
[group('build')]
rollback to="":
    nh os rollback --ask {{ if to != "" { "--to " + to } else { "" } }}

# Open the NixOS configuration in a Nix REPL
[group('info')]
repl hostname=host:
    nh os repl --accept-flake-config -H {{hostname}} .

# Open the home-manager configuration in a Nix REPL
[group('info')]
repl-home:
    nh home repl --accept-flake-config -c {{user}}@{{os}} .

# Update llm-agents and switch
llm:
    nix flake update llm-agents
    git add flake.lock
    git commit -m "bump llm-agents"
    just switch
