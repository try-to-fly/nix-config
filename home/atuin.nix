{
  # https://docs.atuin.sh/configuration/config/
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      update_check = false;
      auto_sync = true;
      show_help = false;
      enter_accept = true;
      sync = {
        records = true;
      };
    };
  };
}
