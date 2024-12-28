{ pkgs, ... }: {

  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  # TODO Fell free to modify this file to fit your needs.
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    neovim
    ripgrep
    lazygit
    fd
    lazydocker
    jq
    bat
    imagemagick
    eza
    fzf
    gh
    delta
    git-extras
    git-lfs
    httpie
    mcfly
    nnn
    wget
    curl
    tmux
    zoxide
    yadm
    poetry
    chafa
    direnv
    git
    ffmpeg
    eza
    exiftool
    fx
    btop
    zsh-syntax-highlighting
    bun
    flyctl
    starship
    yazi
    duf
    scc
    nushell
    difftastic
    pipenv
    nmap
    silver-searcher
    tre-command
    git-sizer
    mas
    gping
    navi
    dua
    glances
    rclone
    nodejs_23
    corepack_23
    pm2
    python311
    python311Packages.pip
    lua
    luarocks
    lla # https://github.com/triyanox/lla
    television # https://github.com/alexpasmantier/television
    m-cli # https://github.com/rgcr/m-cli
    ghostscript # PDF utils https://www.ghostscript.com/
  ];

  environment.variables.EDITOR = "nvim";

  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      # cleanup = "zap";
    };

    taps = [
      "homebrew/services"
    ];

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [ ];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      "only-switch"
      "chromium"
      "microsoft-remote-desktop"
      "rustdesk"
      "iina"
      "stats"
      "sonic-pi"
      "wireshark"
      "kitty"
      "visual-studio-code"
      "sublime-text"
      "keka" # https://www.keka.io
      "apifox" # https://www.apifox.com
    ];
  };
}
