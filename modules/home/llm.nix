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
    { config, lib, pkgs, ... }:
    let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      codexPkg = llm-agents.codex;
      codexSafe = pkgs.writeShellScriptBin "codex" ''
        exec ${codexPkg}/bin/codex --sandbox workspace-write --ask-for-approval on-request "$@"
      '';
      codexUnsafe = pkgs.writeShellScriptBin "codex-unsafe" ''
        exec ${codexPkg}/bin/codex --sandbox danger-full-access --ask-for-approval never "$@"
      '';
    in
    {
      sops.secrets.deepseek_api_key = {
        sopsFile = "${inputs.self}/secrets/will.yaml";
        path = "${config.home.homeDirectory}/.secrets/deepseek_api_key";
      };

      programs.fish.interactiveShellInit = lib.mkAfter ''
        if test -r ${config.sops.secrets.deepseek_api_key.path}
          set -gx DEEPSEEK_API_KEY (${pkgs.coreutils}/bin/cat ${config.sops.secrets.deepseek_api_key.path})
        end
      '';

      home.packages = [
        llm-agents.claude-code
        codexSafe
        codexUnsafe
        llm-agents.opencode
        pkgs.bubblewrap # For codex
      ];
    };
}
