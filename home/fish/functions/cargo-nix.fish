function cargo-nix
    if test "$argv[1]" != init
        echo "Usage: cargo-nix init"
        return 1
    end

    set -l template_dir /home/will/src/flake-templates/rust
    cp $template_dir/flake.nix $template_dir/justfile $template_dir/.envrc .
    git add flake.nix justfile .envrc
    git commit -m "init rust flake"
end
