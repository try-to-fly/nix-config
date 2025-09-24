# 跨平台 Nix 配置使用指南

## 概述

本配置现在支持 macOS 和 Linux x64 服务器两个平台，实现了一套代码两个环境复用。

## 支持的平台

- **macOS** (aarch64-darwin, x86_64-darwin)
- **Linux 服务器** (x86_64-linux)

## 目录结构

```
├── flake.nix                  # 主配置文件，定义两个平台
├── hosts/
│   └── linux-server.nix      # Linux 服务器系统配置
├── home/
│   ├── default.nix           # 跨平台 Home Manager 配置
│   └── shared/               # 共享的工具配置
│       ├── fd.nix            # 文件搜索工具
│       ├── tmux.nix          # 终端多路复用
│       ├── starship.nix      # Shell 提示符
│       ├── fish.nix          # Fish Shell
│       └── ...               # 其他工具配置
└── modules/                  # macOS 特定模块
    ├── nix-core.nix          # 通用 Nix 配置
    ├── system.nix            # macOS 系统配置
    └── ...
```

## 平台特定功能

### macOS 特有
- **GUI 终端应用**: Kitty, WezTerm
- **系统默认设置**: Dock, Finder, 截图等 macOS 特定配置
- **Homebrew 集成**: 通过 nix-darwin
- **字体**: 包含多种 Nerd Fonts

### Linux 服务器特有
- **系统监控工具**: htop, btop, iotop, nethogs
- **网络工具**: curl, wget, nmap, tcpdump, iperf3
- **容器支持**: Docker, docker-compose
- **文件操作**: tree, rsync, unzip, p7zip
- **开发工具**: jq, yq
- **无 GUI**: 跳过桌面应用，专注服务器环境

### 共享配置
所有在 `home/shared/` 目录下的配置在两个平台自动复用：
- fd (文件搜索)
- ripgrep (内容搜索)
- tmux (终端多路复用)
- starship (命令行提示符)
- fish (Shell)
- git (版本控制)
- bat (文件查看器)
- yazi (文件管理器)
- zellij (终端多路复用器)
- 以及其他开发工具

## 使用方式

### macOS (现有方式保持不变)
```bash
# 切换到新配置
darwin-rebuild switch --flake .

# 或者指定特定配置
darwin-rebuild switch --flake .#smile
```

### Linux 服务器
```bash
# 本地构建并部署到服务器
sudo nixos-rebuild switch --flake .#smile-server

# 远程部署到服务器
sudo nixos-rebuild switch --flake .#smile-server --target-host user@server

# 仅构建不激活（测试）
sudo nixos-rebuild build --flake .#smile-server
```

## 部署 Linux 服务器

### 1. 准备工作
- 确保目标服务器已安装 NixOS
- 配置 SSH 密钥认证
- 确保当前用户有 sudo 权限

### 2. 硬件配置
部署前需要根据实际硬件修改 `hosts/linux-server.nix` 中的文件系统配置：

```nix
fileSystems."/" = {
  device = "/dev/disk/by-label/nixos";  # 修改为实际根分区
  fsType = "ext4";
};

fileSystems."/boot" = {
  device = "/dev/disk/by-label/boot";   # 修改为实际 boot 分区
  fsType = "vfat";
};
```

### 3. 用户配置
在 `flake.nix` 中修改用户信息：
```nix
username = "your-username";
useremail = "your-email@example.com";
hostname = "your-hostname";
```

## 配置验证

```bash
# 检查配置语法
nix flake check

# 检查所有支持的系统
nix flake check --all-systems

# 查看可用的配置
nix flake show
```

## 自定义配置

### 添加新的共享工具
1. 在 `home/shared/` 目录创建新的 `.nix` 文件
2. 在 `home/default.nix` 的 `imports` 中添加引用

### 添加平台特定配置
- **macOS**: 修改 `home/default.nix` 中的 `lib.optionals pkgs.stdenv.isDarwin` 部分
- **Linux**: 修改 `home/default.nix` 中的 `lib.optionals pkgs.stdenv.isLinux` 部分

### 修改系统配置
- **macOS**: 编辑 `modules/` 目录下的文件
- **Linux**: 编辑 `hosts/linux-server.nix`

## 故障排除

### 常见问题
1. **文件系统错误**: 确保 Linux 配置中的文件系统路径正确
2. **权限问题**: 确保 SSH 密钥和 sudo 权限配置正确
3. **包不可用**: 某些包可能在不同平台有不同的可用性

### 调试命令
```bash
# 查看详细错误信息
nix flake check --show-trace

# 查看配置输出
nix eval .#darwinConfigurations.smile.config.system.build.toplevel
nix eval .#nixosConfigurations.smile-server.config.system.build.toplevel
```

## 优势

1. **统一环境**: 在 macOS 开发机和 Linux 服务器保持一致的工具链
2. **代码复用**: 共享的配置文件自动在两个平台使用
3. **平台优化**: 每个平台使用最适合的工具和配置
4. **声明式**: 整个环境可复现、可版本控制
5. **渐进迁移**: 现有 macOS 配置完全兼容，无影响