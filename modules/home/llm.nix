{ inputs, ... }:
{
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
      ];
    };
}
