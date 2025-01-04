{ username, useremail, pkgs, ... }: {

  programs.git = {
    enable = true;
    package = pkgs.git;
    lfs.enable = true;

    userName = username;
    userEmail = useremail;

    extraConfig = {
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
      enable = true;
      options = {
        features = "side-by-side";
      };
    };
  };
}

