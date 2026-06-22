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

DeepSeek API key shell export

Added a Home Manager SOPS secret declaration for `deepseek_api_key` in the LLM
module and export `DEEPSEEK_API_KEY` from fish interactive startup by reading
the decrypted runtime secret file. This keeps the secret value out of the Nix
store while making it available to terminal-launched LLM tooling.

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
