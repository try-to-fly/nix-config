{ lib, pkgs, ... }:

{
  # Enable WezTerm via Home Manager (macOS only)
  programs.wezterm = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    package = pkgs.wezterm;

    # Strictly using WezTerm's Lua config through Home Manager
    # Docs: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.wezterm.extraConfig
    #       https://wezfurlong.org/wezterm/config/files.html
    extraConfig = ''
      local wezterm = require 'wezterm'
      local act = wezterm.action

      -- Start maximized (similar to kitty's darwinLaunchOptions)
      wezterm.on('gui-startup', function(cmd)
        local _, _, window = wezterm.mux.spawn_window(cmd or {})
        window:gui_window():maximize()
      end)

      return {
        -- Ensure there is no implicit gap around the grid
        window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
        -- Keep window size aligned to whole-cell rows/cols to avoid extra pixels
        use_resize_increments = true,
        -- Match kitty font family and size
        font = wezterm.font_with_fallback({
          'Maple Mono NF CN',
          'JetBrainsMono Nerd Font',
          'Symbols Nerd Font',
        }),
        font_size = 11.0,
        line_height = 1.2, -- kitty: modify_font cell_height 120%
        max_fps = 120,

        -- Match kitty's Dracula theme
        color_scheme = 'Dracula',

        -- Make Option act like Alt on macOS (kitty: macos_option_as_alt = true)
        send_composed_key_when_left_alt_is_pressed = false,
        send_composed_key_when_right_alt_is_pressed = true,

        -- Disable audible bell (kitty: enable_audio_bell = false)
        audible_bell = 'Disabled',

        -- Match kitty's UI/behavioral prefs
        tab_bar_at_bottom = false, -- kitty: tab_bar_edge = "top"
        hide_tab_bar_if_only_one_tab = true,
        window_close_confirmation = 'NeverPrompt', -- kitty: confirm_os_window_close = 0
        check_for_updates = false, -- kitty: update_check_interval = 0

        -- Keybindings similar to kitty
        keys = {
          -- Toggle fullscreen (kitty: toggle_maximized)
          { key = 'M', mods = 'CTRL|SHIFT', action = act.ToggleFullScreen },
          -- Search in scrollback (close to kitty's show_scrollback)
          { key = 'F', mods = 'CTRL|SHIFT', action = act.Search('CurrentSelectionOrEmptyString') },
          -- Word-wise move with Option + Left/Right
          { key = 'LeftArrow', mods = 'ALT',  action = act.SendString(string.char(27) .. 'b') }, -- ESC-b
          { key = 'RightArrow', mods = 'ALT', action = act.SendString(string.char(27) .. 'f') }, -- ESC-f
        },
      }
    '';
  };
}
