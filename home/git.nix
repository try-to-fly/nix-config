{ username, useremail, pkgs, ... }: {

  programs.git = {
    enable = true;
    package = pkgs.git;
    lfs.enable = true;

    userName = username;
    userEmail = useremail;
    ignores = [
      ".DS_Store"
    ];
    signing = {
      signByDefault = true;
      key = "/Users/${username}/.ssh/id_ed25519";
    };
    extraConfig = {
      gpg.format = "ssh";
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

    delta = {
      enable = false;
      options = {
        line-numbers = true;
        side-by-side = true;
        diff-so-fancy = true;
        navigate = true;
      };
    };
    difftastic = {
      enable = true;
    };
  };
}

