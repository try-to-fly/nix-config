{ pkgs, lib, ... }: {
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
    };

    # Fish abbreviations (智能缩写，fish特有功能)
    shellAbbrs = {
      # 导航缩写
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      
      # Git 缩写
      "g" = "git";
      "ga" = "git add";
      "gaa" = "git add --all";
      "gc" = "git commit";
      "gcm" = "git commit -m";
      "gco" = "git checkout";
      "gd" = "git diff";
      "gl" = "git log";
      "gp" = "git push";
      "gs" = "git status";
      "gst" = "git stash";
      "gpsup" = "git push --set-upstream origin (current_branch)";
      
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
        function mkcd --argument-names dir
          mkdir -p $dir
          and cd $dir
        end
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
      # Puppeteer 配置
      set -gx PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

      # 禁用pip更新检查
      set -gx PIP_DISABLE_PIP_VERSION_CHECK 1

      set -gx NIX_FIRST_BUILD_UID 30001

      # fx 配置 https://fx.wtf/configuration 
      set -gx FX_SHOW_SIZE true
    '';

    # Fish 交互式初始化 (等同于zsh的initContent)
    interactiveShellInit = ''
      # Manually prepend Nix paths to ensure they are available.
      set -gx PATH /etc/profiles/per-user/smile/bin $PATH
      set -gx PATH /run/current-system/sw/bin $PATH
      
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