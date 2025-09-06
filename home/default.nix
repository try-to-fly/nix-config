{ username, pkgs, nix-index-database, ... }:

{


  home.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    nerd-fonts.zed-mono
  ];



  # import sub modules
  imports = [
    # nix-index + prebuilt database for command-not-found suggestions
    nix-index-database.hmModules.nix-index
    ./nix-index.nix
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
    ./fish.nix
    ./atuin.nix
    ./zoxide.nix
    ./direnv.nix
    ./git.nix
    # ./alacritty.nix
    ./kitty.nix
    ./wezterm.nix
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
