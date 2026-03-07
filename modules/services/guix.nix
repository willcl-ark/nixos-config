{ ... }:
{
  flake.modules.nixos.desktop-services =
    { pkgs, ... }:
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
      services.guix.enable = true;
    };
}
