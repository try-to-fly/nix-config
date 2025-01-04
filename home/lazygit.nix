{ pkgs, ... }: {
  programs.lazygit = {
    enable = true;
    package = pkgs.lazygit;
    settings = {
      gui = {
        language = "zh-CN";
        nerdFontsVersion = "3";
        commitLength = {
          show = true;
        };
        mainPanelSplitMode = "flexible";
        timeFormat = "2006-01-02 15:04:05";
        shortTimeFormat = "15:04";
      };
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never --syntax-theme base16-256 --diff-so-fancy";
        };
      };
      notARepository = "skip";
      startupPopupVersion = 1;
      reporting = "off";
    };
  };
}



