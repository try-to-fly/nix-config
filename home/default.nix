{ username, pkgs, ... }:

{


  home.packages = with pkgs; [
    pkgs.nerd-fonts.droid-sans-mono
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.symbols-only
    pkgs.nerd-fonts.zed-mono
  ];



  # import sub modules
  imports = [
    # ./shell.nix
    # ./core.nix
    # ./git.nix
    ./starship.nix
    ./yazi.nix
    ./lazygit.nix
    ./tmux.nix
    ./ripgrep.nix
    ./fd.nix
    ./sqlite3.nix
    ./bat.nix
    ./zsh.nix
    ./atuin.nix
    ./zoxide.nix
    ./git.nix
    ./alacritty.nix
    ./kitty.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
