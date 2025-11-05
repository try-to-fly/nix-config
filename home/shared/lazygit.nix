{ pkgs, ... }:
{
  programs.lazygit = {
    enable = true;
    package = pkgs.lazygit;
    settings = {
      promptToReturnFromSubprocess = false;
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
        pagers = [
          {
            colorArg = "always";
            externalDiffCommand = "difft";
          }
        ];
      };
      notARepository = "skip";
      startupPopupVersion = 1;
      reporting = "off";
    };
  };
}
