{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Languages and runtimes
    go
    lua
    # luajit
    # python312
    python311
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
    actionlint
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
    lua54Packages.luacheck
    nodePackages.jsonlint
    pyright
    ruff
    shellcheck
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
