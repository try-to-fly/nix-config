{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;

    settings = {
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
        min_time = 100;
        format = "take [$duration](bold yellow)";
      };
    };
  };
}
