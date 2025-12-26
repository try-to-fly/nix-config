{
  config,
  username,
  pkgs,
  lib,
  ...
}:
{
  programs.git = {
    enable = true;
    package = pkgs.git;
    lfs.enable = true;

    # 包含 sops 解密的 git 配置（含 email）
    includes = [
      { path = config.sops.secrets.git.path; }
    ];

    settings = {
      user = {
        name = username;
        # email 通过 sops secrets include 设置
      };
      gpg = {
        format = "ssh";
      };
      core = {
        editor = "nvim";
      };
      init = {
        defaultBranch = "main";
      };
      push = {
        autoSetupRemote = true;
        followTags = true;
      };
      pull = {
        rebase = true;
        ff = "only";
      };
      rerere = {
        enabled = true;
      };
    };
    ignores = [
      ".DS_Store"
    ];
    signing = {
      signByDefault = true;
      # 使用 config.home.homeDirectory 以支持跨平台
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
    };
  };

  programs.delta = {
    enable = false;
    options = {
      line-numbers = true;
      side-by-side = true;
      diff-so-fancy = true;
      navigate = true;
    };
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };
}
