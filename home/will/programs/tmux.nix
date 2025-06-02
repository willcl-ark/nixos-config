{pkgs, ...}: {
  programs.tmux = {
    enable = true;

    # Change prefix to C-a
    shortcut = "a";

    # Start window numbering at 1
    baseIndex = 1;

    mouse = true;

    historyLimit = 50000;

    # Terminal configuration
    terminal = "xterm-direct";

    keyMode = "vi";

    extraConfig = ''
      # Pass through ghostty capabilites
      set -ga terminal-overrides ",xterm-ghostty:*:Tc"

      # unbind the prefix and bind it to Ctrl-a like screen
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      # copy to clipboard
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe 'xsel -b &> /dev/null'
      bind -T copy-mode-vi Enter send-keys -X cancel

      # shortcut for moving tmux buffer to clipboard
      # useful if you've selected with the mouse
      bind-key -nr C-y run "tmux show-buffer | xclip -in -selection clipboard &> /dev/null"

      # Avoid ESC delay
      set -s escape-time 0

      # Fix titlebar
      set -g set-titles on
      set -g set-titles-string "#T"

      # VIM mode
      set -g mode-keys vi

      # Mouse friendly
      set -g mouse on

      # Move between panes with vi keys
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Avoid date/time taking up space
      set -g status-right ""
      set -g status-right-length 0

      # Focus events for vim?
      set-option -g focus-events on

      # Switch to last window
      bind-key L last-window

      # Avoid env vars mangling with tmux and direnv
      # https://github.com/direnv/direnv/wiki/Tmux
      set-option -g update-environment "DIRENV_DIFF DIRENV_DIR DIRENV_WATCHES"
      set-environment -gu DIRENV_DIFF
      set-environment -gu DIRENV_DIR
      set-environment -gu DIRENV_WATCHES
      set-environment -gu DIRENV_LAYOUT
    '';

    # Install plugins
    plugins = with pkgs.tmuxPlugins; [
      sensible # Sensible defaults
      pain-control # Better pane management
      yank # Copy to system clipboard
      resurrect # Save and restore sessions
      continuum # Auto-save sessions
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-battery false
          set -g @dracula-show-powerline true
          set -g @dracula-refresh-rate 10
          set -g @dracula-show-fahrenheit false
          set -g @dracula-military-time true
        '';
      }
    ];
  };
}
