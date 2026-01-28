{
  hostname,
  username,
  pkgs,
  ...
}:

#############################################################
#
#  Host & Users configuration
#
#############################################################

{
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # nix-darwin 要求设置主用户
  system.primaryUser = username;

  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
    shell = pkgs.fish; # 设置 fish 为用户默认 shell
  };

  nix.settings.trusted-users = [ username ];
}
