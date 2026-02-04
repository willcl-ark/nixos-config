{ ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        shortcut = "a";
        baseIndex = 1;
        mouse = true;
        historyLimit = 50000;
        terminal = "xterm-direct";
        keyMode = "vi";
        extraConfig = ''
          set -ga terminal-overrides ",xterm-ghostty:*:Tc"

          unbind C-b
          set -g prefix C-a
          bind C-a send-prefix

          bind -T copy-mode-vi v send -X begin-selection
          bind -T copy-mode-vi y send-keys -X copy-pipe 'xsel -b &> /dev/null'
          bind -T copy-mode-vi Enter send-keys -X cancel

          bind-key -nr C-y run "tmux show-buffer | xclip -in -selection clipboard &> /dev/null"

          set -s escape-time 0

          set -g set-titles on
          set -g set-titles-string "#T"

          set -g mode-keys vi

          set -g mouse on

          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R

          set -g status-right ""
          set -g status-right-length 0

          set-option -g focus-events on

          bind-key L last-window

          set-option -g update-environment "DIRENV_DIFF DIRENV_DIR DIRENV_WATCHES"
          set-environment -gu DIRENV_DIFF
          set-environment -gu DIRENV_DIR
          set-environment -gu DIRENV_WATCHES
          set-environment -gu DIRENV_LAYOUT

          set -g @plugin 'tmux-plugins/tpm'

          run '~/.tmux/plugins/tpm/tpm'
        '';
        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank
        ];
      };
    };
}
