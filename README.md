# Nix Config

个人 Nix 配置，支持 macOS (nix-darwin) 和 Linux (NixOS/Home Manager)。

## 快速开始

```bash
# 首次构建
nix build .#darwinConfigurations.smile.system --no-link --extra-experimental-features 'nix-command flakes'

# 应用配置
./result/sw/bin/darwin-rebuild switch --flake .#smile

# 后续更新
darwin-rebuild switch --flake .#smile
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
