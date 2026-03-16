{
  lib,
  pkgs,
  ...
}:
###########################################################
#
# Ghostty Configuration (macOS only)
#
###########################################################
{
  programs.ghostty = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    package = null; # 不安装 ghostty 包，用户已手动安装

    enableFishIntegration = true;

    settings = {
      # 主题 (Ghostty 内置 Dracula)
      theme = "Dracula";

      # 字体 (与 kitty/wezterm 一致)
      font-family = "Maple Mono NF CN";
      font-size = 11;
      font-thicken = true;
      font-thicken-strength = 60;

      # 行高 (kitty: modify_font cell_height 120%)
      adjust-cell-height = "20%";

      # macOS 设置
      macos-option-as-alt = true;
      macos-titlebar-style = "transparent";

      # 窗口行为
      confirm-close-surface = false;
      auto-update = "off";

      # 剪贴板
      clipboard-read = "allow";
      clipboard-write = "allow";

      # 快捷键: 切换全屏 (kitty: ctrl+shift+m = toggle_maximized)
      keybind = "ctrl+shift+m=toggle_fullscreen";
    };
  };
}
