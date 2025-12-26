{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    package = pkgs.bat;
    config = {
      theme = "TwoDark";
      # 显示行号、Git 修改状态、文件头（无网格线）
      style = "numbers,changes,header";
      # 使用斜体（部分终端支持）
      italic-text = "always";
      # 制表符宽度
      tabs = "2";
      # 分页器配置
      pager = "less -FR";
    };
    # 自定义语法映射
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batgrep
    ];
  };
}
