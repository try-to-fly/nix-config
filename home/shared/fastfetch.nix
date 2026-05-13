{ lib, pkgs, ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        padding = {
          right = 2;
        };
      };
      modules = [
        {
          type = "hostname";
          key = "Host";
          keyIcon = "🖥️";
        }
        {
          type = "distro";
          key = "Distro";
          keyIcon = "🐧";
        }
        {
          type = "kernel";
          key = "Kernel";
          keyIcon = "⚙️";
        }
        {
          type = "uptime";
          key = "Uptime";
          keyIcon = "⏳";
        }
        "break"
        {
          type = "localip";
          key = "Local IP";
          keyIcon = "🏠";
        }
        {
          type = "publicip";
          key = "Public IP";
          keyIcon = "🌐";
        }
        {
          type = "dns";
          key = "DNS";
          keyIcon = "📡";
        }
        "break"
        {
          type = "cpu";
          key = "CPU";
          keyIcon = "🖥️";
          temp = true;
        }
        {
          type = "gpu";
          key = "GPU";
          keyIcon = "🎮";
        }
        {
          type = "memory";
          key = "Memory";
          keyIcon = "🧠";
        }
        {
          type = "disk";
          key = "Disk";
          keyIcon = "💿";
        }
        {
          type = "Battery";
          key = "Battery";
        }
        {
          type = "Wifi";
          key = "Wifi";
        }
        "break"
        {
          type = "users";
          key = "Users";
          keyIcon = "👥";
        }
      ];
    };
  };
}
