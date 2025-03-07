{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Languages and runtimes
    go
    lua
    luajit
    python3
    rustup
    zig

    # Development tools
    just
    qemu
    ruff
    uv

    # Build tools
    bash
    clang_19
    cmake
    docker
    elfutils
    findutils
    git
    gnugrep
    gnumake
    gnused
    gnutar
    mold
    ninja
    podman
    sqlite
    uutils-coreutils # Rust coreutils

    # LSPs and linters etc.
    clang-tools
    cmake-language-server
    gitlint
    isort
    jsonlint
    luacheck
    markdownlint
    mdformat
    pyright
    stylua
    typos-cli
    yamllint
    zls

    # Git-related
    delta
    difftastic
    gh
    lazygit

    # Misc
    doxygen
  ];

}
