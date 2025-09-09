{ pkgs, ... }:
{
  programs.ripgrep = {
    enable = true;
    package = pkgs.ripgrep;
    arguments = [
      "--iglob=!.git"
      "--iglob=!node_modules"
    ];
  };
}
