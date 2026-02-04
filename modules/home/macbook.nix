{ inputs, ... }:
{
  flake.modules.homeManager.macbook =
    { config, pkgs, ... }:
    {
      home.username = "will";
      home.homeDirectory = "/Users/will";

      programs = {
        direnv = {
          enable = true;
          package = pkgs.direnv;
          nix-direnv = {
            enable = true;
            package = pkgs.nix-direnv;
          };
          silent = true;
        };
        fzf.enable = true;
        git.settings.alias.ack = "!f() { git rev-parse HEAD | tr -d '[:space:]' | pbcopy; }; f";
      };

      sops = {
        defaultSopsFile = "${inputs.self}/secrets/will.yaml";
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
