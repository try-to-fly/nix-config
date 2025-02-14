{ pkgs, lib, ... }:

let
  t-smart-tmux-session-manager = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "t-smart-tmux-session-manager";
    version = "2023-08-04";
    src = pkgs.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "t-smart-tmux-session-manager";
      rev = "8c887534d0f59cdde2aef873052d59efacdb7b2a";
      sha256 = "sha256-PGemYYjyWbHmNvEflK51PdY8oKI/1DZMU5OBjKH9DLw=";
    };
  };

  tmux-ssh-split = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-ssh-split";
    version = "unstable-2024-10-27";
    src = pkgs.fetchFromGitHub {
      owner = "pschmitt";
      repo = "tmux-ssh-split";
      rev = "d43b4722ce37138f8d391b77396f4754782f33ee";
      sha256 = "sha256-FwInWwlHrzr7hgOiqsIgNOvUstwvr+ulfk2WQGOYRTA=";
    };
  };
in
{
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 10000;
    aggressiveResize = true;
    baseIndex = 1;
    mouse = true;
    prefix = "`";
    keyMode = "vi";
    shortcut = "q";
    sensibleOnTop = true;
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
      sidebar
      continuum
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-plugins "battery cpu-usage ram-usage ssh-session"
          set -g @dracula-show-flags true
          set -g @dracula-show-fahrenheit false
          set -g @dracula-fixed-location "Hangzhou"
          set -g @dracula-cpu-display-load false
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-boot 'on'
          set -g @continuum-boot-options 'alacritty'
          set -g @continuum-restore 'on'
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = t-smart-tmux-session-manager;
      }
    ];
    extraConfig = ''
      set -gq allow-passthrough on
      set -g visual-activity off
      set -g renumber-windows on
      set -s set-clipboard on

      # fix tmux default shell : https://github.com/nix-community/home-manager/issues/5952
      set -gu default-command
      set -g default-shell "$SHELL"

      set -g @no-scroll-on-exit-copy-mode 'on'
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'pbcopy'

      bind - splitw -v -c '#{pane_current_path}' # 垂直方向新增面板，默认进入当前目录
      bind | splitw -h -c '#{pane_current_path}' # 水平方向新增面板，默认进入当前目录


    '';
  };
}


/**
  plugins = with pkgs.tmuxPlugins; [
  copycat
  open
  resurrect
  yank
  vim-tmux-navigator
  ];


  1. https://github.com/namishh/crystal/blob/cc37b56577e951b0c98c1a97840febdce1e39691/home/namish/conf/shell/tmux/default.nix#L4
*/
