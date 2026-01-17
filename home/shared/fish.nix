{ config, pkgs, lib, ... }:
{
  programs.fish = {
    enable = true;
    package = pkgs.fish;

    # Shell aliases (保持与zsh相同)
    shellAliases = {
      "ls" = "eza --time-style=long-iso --icons --hyperlink";
      "h" = "history";
      "j" = "z";
      "cat" = "bat --paging=never";
      "ocr" = "shortcuts run ocr -i";
      # ffmpeg 工具默认隐藏冗余 banner
      "ffmpeg" = "ffmpeg -hide_banner";
      "ffprobe" = "ffprobe -hide_banner";
      "ffplay" = "ffplay -hide_banner";
      # Proxy toggle aliases
      "proxyon" =
        "set -gx https_proxy http://127.0.0.1:7890; set -gx http_proxy http://127.0.0.1:7890; set -gx all_proxy socks5://127.0.0.1:7890; echo Proxy enabled";
      "proxyoff" = "set -e https_proxy; set -e http_proxy; set -e all_proxy; echo Proxy disabled";
    };

    # Fish abbreviations (智能缩写，fish特有功能)
    shellAbbrs = {
      # 导航缩写
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Git 缩写 (灵感来自 oh-my-zsh git 插件)
      g = "git";

      # git add
      ga = "git add";
      gaa = "git add --all";

      # git branch
      gb = "git branch";
      gba = "git branch -a";

      # git commit
      gc = "git commit -v";
      gca = "git commit -v -a";
      gcam = "git commit -a -m";

      # git checkout / switch
      gco = "git checkout";
      gcb = "git checkout -b";
      gcm = "git_checkout_main";

      # git fetch
      gf = "git fetch";

      # git log
      glog = "git log --oneline --decorate --graph";

      # git merge
      gm = "git merge";

      # git pull
      gl = "git pull";

      # git push
      gp = "git push";
      gpsup = "git push --set-upstream origin (current_branch)";

      # git cherry-pick
      gcp = "git cherry-pick";

      # git status
      gst = "git status";

      # 其他有用的缩写
      "ll" = "ls -la";
      "la" = "ls -la";
      "l" = "ls -l";
      "c" = "clear";
      "e" = "exit";
    };

    # Fish functions (替代oh-my-zsh的一些功能)
    functions = {
      # 创建目录并进入
      mkcd = ''
        mkdir -p $argv[1]
        and cd $argv[1]
      '';

      # 提取各种压缩文件
      extract = ''
        function extract --argument-names file
          switch $file
            case "*.tar.bz2"
              tar xjf $file
            case "*.tar.gz"
              tar xzf $file
            case "*.bz2"
              bunzip2 $file
            case "*.rar"
              unrar e $file
            case "*.gz"
              gunzip $file
            case "*.tar"
              tar xf $file
            case "*.tbz2"
              tar xjf $file
            case "*.tgz"
              tar xzf $file
            case "*.zip"
              unzip $file
            case "*.Z"
              uncompress $file
            case "*.7z"
              7z x $file
            case "*"
              echo "不支持的文件类型: $file"
          end
        end
      '';

      # 获取当前Git分支
      current_branch = ''
        function current_branch
          set -l ref (git symbolic-ref HEAD 2> /dev/null); or set -l ref (git rev-parse --short HEAD 2> /dev/null); or return
          echo $ref | sed -e 's|^refs/heads/||'
        end
      '';

      # 查找进程
      psgrep = ''
        function psgrep --argument-names pattern
          ps aux | grep $pattern | grep -v grep
        end
      '';
      # 查询IP信息（外部IP + 局域网IP）
      ipinfo = ''
        if not type -q curl
          echo "❌ 未找到 curl 命令"
          return 1
        end

        # 获取局域网IP
        set -l ip192 (ifconfig 2>/dev/null | grep "inet " | awk '{print $2}' | grep "^192\." | tr '\n' ',' | sed 's/,$//')
        set -l ip100 (ifconfig 2>/dev/null | grep "inet " | awk '{print $2}' | grep "^100\." | tr '\n' ',' | sed 's/,$//')

        # 获取外部IP并合并输出
        curl --silent http://ipinfo.io | fx "x => ({ip: x.ip, city: x.city, region: x.region, lan: \"$ip192\", tailscale: \"$ip100\"})"
      '';
      take = ''
        if test -z "$argv[1]"
            echo "Usage: take <directory>"
            return 1
        end
        mkdir -p $argv[1] && cd $argv[1]
      '';

      # Nix 垃圾回收
      nixgc = ''
        function nixgc
          echo "🧹 清理 Nix 存储..."
          nix-collect-garbage --delete-older-than 7d
          echo "📊 优化存储空间..."
          nix-store --optimise
          echo "✅ 清理完成！当前存储大小："
          du -sh /nix/store
        end
      '';

      # Nix 存储信息
      nixinfo = ''
        function nixinfo
          echo "📦 Nix 存储信息："
          echo "存储大小: "(du -sh /nix/store 2>/dev/null | cut -f1)
          echo "GC roots: "(nix-store -q --roots | wc -l)" 个"
          echo "用户代数: "(nix-env --list-generations | tail -1 | awk '{print $1}')
          echo "系统代数: "(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system 2>/dev/null | tail -1 | awk '{print $1}')
        end
      '';

      # 查看代理状态
      proxystatus = ''
        set -l proxy_envs (env | grep -E '^(https?_proxy|all_proxy|HTTPS?_PROXY|ALL_PROXY)=')
        if test (count $proxy_envs) -gt 0
          set_color green
          echo "✅ Proxy: ON"
          set_color normal
          printf "%s\n" $proxy_envs
        else
          set_color red
          echo "❌ Proxy: OFF"
          set_color normal
        end
      '';

      # 智能切换到主分支 (main 或 master)
      git_checkout_main = ''
        # 检查是否在git仓库中
        if not git rev-parse --git-dir >/dev/null 2>&1
          echo "❌ 不在 git 仓库中"
          return 1
        end

        # 首先尝试切换到 main 分支
        if git show-ref --verify --quiet refs/heads/main
          git checkout main
          echo "✅ 已切换到 main 分支"
        else if git show-ref --verify --quiet refs/remotes/origin/main
          # 如果本地没有但远程有 main 分支
          git checkout -b main origin/main
          echo "✅ 已创建并切换到 main 分支"
        else if git show-ref --verify --quiet refs/heads/master
          # 尝试切换到 master 分支
          git checkout master
          echo "✅ 已切换到 master 分支"
        else if git show-ref --verify --quiet refs/remotes/origin/master
          # 如果本地没有但远程有 master 分支
          git checkout -b master origin/master
          echo "✅ 已创建并切换到 master 分支"
        else
          echo "❌ 找不到 main 或 master 分支"
          return 1
        end
      '';

      # 快速保存/撤销 WIP 提交（与 zsh 保持一致）
      gwip = ''
        # 确保在 git 仓库内
        if not git rev-parse --git-dir >/dev/null 2>&1
          echo "❌ 不在 git 仓库中"
          return 1
        end

        git add -A

        set deleted_files (git ls-files --deleted)
        if test (count $deleted_files) -gt 0
          git rm $deleted_files 2>/dev/null
        end

        git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]" .
      '';

      gunwip = ''
        if not git rev-parse --git-dir >/dev/null 2>&1
          echo "❌ 不在 git 仓库中"
          return 1
        end

        set last_msg (git log -1 --pretty=%s 2>/dev/null)
        if string match -q -- "*--wip--*" "$last_msg"
          git reset HEAD~1
          echo "✅ 已撤销最近的 WIP 提交"
        else
          echo "ℹ️ 最近一次提交不是 WIP，未进行任何操作"
        end
      '';
    };

    # Fish插件
    plugins = [
      # 基本插件
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
          sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
        };
      }
      {
        name = "autopair";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "autopair.fish";
          rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
          sha256 = "sha256-qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
        };
      }
    ];

    # Fish shell环境变量 (等同于zsh的envExtra)
    shellInit = ''
      # 禁用欢迎语
      set -g fish_greeting ""
      # Puppeteer 配置
      set -gx PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

      # 禁用pip更新检查
      set -gx PIP_DISABLE_PIP_VERSION_CHECK 1

      set -gx NIX_FIRST_BUILD_UID 30001

      # fx 配置 https://fx.wtf/configuration
      set -gx FX_SHOW_SIZE true

      # sops age 密钥文件路径
      set -gx SOPS_AGE_KEY_FILE "$HOME/.config/sops/age/keys.txt"

      # OpenAI 环境变量（从 sops 解密）
      set -gx OPENAI_API_KEY (cat ${config.sops.secrets.openai_api_key.path})
      set -gx OPENAI_BASE_URL (cat ${config.sops.secrets.openai_base_url.path})
    '';

    # Fish 交互式初始化 (等同于zsh的initContent)
    interactiveShellInit = ''
      # Manually prepend Nix paths to ensure they are available.
      set -gx PATH /etc/profiles/per-user/smile/bin $PATH
      set -gx PATH /run/current-system/sw/bin $PATH
      set -gx PATH $HOME/.opencode/bin $PATH

      # 禁用conda更新检查
      set -gx CONDA_NUMBER_CHANNEL_NOTICES 0

      # 条件加载 Homebrew 补全
      if test -f /opt/homebrew/share/fish/vendor_completions.d/brew.fish
        source /opt/homebrew/share/fish/vendor_completions.d/brew.fish
      end

      # 设置fish的颜色主题
      set -g fish_color_autosuggestion 555
      set -g fish_color_command 5f87d7
      set -g fish_color_comment 808080
      set -g fish_color_cwd green
      set -g fish_color_cwd_root red
      set -g fish_color_end bcbcbc
      set -g fish_color_error red --bold
      set -g fish_color_escape cyan
      set -g fish_color_history_current cyan
      set -g fish_color_host normal
      set -g fish_color_match cyan
      set -g fish_color_normal normal
      set -g fish_color_operator cyan
      set -g fish_color_param 5f87af
      set -g fish_color_quote brown
      set -g fish_color_redirection normal
      set -g fish_color_search_match --background=purple
      set -g fish_color_user green
      set -g fish_color_valid_path --underline

      # 启用vi模式 (如果你喜欢的话)
      # fish_vi_key_bindings

      # 或者使用默认的emacs模式
      fish_default_key_bindings
    '';
  };

  # 设置环境变量
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    # XDG_CONFIG_HOME = "$HOME/.config";
  };

  # 将fish添加到系统shell列表并设为默认shell (需要在macOS上手动执行)
  # 这部分需要手动执行：
  # echo /path/to/fish | sudo tee -a /etc/shells
  # chsh -s /path/to/fish
}
