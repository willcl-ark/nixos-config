{ inputs, ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      # Codex expects bwrap at /usr/bin/bwrap
      # tracks https://github.com/openai/codex/pull/15791
      system.activationScripts.bwrap-symlink.text = ''
        mkdir -p /usr/bin
        ln -sf ${pkgs.bubblewrap}/bin/bwrap /usr/bin/bwrap
      '';
    };

  flake.modules.homeManager.base =
    { pkgs, ... }:
    let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = [
        llm-agents.claude-code
        llm-agents.codex
        llm-agents.opencode
        pkgs.bubblewrap # For codex
      ];
    };
}
