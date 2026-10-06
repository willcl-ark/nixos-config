Firefox Developer Edition switch

Changed the managed Home Manager Firefox package to `pkgs.firefox-devedition`.
The managed profile is named `dev-edition-default`, matching Firefox Developer
Edition's default profile convention, and its path is pinned to the active
`ac0mwoe8.dev-edition-default` profile directory. The previous `default` profile
data was copied into that Developer Edition profile directory outside Nix. This
is intended as a hard cutover: the browser binary and default MIME handlers now
point at Firefox Developer Edition, and the configured profile reuses the
migrated profile data.

The GitHub issue helper also launches `firefox-devedition` directly to avoid
pulling in or opening stable Firefox through an explicit package path.

The managed Firefox profile sets `xpinstall.signatures.required` to `false` so
Developer Edition permits unsigned extensions declaratively through Home
Manager.

The Firefox Home Manager config path explicitly stays on `.mozilla/firefox`
because Firefox Developer Edition is reading that legacy profile registry at
runtime. This also silences the Home Manager 26.05 XDG migration warning while
preserving the working profile layout.

Borg backup trim

The borg module now applies its baseline cache/generated-data exclusions inside
the generated service script instead of relying on the `excludePaths` option
default. The desktop host sets `excludePaths`, and Nix option defaults are
overridden by that host definition, so the old default cache exclusions were not
present in the effective desktop backup command.

The desktop host adds source-tree exclusions for common rebuildable development
outputs under `~/src`: `.direnv`, `build`, `node_modules`, and `target`.
Project sources and VCS metadata are still included.

A follow-up pass over `/home/will/src/core` found that ccache is already covered:
`/home/will/.ccache` is large, but the service excludes `/home/*/.ccache/*`;
the newer default `~/.cache/ccache` location is also covered by
`/home/*/.cache/*`.

The desktop host now also excludes `build-*` directories, Python cache
directories under `/home/will/src/core`, and generated Bitcoin Core
`depends` outputs. The `depends` rule keeps source-like directories such as
`packages`, `patches`, `hosts`, and `builders`, while dropping host-prefix
output directories plus `built`, `sources`, and `work`.

Contributor check fish function

Added an autoloaded `contributor-check` fish function for bitcoin/bitcoin
contributor review. It intentionally hard-codes the repository to bitcoin/bitcoin
and requires exactly one GitHub username, then labels and runs the four existing
`gh search` queries for authored PRs, authored issues, commented issues/PRs, and
reviewed PRs.

The contributor check now limits authored issues and pull requests to the
previous six calendar months by default. It separately queries GitHub's API for
conversation comments, inline review comments, and submitted reviews, filtering
those records by the person's own timestamps so activity on older issues and
pull requests is included. The default comment lookup uses user-scoped GraphQL
comments and per-PR inline-comment requests, avoiding a slow repository-wide
scan. Review lookup uses the same paginated GraphQL contribution data;
`--all` retains the complete REST history scans. Passing `--all` removes the
time filters.

DeepSeek API key shell export

Added a Home Manager SOPS secret declaration for `deepseek_api_key` in the LLM
module and export `DEEPSEEK_API_KEY` from fish interactive startup by reading
the decrypted runtime secret file. This keeps the secret value out of the Nix
store while making it available to terminal-launched LLM tooling.

Herdr LLM agent workspace manager

Added the `herdr` package from the existing pinned `llm-agents` flake input to
the Home Manager LLM tools. This reuses the repository's existing package-set
pattern and keeps the change as a hard cutover with no compatibility wrapper.

Herdr declarative configuration

Configured Herdr's prefix as `ctrl+a` to match the existing tmux habit. The
onboarding flow is disabled because Home Manager owns the configuration file;
other settings remain at Herdr defaults until the first interactive session
shows which customizations are useful.

Ghostty systemd/D-Bus launch

Changed the Niri `Mod+Return` terminal binding from launching `ghostty` directly
to running `ghostty +new-window`. Ghostty documents this command as the fast
D-Bus path: it asks an existing Ghostty instance to open a window, or lets D-Bus
activation start the Ghostty user systemd service first. The Ghostty package is
still installed through the existing NixOS/Home Manager configuration so its
desktop, D-Bus, and user systemd files remain package-owned.

Added a Home Manager `xdg.configFile` entry for
`systemd/user/default.target.wants/app-com.mitchellh.ghostty.service`, pointing
at the unit shipped by `pkgs.ghostty`. This records the equivalent of
`systemctl enable --user app-com.mitchellh.ghostty.service` declaratively while
keeping the service definition itself owned by the Ghostty package.

Guix substitute server

Configured the NixOS Guix daemon to prefer `https://guix.fish.foo` before the
standard Guix substitute servers. The substitute server's signing key is fetched
with a fixed-output hash so the NixOS configuration can authorize the key
reproducibly during evaluation/build.

Recurring Nix rebuilds

The weekly `nh clean` service was confirmed to remove Catppuccin's generated
Firefox and Starship outputs. Catppuccin's public Cachix cache contains the
exact generated outputs and Whiskers build observed locally, so the flake now
declares that cache. Just recipes explicitly accept this repository's flake
configuration rather than trusting flake configuration globally.

`wf-recorder-gui` previously imported `package.nix` from a fetched source path.
That forced Nix to realize the source during every evaluation after garbage
collection. Its pinned v0.4.0 package expression now lives locally, while the
source and Cargo vendor hashes remain unchanged and are only realized when the
package itself needs building.

The temporary `guile-zlib` overlay changed Guix's dependency graph, preventing
the stock Guix substitute from matching. The workaround was removed after the
current nixpkgs Guix derivation was confirmed available from `cache.nixos.org`.

Catppuccin port enrollment is explicit in both NixOS and Home Manager to retain
current behavior across its upcoming global-enable semantic change. The renamed
NixOS manual-page cache option is used without changing its disabled value.

CMake 4.4 alongside nixpkgs CMake

The local CMake 4.4 package reuses the pinned nixpkgs CMake derivation and
overrides only its version, source, and the purity patch that changed upstream.
The replacement patch is pinned to the immutable commit from nixpkgs PR #540343
because the older patch in the current flake does not apply to CMake 4.4.

Only `cmake4.4` and `ctest4.4` symlinks are exposed in the Home Manager profile.
The underlying 4.4 derivation remains available through the launcher's
`passthru.cmake`, while keeping its unversioned command paths out of the profile
avoids collisions with the regular nixpkgs CMake installation.

Podman hard cutover

The desktop uses rootless Podman with its `docker` CLI compatibility alias, but
without Docker socket compatibility. Podman Compose replaces Docker Compose, the
user no longer joins the privileged Docker group, and the container-network
usage helper uses native Podman commands. The alias keeps hardcoded Docker CLI
workflows on Podman without running the Docker daemon.

Docker's existing data under `/var/lib/docker` is intentionally retained outside
the declarative configuration during validation. Podman uses separate rootless
storage under `~/.local/share/containers`, so images, build cache, volumes, and
networks are not migrated or shared. Existing tools that invoke `docker`, notably
Bitcoin Core's local CI scripts, run through Podman's compatibility alias. Tools
that require the Docker API socket remain intentionally unsupported.

Voxtype push-to-talk for Codex

Added Home Manager's Voxtype service with the Vulkan backend for the desktop's
NVIDIA GeForce RTX 3060 Ti, using the `large-v3-turbo` Whisper model and `wtype`
for Wayland text injection. Voxtype owns `Super+V` so it can observe both press
and release events; the previous Niri clipboard binding was removed. The user
is also added to the `input` group because Niri cannot express a key-release
binding for compositor-driven push-to-talk.

The DMS Niri integration also included a separate `dms/binds.kdl` with its own
`Mod+V` clipboard binding. Removed that include and kept its unique wallpaper,
lock, notepad, and task-manager shortcuts in the managed Niri bindings so DMS
no longer takes `Super+V`.

Voxtype 1.0.1 rejects the letter name `V` for its evdev hotkey. Use
`EVTEST_47`, the Linux keycode for V. The user must log out and back in after
the `input` group change so the evdev listener can read keyboard events.

Voxtype on-screen indicator

The packaged `voxtype-vulkan` binary ships the Quickshell launcher but omits
the Quickshell QML tree. Point the service at `quickshell/` in the same pinned
Voxtype source, select the Quickshell frontend, and include `qs` plus the audio
bridge in the service PATH. This uses the existing Quickshell installation and
keeps the QML version matched to the daemon.

Container registry option migration

Moved the Podman unqualified image search list to
`virtualisation.containers.registries.settings.unqualified-search-registries`
because the older `registries.search` option is deprecated. The list still
contains only `docker.io`; no registry behavior was intended to change.
September 2026 sops-nix build fix

Updated only the `sops-nix` flake lock entry after `just build` failed during
evaluation. The previous sops-nix revision used `buildGo125Module`, which the
current locked nixpkgs removed. The newer sops-nix revision avoids that builder.
No flake input definition or module configuration changed.

Radicle removal

Removed the Home Manager Radicle module after the updated nixpkgs marked
`radicle-node-1.10.3` insecure due to unauthenticated, unencrypted private
repository traffic. This removes the package and its deployed key files from
the configuration. The encrypted secret entry remains in `secrets/will.yaml`.
