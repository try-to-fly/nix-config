{ pkgs, lib, ... }:
let
  githubActionsStatus = pkgs.writeShellScript "tmux-github-actions-status" ''
    set -euo pipefail

    mode="print"
    pane_path="''${1:-$PWD}"
    if [ "''${1:-}" = "refresh" ]; then
      mode="refresh"
      pane_path="''${2:-$PWD}"
    fi

    ttl=60
    no_status="__none__"
    git="${pkgs.git}/bin/git"
    gh="${pkgs.gh}/bin/gh"
    grep="${pkgs.gnugrep}/bin/grep"
    sha256sum="${pkgs.coreutils}/bin/sha256sum"
    date="${pkgs.coreutils}/bin/date"
    nohup="${pkgs.coreutils}/bin/nohup"
    mkdir="${pkgs.coreutils}/bin/mkdir"
    mv="${pkgs.coreutils}/bin/mv"

    [ -d "$pane_path" ] || exit 0
    [ -x "$gh" ] || exit 0
    "$git" -C "$pane_path" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
    "$git" -C "$pane_path" remote -v 2>/dev/null | "$grep" -E 'github\.com[:/]' >/dev/null || exit 0

    branch="$("$git" -C "$pane_path" branch --show-current 2>/dev/null || true)"
    [ -n "$branch" ] || exit 0

    repo_root="$("$git" -C "$pane_path" rev-parse --show-toplevel 2>/dev/null)" || exit 0
    repo_key="$(printf '%s:%s' "$repo_root" "$branch" | "$sha256sum")"
    repo_key="''${repo_key%% *}"
    cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/tmux-gh-actions"
    cache_file="$cache_dir/$repo_key"
    lock_file="$cache_file.lock"
    now="$("$date" +%s)"

    read_first_line() {
      IFS= read -r line < "$1" 2>/dev/null || true
      printf '%s' "''${line:-}"
    }

    read_second_line() {
      ${pkgs.gnused}/bin/sed -n '2p' "$1" 2>/dev/null || true
    }

    is_number() {
      case "$1" in
        "" | *[!0-9]*) return 1 ;;
        *) return 0 ;;
      esac
    }

    cache_is_stale() {
      [ -r "$cache_file" ] || return 0

      cache_time="$(read_first_line "$cache_file")"
      is_number "$cache_time" || return 0
      [ $((now - cache_time)) -ge "$ttl" ]
    }

    print_cache() {
      [ -r "$cache_file" ] || return 1

      output="$(read_second_line "$cache_file")"
      [ -n "$output" ] || return 1
      [ "$output" != "$no_status" ] || return 1

      printf ' GH %s ' "$output"
    }

    refresh_cache() {
      if ! cache_is_stale; then
        exit 0
      fi

      if [ -r "$lock_file" ]; then
        lock_time="$(read_first_line "$lock_file")"
        if is_number "$lock_time" && [ $((now - lock_time)) -lt 30 ]; then
          exit 0
        fi
      fi

      "$mkdir" -p "$cache_dir" || exit 0
      printf '%s\n' "$now" > "$lock_file" || exit 0
      trap 'rm -f "$lock_file"' EXIT

      cd "$repo_root" || exit 0

      status="$(
        "$gh" run list \
          --branch "$branch" \
          --limit 1 \
          --json status,conclusion \
          --jq '.[0] | if . == null then empty else if .status != "completed" then .status else (.conclusion // .status) end end' \
          2>/dev/null
      )" || exit 0

      if [ -z "$status" ]; then
        output="$no_status"
      else
        case "$status" in
          success) output="ok" ;;
          in_progress) output="run" ;;
          queued | waiting | pending | requested) output="wait" ;;
          failure | startup_failure | timed_out) output="fail" ;;
          cancelled) output="cancel" ;;
          action_required) output="need" ;;
          skipped | neutral | stale) output="$status" ;;
          *) output="$status" ;;
        esac
      fi

      tmp_file="$cache_file.$$"
      {
        printf '%s\n' "$now"
        printf '%s\n' "$output"
      } > "$tmp_file"
      "$mv" "$tmp_file" "$cache_file"
    }

    case "$mode" in
      refresh)
        refresh_cache
        ;;
      print)
        if cache_is_stale; then
          "$mkdir" -p "$cache_dir" 2>/dev/null || true
          "$nohup" "$0" refresh "$pane_path" >/dev/null 2>&1 &
        fi
        print_cache || true
        ;;
      *)
        exit 0
        ;;
    esac
  '';
in
{
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 50000;
    aggressiveResize = true;
    baseIndex = 1;
    mouse = true;
    prefix = "`";
    keyMode = "vi";
    sensibleOnTop = true;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      sidebar
      continuum
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-plugins "battery cpu-usage ram-usage ssh-session"
          set -g @dracula-show-flags true
          set -g @dracula-show-fahrenheit false
          set -g @dracula-fixed-location "Hangzhou"
          set -g @dracula-cpu-display-load false
        '';
      }
    ];
    extraConfig = ''
      # 图片预览支持 (yazi)
      set -gq allow-passthrough on
      set -ga update-environment TERM_PROGRAM

      set -g visual-activity off
      set -g renumber-windows on
      # tmux 3.6a 的默认值就是 3000ms；这里保留是为了显式说明语义。
      # 如果想明显感知前缀超时，需要改成更小的值，例如 500 或 800。
      set -g prefix-timeout 3000
      set -s set-clipboard on
      set -g status-right-length 140

      # 根据当前 active pane 的目录异步展示 GitHub Actions 状态。
      set -ga status-right "#[fg=#282a36]#[bg=#bd93f9]#(${githubActionsStatus} #{q:pane_current_path})"
      set-hook -g after-select-pane 'refresh-client -S'
      set-hook -g after-select-window 'refresh-client -S'

      # fix tmux default shell : https://github.com/nix-community/home-manager/issues/5952
      set -gu default-command
      set -g default-shell "$SHELL"

      set -g @no-scroll-on-exit-copy-mode 'on'
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-no-clear 'pbcopy'

      bind - splitw -v -c '#{pane_current_path}' # 垂直方向新增面板，默认进入当前目录
      bind | splitw -h -c '#{pane_current_path}' # 水平方向新增面板，默认进入当前目录


    '';
  };
}

/**
  plugins = with pkgs.tmuxPlugins; [
  copycat
  open
  resurrect
  yank
  vim-tmux-navigator
  ];

  1. https://github.com/namishh/crystal/blob/cc37b56577e951b0c98c1a97840febdce1e39691/home/namish/conf/shell/tmux/default.nix#L4
*/
