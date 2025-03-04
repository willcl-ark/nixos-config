{ ... }: {
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Set environment variables
      set -gx EDITOR nvim
      set -gx VISUAL nvim

      # Disable fish greeting
      set -g fish_greeting
    '';

    plugins = [
      # { name = "z"; src = pkgs.fishPlugins.z.src; }
    ];

    shellAliases = {
      l = "exa -la";
      ll = "exa -l";
      g = "git";
      vim = "nvim";
      v = "nvim";
    };

    # Fish shell integration with tools
    shellInit = ''
      fish_vi_key_bindings

      starship init fish | source
      zoxide init --cmd cd fish | source
      direnv hook fish | source

      fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --history=\cr --variables=\cv
    '';
  };
}
