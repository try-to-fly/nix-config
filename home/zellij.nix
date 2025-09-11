{ pkgs, ... }:

{
  # 安装并启用 Zellij
  programs.zellij = {
    enable = true;
    package = pkgs.zellij;
  };

  # 写入 Zellij 配置（KDL），将反引号作为“tmux 前缀”以进入 Tmux 模式
  # 并在 Tmux 模式下：
  # - 支持按两次前缀发送前缀（与 tmux send-prefix 行为一致）
  # - 映射 '-' 为水平分屏（向下），'|' 为垂直分屏（向右），保持与当前 tmux 习惯一致
  xdg.configFile."zellij/config.kdl".text = ''
    keybinds {
      shared_except "tmux" "locked" {
        bind "`" { SwitchToMode "Tmux"; }
      }
      tmux {
        bind "`" { Write 96; SwitchToMode "Normal"; }
        bind "-" { NewPane "Down"; SwitchToMode "Normal"; }
        bind "|" { NewPane "Right"; SwitchToMode "Normal"; }
        // prefix + 数字 切换到对应 tab（1-9）
        bind "1" { GoToTab 1; SwitchToMode "Normal"; }
        bind "2" { GoToTab 2; SwitchToMode "Normal"; }
        bind "3" { GoToTab 3; SwitchToMode "Normal"; }
        bind "4" { GoToTab 4; SwitchToMode "Normal"; }
        bind "5" { GoToTab 5; SwitchToMode "Normal"; }
        bind "6" { GoToTab 6; SwitchToMode "Normal"; }
        bind "7" { GoToTab 7; SwitchToMode "Normal"; }
        bind "8" { GoToTab 8; SwitchToMode "Normal"; }
        bind "9" { GoToTab 9; SwitchToMode "Normal"; }
      }
    }
  '';
}
