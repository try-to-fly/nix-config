{
  # https://docs.atuin.sh/configuration/config/
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      update_check = false;
      auto_sync = true;
      show_help = true;
      enter_accept = true;
      ctrl_n_shortcuts = true;
      sync = {
        records = true;
      };
    };
  };
}
