{ pkgs, ... }:
{
  programs.ripgrep = {
    enable = true;
    package = pkgs.ripgrep;
    arguments = [
      # 排除目录
      "--glob=!.git/*"
      "--glob=!node_modules/*"
      "--glob=!target/*"
      "--glob=!.direnv/*"
      "--glob=!dist/*"
      "--glob=!*.lock"

      # 智能搜索
      "--smart-case"
      "--hidden"

      # 限制行宽，避免超长行
      "--max-columns=150"
      "--max-columns-preview"

      # 颜色配置
      "--colors=line:style:bold"
      "--colors=path:fg:green"
      "--colors=path:style:bold"
      "--colors=match:fg:black"
      "--colors=match:bg:yellow"
    ];
  };
}
