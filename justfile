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
    nh os build -H {{hostname}} .

# Build and activate the new configuration
[group('build')]
test hostname=host:
    nh os test -H {{hostname}} .

# Build and activate the new configuration, and make it the boot default
[group('build')]
[no-exit-message]
switch hostname=host:
    nh os switch -H {{hostname}} .

# Build a VM for testing
[group('test')]
build-vm hostname=host:
    nixos-rebuild build-vm --flake .#{{hostname}}

# Show what would change without build
[group('test')]
dry-run hostname=host:
    nixos-rebuild dry-run --flake .#{{hostname}}

# Show what would change without build
[group('test')]
dry-run-guest hostname=host:
    nix-shell -p nixos-anywhere nixos-rebuild --command "nixos-rebuild dry-run --flake .#{{hostname}}"

# Update system and home-manager inputs
[group('maintenance')]
update:
    nix flake update

# Check NixOS configuration for errors
[group('check')]
check-config hostname=host:
    sudo nixos-rebuild dry-activate --flake .#{{hostname}}

# Rebuild user environment (home-manager standalone)
[group('home')]
update-home:
    nix run nixpkgs#home-manager -- switch --flake .#{{user}}@{{os}}

# Test rebuild user environment (home-manager build)
[group('home')]
build-home:
    nix run nixpkgs#home-manager -- build --flake .#{{user}}@{{os}}

# Copy the current hardware configuration to the repo
[group('system')]
update-hardware:
    sudo cp /etc/nixos/hardware-configuration.nix hosts/desktop/hardware-configuration.nix

# nix-collect-garbage that also collects gcroots
[group('maintenance')]
clean:
    nh clean all

# Build the new configuration and make it the boot default
[group('build')]
boot hostname=host:
    nh os boot  -H {{hostname}} .

# List system generations
[group('info')]
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
