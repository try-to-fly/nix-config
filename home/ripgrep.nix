{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--iglob=!.git"
      "--iglob=!node_modules"
    ];
  };
}
