{ pkgs, ... }:
{
  # https://docs.atuin.sh/configuration/config/
  programs.atuin = {
    enable = true;
    package = pkgs.atuin;
    flags = [ "--disable-up-arrow" ];
    settings = {
      update_check = false;
      auto_sync = true;
      show_help = true;
      enter_accept = true;
      ctrl_n_shortcuts = true;

      # 同步配置
      sync = {
        records = true;
      };

      # 后台同步守护进程
      daemon = {
        enabled = false;
        # sync_frequency = 300; # 5分钟同步一次
      };

      # 搜索配置
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";

      # 显示样式
      style = "compact";
      inline_height = 20;
      show_preview = true;

      # 历史记录过滤（不记录这些命令）
      history_filter = [
        "^cd"
        "^ls"
        "^exit"
        "^clear"
      ];

      # Dotfiles 同步
      dotfiles = {
        enabled = true;
      };
    };
  };
}
