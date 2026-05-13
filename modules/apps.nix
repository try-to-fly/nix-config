{
  lib,
  pkgs,
  username,
  ...
}:
{

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
    neovim # https://github.com/neovim/neovim
    nil # https://github.com/oxalica/nil
    nixfmt-rfc-style # https://github.com/NixOS/nixfmt
    statix # https://github.com/oppiliappan/statix
    lazydocker # https://github.com/jesseduffield/lazydocker
    jq # https://github.com/jqlang/jq
    imagemagick # https://github.com/ImageMagick/ImageMagick
    eza # https://github.com/eza-community/eza
    fzf # https://github.com/junegunn/fzf
    gh # https://github.com/cli/cli
    delta # https://github.com/dandavison/delta
    git-extras # https://github.com/tj/git-extras
    git-lfs # https://github.com/git-lfs/git-lfs
    httpie # https://github.com/httpie/httpie
    mcfly # https://github.com/cantino/mcfly
    nnn # https://github.com/jarun/nnn
    wget # https://www.gnu.org/software/wget/
    curl # https://github.com/curl/curl
    chafa # https://github.com/hpjansson/chafa
    ffmpeg # https://git.ffmpeg.org/ffmpeg.git
    exiftool # https://github.com/exiftool/exiftool
    fx # https://github.com/antonmedv/fx
    btop # https://github.com/aristocratos/btop
    bun # https://github.com/oven-sh/bun
    flyctl # https://github.com/superfly/flyctl
    duf # https://github.com/muesli/duf
    scc # https://github.com/boyter/scc
    difftastic # https://github.com/Wilfred/difftastic
    pipenv # https://github.com/pypa/pipenv
    nmap # https://nmap.org
    silver-searcher # https://github.com/ggreer/the_silver_searcher
    tre-command # https://github.com/dduan/tre
    git-sizer # https://github.com/github/git-sizer
    mas # https://github.com/mas-cli/mas
    gping # https://github.com/orf/gping
    navi # https://github.com/denisidoro/navi
    dua # https://github.com/Byron/dua-cli
    glances # https://github.com/nicolargo/glances
    rclone # https://github.com/rclone/rclone
    nodejs_24 # https://github.com/nodejs/node
    corepack_24 # https://github.com/nodejs/corepack
    pm2 # https://github.com/Unitech/pm2
    python312 # https://github.com/python/cpython
    python312Packages.pip # https://github.com/pypa/pip
    python312Packages.git-filter-repo # https://github.com/newren/git-filter-repo
    python312Packages.pipx # https://github.com/pypa/pipx
    python312Packages.pyyaml # https://github.com/yaml/pyyaml
    lua # https://www.lua.org
    luarocks # https://github.com/luarocks/luarocks
    lla # https://github.com/chaqchase/lla
    television # https://github.com/alexpasmantier/television
    m-cli # https://github.com/rgcr/m-cli
    ghostscript # https://www.ghostscript.com/
    graphicsmagick # http://www.graphicsmagick.org/
    nali # https://github.com/zu1k/nali
    unar # https://github.com/MacPaw/XADMaster
    ffmpegthumbnailer # https://github.com/dirkvdb/ffmpegthumbnailer
    jless # https://github.com/PaulJuliusMartinez/jless
    jc # https://github.com/kellyjonbrazil/jc
    # yt-dlp # 临时禁用：jeepney 依赖在 macOS 上构建失败
    rustc # https://github.com/rust-lang/rust
    rustup # https://github.com/rust-lang/rustup
    cargo # https://github.com/rust-lang/cargo
    otree # https://github.com/fioncat/otree
    postgresql # https://github.com/postgres/postgres
    aria2 # https://github.com/aria2/aria2
    go # https://github.com/golang/go
    uv # https://github.com/astral-sh/uv
    f2 # https://github.com/ayoisaiah/f2
    iperf3 # https://software.es.net/iperf/
    tesseract # https://github.com/tesseract-ocr/tesseract
    redis # https://github.com/redis/redis
    xcodegen # https://github.com/yonaskolb/XcodeGen
    coreutils # https://www.gnu.org/software/coreutils/
    fpp # https://github.com/facebook/PathPicker
    tokei # https://github.com/XAMPPRocky/tokei
    xh # https://github.com/ducaale/xh
    hexyl # https://github.com/sharkdp/hexyl
    viddy # https://github.com/sachaos/viddy
    # gitui
    doggo # https://github.com/mr-karan/doggo
    pandoc # https://github.com/jgm/pandoc
    platformio
    mihomo
  ];

  environment.shells = [
    pkgs.zsh
    pkgs.fish
  ];

  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      # cleanup = "zap";
    };

    taps = [
      # homebrew/services 已废弃，服务管理功能现已内置于 brew
    ];

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [
      "telnet" # https://github.com/apple-oss-distributions/remote_cmds
      "git-who" # https://github.com/sinclairtarget/git-who
    ];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      "chromium" # https://chromium.googlesource.com/chromium/src
      "font-maple-mono-nf-cn" # https://github.com/subframe7536/Maple-font
    ]
    ++ lib.optionals (username == "smile") [
      "iina" # https://github.com/iina/iina
      "sublime-text" # https://www.sublimetext.com/
      "keka" # https://github.com/aonez/Keka
    ];
  };
}
