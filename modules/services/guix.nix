{ ... }:
{
  flake.modules.nixos.desktop-services =
    { options, pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: prev: {
          guile-zlib = prev.guile-zlib.overrideAttrs {
            doCheck = false;
            postConfigure = ''
              sed -i "s|/nix/store/[a-z0-9]*-zlib-[^\"]*-static/lib/libz|${prev.zlib.out}/lib/libz|" zlib/config.scm
            '';
          };
        })
      ];
      environment.systemPackages = [ pkgs.guix ];
      services.guix = {
        enable = true;
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
