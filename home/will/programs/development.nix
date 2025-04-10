{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Languages and runtimes
    go
    lua
    # luajit
    python3
    rustup
    zig

    # Development tools
    qemu
    uv

    # Build tools
    bash
    clang_19
    cmake
    docker
    elfutils
    findutils
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
    basedpyright
    clang-tools
    cmake-language-server
    fish-lsp
    gitlint
    gopls
    isort
    markdownlint-cli
    mdformat
    nil
    lua-language-server
    nodePackages.jsonlint
    pyright
    ruff
    stylua
    typos
    typos-lsp
    yamllint
    zls

    # Git-related
    delta
    difftastic
    lazygit

    # Misc
    doxygen
  ];

}
