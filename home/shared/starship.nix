{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;

    settings = {
      right_format = "\${env_var.http_proxy}";
      battery = {
        full_symbol = "🔋 ";
        charging_symbol = "⚡️ ";
        discharging_symbol = "💀 ";
      };
      git_commit = {
        commit_hash_length = 6;
        tag_symbol = "🔖 ";
      };
      git_metrics = {
        added_style = "bold blue";
        format = "[+$added]($added_style)/[-$deleted]($deleted_style) ";
      };
      git_state = {
        format = "[\($state( $progress_current of $progress_total)\)]($style) ";
        cherry_pick = "[🍒 PICKING](bold red)";
      };
      cmd_duration = {
        min_time = 2000;
        format = "took [$duration](bold yellow) ";
      };
      env_var = {
        http_proxy = {
          variable = "http_proxy";
          format = "🌐 ";
          style = "bold green";
        };
      };

      # Python 版本显示
      python = {
        symbol = "🐍 ";
        format = "via [\${symbol}\${pyenv_prefix}(\${version} )(\\(\$virtualenv\\) )](\$style)";
        style = "bold yellow";
        pyenv_version_name = true;
      };

      # Node.js 版本显示
      nodejs = {
        symbol = "⬢ ";
        format = "via [\${symbol}(\${version} )](\$style)";
        style = "bold green";
      };

      # Rust 版本显示
      rust = {
        symbol = "🦀 ";
        format = "via [\${symbol}(\${version} )](\$style)";
        style = "bold red";
      };

      # Docker 上下文显示
      docker_context = {
        symbol = "🐳 ";
        format = "via [\${symbol}\${context}](\$style) ";
        style = "blue bold";
        only_with_files = true;
      };

      # Nix shell 显示
      nix_shell = {
        symbol = "❄️ ";
        format = "via [\${symbol}\${state}( \\(\${name}\\))](\$style) ";
        style = "bold blue";
      };
    };
  };
}
