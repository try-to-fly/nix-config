{

  programs.alacritty = {
    enable = true;
    settings = {
      env = { TERM = "xterm-256color"; };
      window.padding = { x = 0; y = 0; };
      window.dynamic_padding = true;
      window.startup_mode = "Maximized";

      font = {
        normal = {
          family = "FiraCode Nerd Font Mono";
        };

        size = 12.0;
      };
    };
  };
}


