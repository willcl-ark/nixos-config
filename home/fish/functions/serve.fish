function serve --description 'Share a file, live log, or Herdr session through Tailscale Funnel'
    if contains -- --help $argv
        printf '%s\n' 'serve: choose a live log, static file, or Herdr session to share publicly.' \
            'The URL stays active while this command runs. Ctrl-C stops sharing.' \
            'Uses HTTPS port 8443; refuses to replace an existing service on that port.'
        return
    end
    if test (count $argv) -ne 0
        echo 'Usage: serve [--help]' >&2
        return 2
    end

    set -l kind (printf '%s\n' 'Stream log' 'Static file' 'Herdr terminal' | fzf --height=8 --reverse --prompt='Share: ')
    or return 130

    set -l viewer
    set -l file
    switch $kind
        case 'Stream log' 'Static file'
            read --prompt-str='File path: ' file
            or return 130
            set file (path resolve -- "$file")
            if not test -f "$file"; or not test -r "$file"
                echo 'Choose a readable file.' >&2
                return 1
            end
            set viewer tail -n 100 -F -- "$file"
        case 'Herdr terminal'
            if not command -q herdr
                echo 'Herdr is not installed.' >&2
                return 1
            end
            set viewer env -u HERDR_ENV herdr
        case '*'
            return 130
    end

    set -l configured (tailscale serve status --json)
    or return
    if string match --quiet --regex '"8443"\s*:' -- $configured
        echo 'Tailscale port 8443 is already in use. Stop its current share first.' >&2
        return 1
    end

    echo 'Sharing publicly. Keep this command running; Ctrl-C stops it.' >&2
    if test "$kind" = 'Static file'
        # tailscaled opens files as root, so file serving requires sudo.
        sudo tailscale funnel --https=8443 "$file"
        return $status
    end

    # A child shell owns cleanup: Ctrl-C cancels fish functions before later lines run.
    nix shell nixpkgs#bash nixpkgs#ttyd --command bash -c '
        set -euo pipefail
        log=$(mktemp)
        viewer=
        cleanup() {
            if [[ -n $viewer ]]; then
                kill "$viewer" 2>/dev/null || true
                wait "$viewer" 2>/dev/null || true
            fi
            rm -f "$log"
        }
        trap cleanup EXIT
        trap "exit 130" INT
        trap "exit 143" TERM HUP

        ttyd -i 127.0.0.1 -p 0 "$@" > "$log" 2>&1 &
        viewer=$!
        port=
        for ((attempt=0; attempt<100; ++attempt)); do
            port=$(sed -n "s/.*Listening on port: //p" "$log")
            [[ -n $port ]] && break
            if ! kill -0 "$viewer" 2>/dev/null; then
                cat "$log" >&2
                exit 1
            fi
            sleep 0.1
        done
        if [[ -z $port ]]; then
            cat "$log" >&2
            echo "ttyd did not become ready." >&2
            exit 1
        fi
        tailscale funnel --https=8443 "http://127.0.0.1:$port"
    ' serve $viewer
end
