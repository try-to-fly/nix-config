{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    history = {
      ignoreDups = true;
      share = true;
      save = 999999999;
      size = 999999999;
    };
    syntaxHighlighting.enable = true;
    enableAutosuggestions = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
      /* ugly hack: oh my zsh only wants a relative path, so lets go back to the system root */
      extraConfig = ''
        zstyle :omz:plugins:ssh-agent identities id_ed25519
      '';
    };
    shellAliases = {
      "ls" = "eza --time-style=long-iso --icons --hyperlink";
      "h" = "history";
      "j" = "z";
      "cat" = "bat --paging=never";
      "ocr" = "shortcuts run ocr -i";
      "tailscale" = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };

    initExtraFirst = "
# 优化粘贴速度
pasteinit() {
  OLD_SELF_INSERT=$\{$\{(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic 
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# 禁用conda更新检查
export CONDA_NUMBER_CHANNEL_NOTICES=0


export SCRCPY_SERVER_PATH=/Applications/极空间.app/Contents/Resources/app.asar.unpacked/bin/platform-tools/scrcpy-server
export PATH=$PATH:/Applications/极空间.app/Contents/Resources/app.asar.unpacked/bin/platform-tools
    ";
    envExtra = ''
      # Puppeteer 配置
      export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
      export PUPPETEER_EXECUTABLE_PATH=`which chromium`

      export PATH="$HOME/.local/bin:$PATH"


      # 禁用pip更新检查
      export PIP_DISABLE_PIP_VERSION_CHECK=1

      NIX_FIRST_BUILD_UID=30001

      # fx 配置 https://fx.wtf/configuration 
      export FX_SHOW_SIZE=true

    '';
  };


  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
  };
}
