{ ... }:
let
  guixOverride = builtins.fetchGit {
    url = "file:///home/will/src/nixpkgs";
    rev = "abb829a42412d7da71e477a0edd41db6a443d1fc";
    ref = "guix-unprivileged";
    shallow = true;
  };
in
{
  flake.modules.nixos.desktop-services =
    { options, pkgs, ... }:
    {
      disabledModules = [ "services/misc/guix" ];
      imports = [ (guixOverride + "/nixos/modules/services/misc/guix") ];
      nixpkgs.overlays = [
        (final: _prev: {
          guix = final.callPackage (guixOverride + "/pkgs/by-name/gu/guix/package.nix") { };
        })
      ];

      environment.systemPackages = [ pkgs.guix ];
      services.guix = {
        enable = true;
        privileged = false;
        substituters = {
          urls = [
            "https://guix.fish.foo"
          ] ++ options.services.guix.substituters.urls.default;
          authorizedKeys = [
            (pkgs.fetchurl {
              url = "https://guix.fish.foo/signing-key.pub";
              hash = "sha256-V5a05swjY1BSunzs3EuLkrpqU+83QgjOUJTAkgpy9A8=";
            })
          ] ++ options.services.guix.substituters.authorizedKeys.default;
        };
      };
    };
}
