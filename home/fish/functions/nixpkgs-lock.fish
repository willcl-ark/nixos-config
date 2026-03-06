function nixpkgs-lock
    if not test -f ~/.config/nixpkgs-rev
        echo "No saved rev. Run nixpkgs-fetch first."
        return 1
    end

    if not test -f flake.nix
        echo "No flake.nix in current directory"
        return 1
    end

    if not grep -i -q 'nixOS/nixpkgs/nixos-unstable' flake.nix
        echo "No nixos-unstable input found in flake.nix"
        return 1
    end

    set -l rev (cat ~/.config/nixpkgs-rev)
    echo "Locking nixpkgs to $rev..."

    set -l meta (nix flake metadata "github:nixOS/nixpkgs/$rev" --json 2>/dev/null)
    or begin
        echo "Failed to fetch metadata for $rev"
        return 1
    end

    set -l narHash (echo $meta | jq -r '.locked.narHash')
    set -l lastModified (echo $meta | jq -r '.locked.lastModified')

    set -l tmpfile (mktemp)
    jq --arg rev "$rev" --arg narHash "$narHash" --argjson lastModified "$lastModified" \
        '.nodes.nixpkgs.locked |= (.rev = $rev | .narHash = $narHash | .lastModified = $lastModified)' \
        flake.lock >$tmpfile
    and mv $tmpfile flake.lock
    echo "Locked nixpkgs to $rev"
end
