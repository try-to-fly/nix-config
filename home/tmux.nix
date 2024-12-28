{ lib, ... }: {
  programs.tmux = {
    enable = true;
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
    extraConfig = lib.strings.fileContents ./tmux.conf;
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
*/
