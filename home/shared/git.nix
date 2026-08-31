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

    # 包含 sops 解密的 git 配置（含 email），fox 用户不使用 sops
    includes = lib.optionals (username != "fox") [
      { path = config.sops.secrets.git.path; }
    ];

    settings = {
      user = {
        name = username;
        # 除 fox 外，email 通过 sops secrets include 设置
      }
      // lib.optionalAttrs (username == "fox") {
        email = "991854471@qq.com";
      };
      advice.skippedCherryPicks = false;
      core = {
        editor = "nvim";
      };
      branch = {
        sort = "-committerdate";
      };
      checkout = {
        defaultRemote = "origin";
      };
      commit = {
        verbose = true;
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "zebra";
        colorMovedWS = "allow-indentation-change";
      };
      fetch = {
        prune = true;
      };
      http = {
        proxy = "http://127.0.0.1:7890";
      };
      https = {
        proxy = "http://127.0.0.1:7890";
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
      };
      rebase = {
        autoStash = true;
      };
      rerere = {
        enabled = true;
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      safe = {
        bareRepository = "explicit";
      };
      status = {
        showStash = true;
      };
      tag = {
        sort = "-version:refname";
      };
      worktree = {
        guessRemote = true;
      };
    };
    ignores = [
      ".DS_Store"
    ];
    signing = {
      format = "ssh";
      signByDefault = true;
      # 使用 config.home.homeDirectory 以支持跨平台
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
    };
  };

  # programs.git 把 ~/.config/git/config 做成 store symlink，git config --global
  # 会写那个只读文件。只要 ~/.gitconfig 存在，--global 就改它；Git 仍会同时读两份。
  # 不要用 home.file 托管 ~/.gitconfig，否则又会变成只读 symlink。
  home.activation.ensureWritableGitconfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    gitconfig="${config.home.homeDirectory}/.gitconfig"
    if [[ ! -e "$gitconfig" ]]; then
      touch "$gitconfig"
    elif [[ -L "$gitconfig" ]]; then
      echo "warning: $gitconfig is a symlink; git config --global will not be writable" >&2
    fi
  '';

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
