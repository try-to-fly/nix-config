{
  lib,
  pkgs,
  ...
}:
###########################################################
#
# Kitty Configuration (macOS only)
#
# Useful Hot Keys for Linux(replace `ctrl + shift` with `cmd` on macOS)):
#   1. Increase Font Size: `ctrl + shift + =` | `ctrl + shift + +`
#   2. Decrease Font Size: `ctrl + shift + -` | `ctrl + shift + _`
#   3. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#
###########################################################
{
  programs.kitty = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    package = pkgs.emptyDirectory; # 不安装 kitty 包，仅管理配置文件
    # kitty has catppuccin theme built-in,
    # all the built-in themes are packaged into an extra package named `kitty-themes`
    # and it's installed by home-manager if `theme` is specified.
    themeFile = "Dracula";
    font = {
      name = "Maple Mono NF CN";
      # use different font size on macOS
      size = 11;
    };

    # consistent with other terminal emulators
    keybindings = {
      "ctrl+shift+m" = "toggle_maximized";
      "ctrl+shift+f" = "show_scrollback"; # search in the current window
    };

    settings = {
      macos_option_as_alt = true; # Option key acts as Alt on macOS
      confirm_os_window_close = 0;
      update_check_interval = 0;

      # 使用类似 tmux 的底部 tab 状态栏，替代默认的 fade 色块样式。
      tab_bar_edge = "bottom";
      tab_bar_style = "custom";
      tab_powerline_style = "angled";
      tab_bar_align = "left";
      tab_bar_min_tabs = 1;
      # kitty 会丢掉未加引号的首尾空格，用固定宽度让序号居中，tab 才真正变宽。
      tab_title_template = "{index:^7}";
      active_tab_foreground = "#f8f8f2";
      active_tab_background = "#6272a4";
      active_tab_font_style = "bold";
      inactive_tab_foreground = "#f8f8f2";
      inactive_tab_background = "#44475a";
      inactive_tab_font_style = "normal";
      tab_bar_background = "#282a36";

      bell_on_tab = "yes";
      window_alert_on_bell = "no";
      enable_audio_bell = false;
      clipboard_control = "read-clipboard write-clipboard read-primary write-primary";
      copy_on_select = "no"; # 保持显式复制，不让鼠标选区覆盖系统剪贴板
      paste_actions = "no-op";

      scrollback_lines = 10000;
      scrollback_pager_history_size = 10; # 额外保留约十万行普通文本供 pager 搜索
      enabled_layouts = "splits,stack";
      map_timeout = 3.0; # 与现有 tmux prefix-timeout 保持一致
      watcher = "watcher.py"; # 聚焦时刷新 tab 栏；退出时保存 last session
      # 可写 session 文件，不要用 xdg.configFile 管理（会被 home-manager 变成只读）。
      # 文件不存在时 kitty 忽略并开默认窗口。需要 kitty >= 0.46.2（on_quit），建议 >= 0.47.3。
      startup_session = "~/.local/share/kitty/last.kitty-session";

    };
    extraConfig = ''
      map alt+left send_text all \x1b\x62
      map alt+right send_text all \x1b\x66

      # 使用反引号进入一次性的 tmux 风格 prefix mode。
      # 执行动作、按 Esc、按下未映射按键或等待 3 秒后自动退出。
      map --new-mode prefix --on-action end --on-unknown end --timeout 3.0 `
      map --mode prefix esc pop_keyboard_mode
      map --mode prefix ` send_text all \x60

      # kitty 的 window 对应 tmux pane，kitty 的 tab 对应 tmux window。
      map --mode prefix - launch --location=hsplit --cwd=current
      map --mode prefix | launch --location=vsplit --cwd=current
      map --mode prefix left neighboring_window left
      map --mode prefix right neighboring_window right
      map --mode prefix up neighboring_window up
      map --mode prefix down neighboring_window down
      map --mode prefix o next_window
      map --mode prefix q focus_visible_window
      map --mode prefix x close_window_with_confirmation
      map --mode prefix z toggle_layout stack

      # 滚屏浏览、搜索与原生 hints 摘取。
      map --mode prefix [ show_scrollback
      map --mode prefix / search_scrollback
      map --mode prefix y kitten hints --type=line --multiple --program=@ --multiple-joiner=newline
      map --mode prefix shift+y copy_last_command_output
      map --mode prefix g show_last_non_empty_command_output
      map --mode prefix u open_url_with_hints
      map --mode prefix f kitten hints --type=path --program=-
      map --mode prefix e kitten hints --type=linenum --linenum-action=tab nvim +{line} {path}

      # 创建和切换标签页（对应 tmux window）。
      map --mode prefix c new_tab_with_cwd
      map --mode prefix n next_tab
      map --mode prefix p previous_tab
      map --mode prefix l goto_tab 0
      map --mode prefix w select_tab
      map --mode prefix 1 goto_tab 1
      map --mode prefix 2 goto_tab 2
      map --mode prefix 3 goto_tab 3
      map --mode prefix 4 goto_tab 4
      map --mode prefix 5 goto_tab 5
      map --mode prefix 6 goto_tab 6
      map --mode prefix 7 goto_tab 7
      map --mode prefix 8 goto_tab 8
      map --mode prefix 9 goto_tab 9

      # 保存当前 splits/tabs/cwd，以及窗口里正在跑的前台进程（下次会重新执行）。
      # 正在跑的 grok 会写成 grok --resume <session-id>；proxyon && grok 会先开代理再 resume。
      # 若当时正在跑 rm/mv 之类命令，重启也会再跑一遍。
      map --mode prefix s kitten save_session.py
      map cmd+q kitten save_session.py --quit

      modify_font cell_height 120%

      # 使用 Command+点击打开链接
      mouse_map cmd+left release grabbed,ungrabbed mouse_handle_click link
    '';
    # macOS specific settings
    darwinLaunchOptions = [ "--start-as=maximized" ];
  };

  # Dracula 风格 tab 状态栏：左侧笑脸在 prefix mode 中由绿色切换为黄色。
  # Grok 任务完成时，对应 tab 变成粉色，切到该 tab 或窗口重新聚焦后恢复。
  xdg.configFile."kitty/tab_bar.py" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      from kitty.fast_data_types import Screen, current_focused_os_window_id, get_boss
      from kitty.tab_bar import (
          DrawData,
          ExtraData,
          TabBarData,
          as_rgb,
          draw_tab_with_powerline,
      )


      DRACULA_BACKGROUND = as_rgb(0x282A36)
      DRACULA_GREEN = as_rgb(0x50FA7B)
      DRACULA_YELLOW = as_rgb(0xF1FA8C)
      DRACULA_PINK = as_rgb(0xFF79C6)
      GROK_DONE_RGB = 0xFF79C6
      GROK_DONE_FG_RGB = 0x282A36


      def grok_done_ids() -> set:
          return getattr(get_boss(), "grok_done_window_ids", set())


      def tab_is_grok_done(tab: TabBarData) -> bool:
          done = grok_done_ids()
          if not done:
              return False
          t = get_boss().tab_for_id(tab.tab_id)
          if t is None:
              return False
          return any(w.id in done for w in t)


      def clear_tab_grok_done(tab: TabBarData) -> None:
          done = grok_done_ids()
          t = get_boss().tab_for_id(tab.tab_id)
          if t is None:
              return
          for w in t:
              done.discard(w.id)


      def draw_tab(
          draw_data: DrawData,
          screen: Screen,
          tab: TabBarData,
          before: int,
          max_tab_length: int,
          index: int,
          is_last: bool,
          extra_data: ExtraData,
      ) -> int:
          viewed = (
              not extra_data.for_layout
              and tab.is_active
              and tab.os_window_id == current_focused_os_window_id()
          )
          if viewed:
              clear_tab_grok_done(tab)
          elif tab_is_grok_done(tab):
              screen.cursor.bg = DRACULA_PINK
              screen.cursor.fg = DRACULA_BACKGROUND

          nxt = extra_data.next_tab
          if nxt is not None and tab_is_grok_done(nxt):
              extra_data.next_tab = nxt._replace(
                  inactive_bg=GROK_DONE_RGB,
                  active_bg=GROK_DONE_RGB,
                  inactive_fg=GROK_DONE_FG_RGB,
                  active_fg=GROK_DONE_FG_RGB,
              )

          if index == 1:
              tab_background = screen.cursor.bg
              tab_foreground = screen.cursor.fg
              tab_bold = screen.cursor.bold
              tab_italic = screen.cursor.italic

              prefix_active = get_boss().mappings.current_keyboard_mode_name == "prefix"
              status_background = DRACULA_YELLOW if prefix_active else DRACULA_GREEN

              screen.cursor.bg = status_background
              screen.cursor.fg = DRACULA_BACKGROUND
              screen.cursor.bold = True
              screen.cursor.italic = False
              screen.draw(" ☺ ")

              screen.cursor.bg = tab_background
              screen.cursor.fg = status_background
              screen.draw("")

              screen.cursor.fg = tab_foreground
              screen.cursor.bold = tab_bold
              screen.cursor.italic = tab_italic
              screen.draw(" ")

              prefix_width = screen.cursor.x - before
              before = screen.cursor.x
              max_tab_length = max(1, max_tab_length - prefix_width)

          return draw_tab_with_powerline(
              draw_data,
              screen,
              tab,
              before,
              max_tab_length,
              index,
              is_last,
              extra_data,
          )
    '';
  };

  xdg.configFile."kitty/notifications.py" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      from kitty.fast_data_types import current_focused_os_window_id, get_boss

      SKIP_TITLES = {"Session ready"}
      GROK_TITLES = {
          "Turn complete",
          "Task complete",
          "Approval required",
          "Agent error",
      }


      def is_grok_task_notice(nc) -> bool:
          title = (nc.title or "").strip()
          if title in SKIP_TITLES:
              return False
          if nc.identifier == "grok":
              return True
          return title in GROK_TITLES


      def main(nc) -> bool:
          if not is_grok_task_notice(nc):
              return False
          window_id = nc.channel_id
          if not window_id:
              return False
          boss = get_boss()
          done = getattr(boss, "grok_done_window_ids", None)
          if done is None:
              done = set()
              boss.grok_done_window_ids = done
          done.add(window_id)
          window = boss.window_id_map.get(window_id)
          if window is not None:
              tab = window.tabref()
              if tab is not None:
                  tab.mark_tab_bar_dirty()
              # Kitty 窗口已在前台时，tab 变色就够了，不再弹系统横幅。
              if window.os_window_id == current_focused_os_window_id():
                  return True
          return False
    '';
  };

  xdg.configFile."kitty/save_session.py" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      import json
      import os
      import re
      import subprocess
      import traceback

      SESSION_PATH = os.path.expanduser("~/.local/share/kitty/last.kitty-session")
      GROK_ACTIVE_SESSIONS = os.path.expanduser("~/.grok/active_sessions.json")
      _saving = False

      _HAS_RESUME = re.compile(r"(^|[\s])(-c|--continue|--resume|-r)(\s|=|$)")
      _GROK_CMD = re.compile(r"(^|(?:&&|\|\||;)\s*)grok(?=\s|$)")


      def _load_active_grok_sessions():
          try:
              with open(GROK_ACTIVE_SESSIONS) as f:
                  items = json.load(f)
          except (OSError, json.JSONDecodeError):
              return {}
          if not isinstance(items, list):
              return {}
          items = [x for x in items if isinstance(x, dict) and x.get("pid") and x.get("session_id")]
          items.sort(key=lambda x: x.get("opened_at") or "")
          return {int(x["pid"]): str(x["session_id"]) for x in items}


      def _pid_tree():
          tree = {}
          try:
              out = subprocess.check_output(
                  ["ps", "-axo", "pid=,ppid="],
                  text=True,
                  errors="replace",
              )
          except OSError:
              return tree
          for line in out.splitlines():
              parts = line.split()
              if len(parts) < 2:
                  continue
              try:
                  pid, ppid = int(parts[0]), int(parts[1])
              except ValueError:
                  continue
              tree.setdefault(ppid, []).append(pid)
          return tree


      def _proc_pid(proc):
          if isinstance(proc, dict):
              return proc.get("pid")
          return getattr(proc, "pid", None)


      def _window_pids(window):
          pids = []
          child = getattr(window, "child", None)
          if child is None:
              return pids
          try:
              for proc in child.foreground_processes or []:
                  pid = _proc_pid(proc)
                  if pid:
                      pids.append(int(pid))
          except Exception:
              pass
          for attr in ("pid_for_cwd", "pid"):
              try:
                  pid = getattr(child, attr)
              except Exception:
                  pid = None
              if pid:
                  pids.append(int(pid))
          return pids


      def _session_id_for_window(window, pid_to_sid, tree):
          for pid in _window_pids(window):
              sid = pid_to_sid.get(pid)
              if sid:
                  return sid
          root = getattr(getattr(window, "child", None), "pid", None)
          if not root:
              return None
          stack = [int(root)]
          seen = set()
          while stack:
              pid = stack.pop()
              if pid in seen:
                  continue
              seen.add(pid)
              sid = pid_to_sid.get(pid)
              if sid:
                  return sid
              stack.extend(tree.get(pid, ()))
          return None


      def _inject_grok_resume(cmd, session_id):
          if not cmd or not session_id:
              return cmd
          if _HAS_RESUME.search(cmd):
              return cmd
          new_cmd, n = _GROK_CMD.subn(
              lambda m: m.group(1) + "grok --resume " + session_id,
              cmd,
              count=1,
          )
          return new_cmd if n else cmd


      def inject_grok_resume_into_windows(boss):
          pid_to_sid = _load_active_grok_sessions()
          if not pid_to_sid:
              return
          tree = _pid_tree()
          for window in boss.all_windows:
              sid = _session_id_for_window(window, pid_to_sid, tree)
              if not sid:
                  continue
              cmd = window.last_cmd_cmdline or ""
              if cmd and "grok" not in cmd:
                  continue
              if not cmd:
                  cmd = "grok"
              new_cmd = _inject_grok_resume(cmd, sid)
              if new_cmd:
                  window.last_cmd_cmdline = new_cmd


      def save_last_session(boss):
          global _saving
          if _saving:
              return
          _saving = True
          try:
              os.makedirs(os.path.dirname(SESSION_PATH), exist_ok=True)
              inject_grok_resume_into_windows(boss)
              boss.save_as_session(
                  "--save-only",
                  "--use-foreground-process",
                  SESSION_PATH,
              )
          except Exception:
              traceback.print_exc()
          finally:
              _saving = False


      def main(args):
          pass


      from kittens.tui.handler import result_handler


      @result_handler(no_ui=True)
      def handle_result(args, answer, target_window_id, boss):
          save_last_session(boss)
          if "--quit" in args:
              boss.quit()
    '';
  };

  xdg.configFile."kitty/watcher.py" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      import importlib.util
      import os

      _saved_for_quit = False


      def _session_save():
          path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "save_session.py")
          spec = importlib.util.spec_from_file_location("kitty_save_session", path)
          mod = importlib.util.module_from_spec(spec)
          spec.loader.exec_module(mod)
          return mod


      def _save_last_session(boss):
          _session_save().save_last_session(boss)


      def on_focus_change(boss, window, data):
          if not data.get("focused"):
              return
          tab = window.tabref()
          if tab is not None:
              tab.mark_tab_bar_dirty()


      def on_quit(boss, window, data):
          global _saved_for_quit
          _save_last_session(boss)
          _saved_for_quit = True


      def on_close(boss, window, data):
          if _saved_for_quit:
              return
          for w in boss.all_windows:
              if w is not window:
                  _save_last_session(boss)
                  return
    '';
  };
}
