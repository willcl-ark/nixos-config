{pkgs, ...}: {
  home.packages = with pkgs; [
    # Languages and runtimes
    go
    lua
    python311
    rustup
    zig

    # Development tools
    gh-dash
    qemu
    uv

    # Build tools & tings
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

    # Git-related
    delta
    difftastic
    lazygit
  ];
}
