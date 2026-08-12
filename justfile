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
