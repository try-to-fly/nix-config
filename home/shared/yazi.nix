{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
    enableZshIntegration = true;
    enableFishIntegration = true;
    settings = {
      mgr = {
        show_hidden = true;
        sort_dir_first = true;
        linemode = "owner";
      };

    };
  };
}
