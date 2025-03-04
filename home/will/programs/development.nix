{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Languages and runtimes
    go
    python3
    rustup

    # Development tools
    just
    ruff
    uv

    # Build tools
    bash
    clang
    cmake
    coreutils
    docker
    findutils
    git
    gnugrep
    gnumake
    gnused
    gnutar
    ninja
    podman
    python3
    sqlite

    # Git-related
    gh
    lazygit
  ];

}
