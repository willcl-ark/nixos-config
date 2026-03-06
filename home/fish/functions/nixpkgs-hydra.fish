function nixpkgs-hydra
    set -l rev (curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" \
        | jq -r '.data.result[] | select(.metric.channel=="nixos-unstable") | .metric.revision')

    if test -z "$rev"
        echo "Failed to fetch latest hydra revision"
        return 1
    end

    echo $rev

    if not test -f flake.nix
        return 0
    end

    if not grep -q 'nixos/nixpkgs/nixos-unstable' flake.nix
        return 0
    end

    echo "Updating nixpkgs to $rev..."
    nix flake lock --override-input nixpkgs "github:nixos/nixpkgs/$rev"
end
