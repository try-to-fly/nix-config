{ pkgs, ... }:

###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#
###################################################################################
{
  system = {
    stateVersion = 5;
    defaults = {
      menuExtraClock.Show24Hour = true; # show 24 hour clock

      # other macOS's defaults configuration.
      # ......
    };

    primaryUser = "smile";
  };

  environment = {
    # 参考: https://write.rog.gr/writing/using-touchid-with-tmux/
    etc."pam.d/sudo_local".text = ''
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth       sufficient     pam_tid.so
    '';
  };

  # Add ability to used TouchID for sudo authentication
  # security.pam.services.sudo_local.touchIdAuth = true;

  # 确保 nix-darwin 激活脚本在启动时运行
  # 这修复了重启后 /run/current-system 不存在的问题
  system.activationScripts.postActivation.text = ''
    # 确保激活服务在系统启动时运行
    echo "Checking nix-darwin activation status..."
    if [ ! -e /run/current-system ]; then
      echo "Warning: /run/current-system does not exist, may need manual activation"
    fi
  '';

  # 添加 LaunchDaemon 确保服务持久化
  launchd.daemons.nix-darwin-activation-check = {
    script = ''
      # 检查并确保 nix-darwin 激活服务正常运行
      if ! launchctl print system/org.nixos.activate-system &>/dev/null; then
        echo "Reloading nix-darwin activation service..."
        launchctl bootstrap system /Library/LaunchDaemons/org.nixos.activate-system.plist || true
        launchctl kickstart -k system/org.nixos.activate-system || true
      fi
    '';
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/var/log/nix-darwin-activation-check.log";
      StandardErrorPath = "/var/log/nix-darwin-activation-check.error.log";
    };
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = false; # 禁用 zsh 作为默认

  # Enable fish shell
  programs.fish.enable = true;

}
