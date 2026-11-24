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
      # Voxtype 1.1.1 links SQLite, but its nixpkgs recipe omits the library.
      voxtype = pkgs.voxtype-vulkan.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ pkgs.sqlite ];
      });
      codexSafe = pkgs.writeShellScriptBin "codex" ''
        exec ${codexPkg}/bin/codex --sandbox workspace-write "$@"
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
        llm-agents.antigravity-cli
        codexSafe
        codexUnsafe
        llm-agents.opencode
        llm-agents.herdr
        pkgs.bubblewrap # For codex
      ];

      xdg.configFile."herdr/config.toml".text = ''
        onboarding = false

        [keys]
        prefix = "ctrl+a"
      '';

      services.voxtype = {
        enable = true;
        package = voxtype;
        loadModels = [ "large-v3-turbo" ];
        environment = {
          PATH = lib.makeBinPath [
            pkgs.coreutils
            pkgs.which
            pkgs.wl-clipboard
            pkgs.wtype
            pkgs.quickshell
            voxtype
          ];
          VOXTYPE_OSD_QML_PATH = "${voxtype.src}/quickshell";
        };
        settings = {
          engine = "whisper";
          hotkey = {
            enabled = true;
            key = "EVTEST_47";
            modifiers = [ "LEFTMETA" ];
          };
          output = {
            fallback_to_clipboard = true;
            mode = "type";
          };
          osd.frontend = "quickshell";
          whisper = {
            language = "en";
            model = "large-v3-turbo";
          };
        };
      };
    };
}
