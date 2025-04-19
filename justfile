set shell := ["bash", "-uc"]
os := os()
host := "desktop"
user := "will"

[private]
default:
    just --list

# Build configuration without switching
[group('local')]
build hostname=host:
    nixos-rebuild build --flake .#{{hostname}}

[group('remote')]
build-test hostname=host:
    nix-shell -p nixos-rebuild --command "nixos-rebuild build --flake .#{{hostname}} --impure --show-trace"

# Build and switch to new configuration
[group('local')]
[no-exit-message]
switch hostname=host:
    sudo nixos-rebuild switch --flake .#{{hostname}}
    @-unlink result 2&>1 /dev/null || true

# Build a VM for testing
[group('test')]
build-vm hostname=host:
    nixos-rebuild build-vm --flake .#{{hostname}}

# Show what would change without building
[group('test')]
dry-run hostname=host:
    nixos-rebuild dry-run --flake .#{{hostname}}

# Show what would change without building
[group('test')]
dry-run-guest hostname=host:
    nix-shell -p nixos-anywhere nixos-rebuild --command "nixos-rebuild dry-run --flake .#{{hostname}}"

# Update system and home-manager inputs
[group('update')]
update:
    nix flake update

# Update specific input
[group('update')]
update-input input="nixpkgs":
    nix flake lock --update-input {{input}}

# Clean up old generations (keeps last 3)
[group('maintenance')]
cleanup-generations hostname=host:
    sudo nix-collect-garbage --delete-older-than 14d
    sudo nixos-rebuild boot --flake .#{{hostname}}

# Check NixOS configuration for errors
[group('check')]
check-config hostname=host:
    sudo nixos-rebuild dry-activate --flake .#{{hostname}}

# Rebuild user environment (home-manager standalone)
[group('home')]
update-home:
    nix run nixpkgs#home-manager -- switch --flake .#{{user}}@{{os}}

# Copy the current hardware configuration to the repo
[group('system')]
update-hardware:
    sudo cp /etc/nixos/hardware-configuration.nix hosts/desktop/hardware-configuration.nix

# Run a garbage collection
[group('maintenance')]
gc:
    sudo nix-collect-garbage -d

# Create a boot entry for current configuration
[group('system')]
boot hostname=host:
    sudo nixos-rebuild boot --flake .#{{hostname}}

# List system generations
[group('info')]
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Comprehensive system upgrade: update flake inputs and rebuild system
[group('update')]
upgrade hostname=host user=user:
    echo "Updating flake inputs..."
    nix flake update
    echo "Rebuilding system configuration..."
    sudo nixos-rebuild switch --flake .#{{hostname}}
    echo "Updating home-manager configuration..."
    nix run nixpkgs#home-manager -- switch --flake .#{{user}}@{{os}}
    echo "System upgrade complete!"
