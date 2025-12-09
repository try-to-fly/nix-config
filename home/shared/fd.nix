{ pkgs, ... }:
{
  programs.fd = {
    enable = true;
    package = pkgs.fd;
    hidden = true;
    ignores = [
      ".git/"
      "node_modules/"
      # Rust
      "target/"
      # Nix/direnv
      ".direnv/"
      # 构建产物
      "dist/"
      # Python
      "__pycache__/"
      "*.pyc"
      ".venv/"
      # macOS
      ".DS_Store"
      # 锁文件
      "*.lock"
    ];
    extraOptions = [
      "--follow" # 跟随符号链接
    ];
  };
}
