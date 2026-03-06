function nixpkgs-fetch
    set -l rev (curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" \
        | jq -r '.data.result[] | select(.metric.channel=="nixos-unstable") | .metric.revision')

    if test -z "$rev"
        echo "Failed to fetch latest hydra revision"
        return 1
    end

    mkdir -p ~/.config
    echo $rev >~/.config/nixpkgs-rev
    echo $rev
end
