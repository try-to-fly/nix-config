{ lib
, pkgs
, ...
}:
###########################################################
#
# Kitty Configuration
#
# Useful Hot Keys for Linux(replace `ctrl + shift` with `cmd` on macOS)):
#   1. Increase Font Size: `ctrl + shift + =` | `ctrl + shift + +`
#   2. Decrease Font Size: `ctrl + shift + -` | `ctrl + shift + _`
#   3. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#
###########################################################
{
  programs.kitty = {
    enable = true;
    # package = pkgs.kitty;
    # kitty has catppuccin theme built-in,
    # all the built-in themes are packaged into an extra package named `kitty-themes`
    # and it's installed by home-manager if `theme` is specified.
    themeFile = "Dracula";
    font = {
      name = "Maple Mono NF CN";
      # use different font size on macOS
      size = 11;
    };

    # consistent with other terminal emulators
    keybindings = {
      "ctrl+shift+m" = "toggle_maximized";
      "ctrl+shift+f" = "show_scrollback"; # search in the current window
    };

    settings = {
      macos_option_as_alt = true; # Option key acts as Alt on macOS
      tab_bar_edge = "top"; # tab bar on top
      confirm_os_window_close = 0;
      update_check_interval = 0;

      bell_on_tab = "yes";
      window_alert_on_bell = "no";
      enable_audio_bell = false;
      clipboard_control = "read-clipboard write-clipboard read-primary write-primary";
      paste_actions = "no-op";

    };
    extraConfig = ''
      map alt+left send_text all \x1b\x62
      map alt+right send_text all \x1b\x66
      modify_font cell_height 120%
    '';
    # macOS specific settings
    darwinLaunchOptions = [ "--start-as=maximized" ];
  };
}

