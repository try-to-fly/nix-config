{
  username,
  useremail,
  pkgs,
  ...
}:
{

  programs.git = {
    enable = true;
    package = pkgs.git;
    lfs.enable = true;

    settings = {
      user = {
        name = username;
        email = useremail;
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
      };
      pull = {
        rebase = true;
        ff = "only";
      };
    };
    ignores = [
      ".DS_Store"
    ];
    signing = {
      signByDefault = true;
      key = "/Users/${username}/.ssh/id_ed25519";
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
