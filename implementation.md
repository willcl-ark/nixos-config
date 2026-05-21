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
