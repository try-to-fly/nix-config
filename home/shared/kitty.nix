{
  lib,
  pkgs,
  ...
}:
###########################################################
#
# Kitty Configuration (macOS only)
#
# Useful Hot Keys for Linux(replace `ctrl + shift` with `cmd` on macOS)):
#   1. Increase Font Size: `ctrl + shift + =` | `ctrl + shift + +`
#   2. Decrease Font Size: `ctrl + shift + -` | `ctrl + shift + _`
#   3. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#
###########################################################
{
  programs.kitty = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    package = pkgs.emptyDirectory; # 不安装 kitty 包，仅管理配置文件
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
      confirm_os_window_close = 0;
      update_check_interval = 0;

      # 使用类似 tmux 的底部 tab 状态栏，替代默认的 fade 色块样式。
      tab_bar_edge = "bottom";
      tab_bar_style = "custom";
      tab_powerline_style = "angled";
      tab_bar_align = "left";
      tab_bar_min_tabs = 1;
      # kitty 会丢掉未加引号的首尾空格，用固定宽度让序号居中，tab 才真正变宽。
      tab_title_template = "{index:^7}";
      active_tab_foreground = "#f8f8f2";
      active_tab_background = "#6272a4";
      active_tab_font_style = "bold";
      inactive_tab_foreground = "#f8f8f2";
      inactive_tab_background = "#44475a";
      inactive_tab_font_style = "normal";
      tab_bar_background = "#282a36";

      bell_on_tab = "yes";
      window_alert_on_bell = "no";
      enable_audio_bell = false;
      clipboard_control = "read-clipboard write-clipboard read-primary write-primary";
      copy_on_select = "no"; # 保持显式复制，不让鼠标选区覆盖系统剪贴板
      paste_actions = "no-op";

      scrollback_lines = 10000;
      scrollback_pager_history_size = 10; # 额外保留约十万行普通文本供 pager 搜索
      enabled_layouts = "splits,stack";
      map_timeout = 3.0; # 与现有 tmux prefix-timeout 保持一致

    };
    extraConfig = ''
      map alt+left send_text all \x1b\x62
      map alt+right send_text all \x1b\x66

      # 使用反引号进入一次性的 tmux 风格 prefix mode。
      # 执行动作、按 Esc、按下未映射按键或等待 3 秒后自动退出。
      map --new-mode prefix --on-action end --on-unknown end --timeout 3.0 `
      map --mode prefix esc pop_keyboard_mode
      map --mode prefix ` send_text all \x60

      # kitty 的 window 对应 tmux pane，kitty 的 tab 对应 tmux window。
      map --mode prefix - launch --location=hsplit --cwd=current
      map --mode prefix | launch --location=vsplit --cwd=current
      map --mode prefix left neighboring_window left
      map --mode prefix right neighboring_window right
      map --mode prefix up neighboring_window up
      map --mode prefix down neighboring_window down
      map --mode prefix o next_window
      map --mode prefix q focus_visible_window
      map --mode prefix x close_window_with_confirmation
      map --mode prefix z toggle_layout stack

      # 滚屏浏览、搜索与原生 hints 摘取。
      map --mode prefix [ show_scrollback
      map --mode prefix / search_scrollback
      map --mode prefix y kitten hints --type=line --multiple --program=@ --multiple-joiner=newline
      map --mode prefix shift+y copy_last_command_output
      map --mode prefix g show_last_non_empty_command_output
      map --mode prefix u open_url_with_hints
      map --mode prefix f kitten hints --type=path --program=-
      map --mode prefix e kitten hints --type=linenum --linenum-action=tab nvim +{line} {path}

      # 创建和切换标签页（对应 tmux window）。
      map --mode prefix c new_tab_with_cwd
      map --mode prefix n next_tab
      map --mode prefix p previous_tab
      map --mode prefix l goto_tab 0
      map --mode prefix w select_tab
      map --mode prefix 1 goto_tab 1
      map --mode prefix 2 goto_tab 2
      map --mode prefix 3 goto_tab 3
      map --mode prefix 4 goto_tab 4
      map --mode prefix 5 goto_tab 5
      map --mode prefix 6 goto_tab 6
      map --mode prefix 7 goto_tab 7
      map --mode prefix 8 goto_tab 8
      map --mode prefix 9 goto_tab 9

      modify_font cell_height 120%

      # 使用 Command+点击打开链接
      mouse_map cmd+left release grabbed,ungrabbed mouse_handle_click link
    '';
    # macOS specific settings
    darwinLaunchOptions = [ "--start-as=maximized" ];
  };

  # Dracula 风格 tab 状态栏：左侧笑脸在 prefix mode 中由绿色切换为黄色。
  xdg.configFile."kitty/tab_bar.py" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      from kitty.fast_data_types import Screen, get_boss
      from kitty.tab_bar import (
          DrawData,
          ExtraData,
          TabBarData,
          as_rgb,
          draw_tab_with_powerline,
      )


      DRACULA_BACKGROUND = as_rgb(0x282A36)
      DRACULA_GREEN = as_rgb(0x50FA7B)
      DRACULA_YELLOW = as_rgb(0xF1FA8C)


      def draw_tab(
          draw_data: DrawData,
          screen: Screen,
          tab: TabBarData,
          before: int,
          max_tab_length: int,
          index: int,
          is_last: bool,
          extra_data: ExtraData,
      ) -> int:
          if index == 1:
              tab_background = screen.cursor.bg
              tab_foreground = screen.cursor.fg
              tab_bold = screen.cursor.bold
              tab_italic = screen.cursor.italic

              prefix_active = get_boss().mappings.current_keyboard_mode_name == "prefix"
              status_background = DRACULA_YELLOW if prefix_active else DRACULA_GREEN

              screen.cursor.bg = status_background
              screen.cursor.fg = DRACULA_BACKGROUND
              screen.cursor.bold = True
              screen.cursor.italic = False
              screen.draw(" ☺ ")

              screen.cursor.bg = tab_background
              screen.cursor.fg = status_background
              screen.draw("")

              screen.cursor.fg = tab_foreground
              screen.cursor.bold = tab_bold
              screen.cursor.italic = tab_italic
              screen.draw(" ")

              prefix_width = screen.cursor.x - before
              before = screen.cursor.x
              max_tab_length = max(1, max_tab_length - prefix_width)

          return draw_tab_with_powerline(
              draw_data,
              screen,
              tab,
              before,
              max_tab_length,
              index,
              is_last,
              extra_data,
          )
    '';
  };
}
