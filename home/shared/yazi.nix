{ pkgs, lib, ... }:
{
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      mgr = {
        show_hidden = true;
        sort_dir_first = true;
        linemode = "size";
        # 布局比例：父目录:当前:预览
        ratio = [ 1 4 3 ];
        sort_by = "natural";
        sort_sensitive = false;
        # 光标距离边缘的偏移
        scrolloff = 5;
        # 终端标题格式
        title_format = "Yazi: {cwd}";
      };

      preview = {
        wrap = "no";
        max_width = 600;
        max_height = 900;
      };

      opener = {
        edit = [
          { run = ''nvim "$@"''; block = true; }
        ];
      };
    };

    # 键位映射
    keymap = {
      mgr.prepend_keymap = [
        # macOS Quick Look 预览
        { on = [ "<C-p>" ]; run = ''shell -- qlmanage -p "$@"''; desc = "Quick Look preview"; }
      ];
    };

    # 初始化脚本 - 配置 zoxide 插件
    initLua = ''
      require("zoxide"):setup {
        update_db = true,
      }
    '';
  };
}
