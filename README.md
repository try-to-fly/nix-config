# Nix Config

个人 Nix 配置，支持 macOS (nix-darwin) 和 Linux (NixOS/Home Manager)。

## 前置依赖

### 1. 安装 Nix

```bash
# 使用清华镜像安装（国内推荐）
sh <(curl -L https://mirrors.tuna.tsinghua.edu.cn/nix/latest/install)

# 或官方源
# sh <(curl -L https://nixos.org/nix/install)

# 安装完成后重启终端
```

### 2. 安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装完成后按提示将 brew 添加到 PATH
```

## 快速开始

### smile 用户（主配置）

```bash
# 克隆仓库
git clone <repo-url> ~/nix-config
cd ~/nix-config

# 首次构建
nix build .#darwinConfigurations.smile.system --extra-experimental-features 'nix-command flakes'

# 应用配置
./result/sw/bin/darwin-rebuild switch --flake .#smile

# 后续更新
darwin-rebuild switch --flake .#smile
```

### fox 用户（无 sops secrets）

```bash
# 克隆仓库
git clone <repo-url> ~/nix-config
cd ~/nix-config

# 首次安装（需要 sudo）
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .#fox

# 后续更新
darwin-rebuild switch --flake .#fox
```

### 配置 Fish 为默认 Shell

nix-darwin 安装完成后，需要手动将 fish 设为默认 shell：

```bash
# 1. 将 fish 添加到允许的 shell 列表
echo "/run/current-system/sw/bin/fish" | sudo tee -a /etc/shells

# 2. 设置 fish 为默认 shell
chsh -s /run/current-system/sw/bin/fish

# 3. 完全退出终端应用（⌘Q），重新打开
```

如果终端仍未生效，可以在终端设置中手动指定 shell 路径为 `/run/current-system/sw/bin/fish`，或使用 nix 配置的 **kitty** / **wezterm** 终端：

```bash
open -a kitty
# 或
open -a wezterm
```

## 密钥管理 (sops-nix)

本项目使用 [sops-nix](https://github.com/Mic92/sops-nix) 安全管理敏感信息（邮箱、API Keys 等）。密钥使用 age 加密后可安全提交到 Git。

### 新机器设置

```bash
# 1. 克隆仓库
git clone <repo> && cd nix-config

# 2. 确保 SSH key 已存在（~/.ssh/id_ed25519）

# 3. 生成 age 私钥（用于解密 secrets）
nix-shell -p ssh-to-age
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# 4. 应用配置
darwin-rebuild switch --flake .#smile
```

### 编辑 Secrets

```bash
# 编辑加密的 secrets（会自动解密供编辑，保存时自动加密）
sops secrets/secrets.yaml

# 查看解密内容（只读）
sops -d secrets/secrets.yaml
```

### 添加新用户/新机器

```bash
# 1. 新用户生成 SSH key 并获取 age 公钥
ssh-to-age -i ~/.ssh/id_ed25519.pub
# 输出类似: age1xxxxxxxxxx...

# 2. 将公钥添加到 .sops.yaml
# 编辑 .sops.yaml，在 keys 部分添加新用户的公钥

# 3. 重新加密 secrets（需要有权限的用户执行）
sops updatekeys secrets/secrets.yaml

# 4. 提交并推送
git add .sops.yaml secrets/secrets.yaml
git commit -m "Add new user key"
git push
```

### Secrets 文件结构

```yaml
# secrets/secrets.yaml
user:
  email: "your-email@example.com"
api_keys:
  openai: "sk-xxx"
  github: "ghp_xxx"
tokens:
  example: "token_value"
```

### 在配置中使用 Secrets

```nix
# home/shared/sops.nix 中定义需要解密的 secrets
sops.secrets = {
  "user/email" = { };
  "api_keys/openai" = { };
};

# 其他模块中使用
config.sops.secrets."user/email".path  # 解密后的文件路径
```

### 新增环境变量

以添加 `OPENAI_API_KEY` 和 `OPENAI_BASE_URL` 为例：

**1. 编辑 secrets 文件**

```bash
sops secrets/secrets.yaml
```

添加内容：
```yaml
openai_api_key: "sk-xxx"
openai_base_url: "https://api.example.com/v1"
```

**2. 在 sops.nix 中声明**

```nix
# home/shared/sops.nix
secrets = {
  "openai_api_key" = { };
  "openai_base_url" = { };
};
```

**3. 在 fish.nix 中暴露环境变量**

```nix
# home/shared/fish.nix
# 确保函数参数包含 config
{ config, pkgs, lib, ... }:

# 在 shellInit 中添加
shellInit = ''
  set -gx OPENAI_API_KEY (cat ${config.sops.secrets.openai_api_key.path})
  set -gx OPENAI_BASE_URL (cat ${config.sops.secrets.openai_base_url.path})
'';
```

**4. 重建配置**

```bash
darwin-rebuild switch --flake .#smile
```

## 技巧

1. 搜索 app、cli 的配置

```
https://github.com/search?q=language:Nix+programs.ripgrep&type=code
```
