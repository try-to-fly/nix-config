{ config, lib, pkgs, username, hostname, useremail, ... }:

###################################################################################
#
#  NixOS configuration for Linux server
#
#  All the configuration options are documented here:
#    https://nixos.org/manual/nixos/stable/options.html
#
###################################################################################
{
  imports = [
    # 包含通用的 Nix 核心配置
    ../modules/nix-core.nix
  ];

  # 文件系统配置（模板配置，实际部署时需要根据硬件调整）
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 网络配置
  networking = {
    hostName = "${hostname}-server";
    networkmanager.enable = true;
    # 防火墙配置
    firewall = {
      enable = true;
      # 允许 SSH
      allowedTCPPorts = [ 22 ];
    };
  };

  # 时区和本地化
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # 用户配置
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
  };

  # 启用 sudo 免密码
  security.sudo.wheelNeedsPassword = false;

  # SSH 配置
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # 启用 Fish shell
  programs.fish.enable = true;

  # 系统级别的包
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    tmux
    screen
    rsync
    unzip
    tree
  ];

  # Docker 支持（可选）
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # 系统服务
  services = {
    # 日志管理
    journald = {
      extraConfig = ''
        SystemMaxUse=1G
        SystemMaxFiles=5
      '';
    };
  };

  # Nix 配置
  nix = {
    # 自动垃圾回收
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # 系统状态版本
  system.stateVersion = "24.05";
}