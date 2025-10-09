{
  lib,
  pkgs,
  username,
  ...
}:

{
  # 导入所有共享配置（平台特定配置在各模块内部处理）
  imports = [
    ./shared/starship.nix
    ./shared/yazi.nix
    ./shared/lazygit.nix
    ./shared/tmux.nix
    ./shared/ripgrep.nix
    ./shared/fd.nix
    ./shared/sqlite3.nix
    ./shared/bat.nix
    ./shared/fish.nix
    ./shared/atuin.nix
    ./shared/zoxide.nix
    ./shared/direnv.nix
    ./shared/git.nix
    ./shared/zellij.nix
    # macOS 特定的终端应用（在模块内部判断平台）
    ./shared/kitty.nix
    ./shared/wezterm.nix
  ];

  # 平台特定的包
  home.packages =
    (with pkgs; [
      # 基础字体
      nerd-fonts.jetbrains-mono
    ])
    ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
      # macOS 特定的字体
      nerd-fonts.droid-sans-mono
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
      nerd-fonts.zed-mono
    ])
    ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
      # Linux 服务器特定的包
      htop
      btop
      iotop
      nethogs
      curl
      wget
      nmap
      tcpdump
      iperf3
      tree
      rsync
      unzip
      p7zip
      jq
      yq
      docker-compose
    ]);

  # 程序配置
  programs = {
    home-manager.enable = true;
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    man.enable = true;
  };

  # Home Manager 基本配置
  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "24.05";
  };

  # 非 NixOS Linux 系统配置(如 Ubuntu)
  targets = lib.optionalAttrs pkgs.stdenv.isLinux {
    # 启用通用 Linux 支持,设置必要的环境变量和路径
    genericLinux.enable = true;
  };

  # 字体配置(仅 Linux)
  fonts = lib.optionalAttrs pkgs.stdenv.isLinux {
    # 启用 fontconfig,让 Nix 安装的字体(如 Nerd Fonts)可被系统识别
    fontconfig.enable = true;
  };
}