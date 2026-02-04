{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nil
          nixfmt-tree
          sops
          ssh-to-age
        ];
      };
    };
}
