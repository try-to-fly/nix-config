# Ubuntu 使用指南

本配置现已支持在 Ubuntu 等非 NixOS Linux 发行版上使用 Nix + Home Manager。

## 前置要求

### 1. 安装 Nix 包管理器

如果还没有安装 Nix,推荐使用 Determinate Systems 安装器:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

安装完成后,重新登录或运行:
```bash
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### 2. 启用 Flakes 和 nix-command 特性

如果使用的是官方 Nix 安装器(而非 Determinate Systems),需要手动启用实验性特性:

```bash
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf <<EOF
experimental-features = nix-command flakes
EOF
```

## 使用方法

### 首次部署

1. **克隆配置仓库**:
   ```bash
   git clone <你的仓库地址> ~/nix-config
   cd ~/nix-config
   ```

2. **应用配置**:

   **如果是 smile 用户**:
   ```bash
   nix run nixpkgs#home-manager -- switch --flake .#smile@linux
   ```

   **如果是 root 用户**:
   ```bash
   nix run nixpkgs#home-manager -- switch --flake .#root@linux
   ```

   ⚠️ **注意**: 推荐创建普通用户而不是使用 root 运行。以 root 运行开发环境存在安全风险。

   首次运行会下载和构建大量包,请耐心等待。

### 日常使用

#### 更新配置

修改配置文件后,应用更改:
```bash
cd ~/nix-config
# smile 用户
home-manager switch --flake .#smile@linux
# 或者 root 用户
home-manager switch --flake .#root@linux
```

#### 更新软件包

更新 nixpkgs 和其他依赖:
```bash
cd ~/nix-config
nix flake update
# smile 用户
home-manager switch --flake .#smile@linux
# 或者 root 用户
home-manager switch --flake .#root@linux
```

#### 清理旧版本

清理未使用的旧版本以节省空间:
```bash
nix-collect-garbage -d
```

## 配置说明

### 自动启用的功能

在 Ubuntu 上,配置自动启用了以下特性:

1. **`targets.genericLinux.enable = true`**
   - 自动设置必要的环境变量和 XDG 路径
   - 让 Nix 安装的软件能正确集成到 Ubuntu 系统中
   - 添加 Ubuntu 特定的系统路径支持

2. **`fonts.fontconfig.enable = true`**
   - 启用字体配置管理
   - 让 Nix 安装的 Nerd Fonts 可被系统识别
   - 应用程序可以正确使用这些字体

### 已包含的软件包(Linux)

配置已经包含了 Linux 服务器常用的工具:
- 系统监控: `htop`, `btop`, `iotop`, `nethogs`
- 网络工具: `curl`, `wget`, `nmap`, `tcpdump`, `iperf3`
- 文件管理: `tree`, `rsync`, `unzip`, `p7zip`
- 数据处理: `jq`, `yq`
- 容器工具: `docker-compose`

### 环境变量配置

Home Manager 会自动设置以下环境变量(通过 Fish shell):
- `$PATH` 包含 `~/.nix-profile/bin`
- Fish 补全和配置会自动加载
- 各种工具(如 starship, zoxide, direnv)会自动初始化

## 故障排除

### 问题: 命令找不到

如果应用配置后命令仍然找不到,检查:

1. **重新加载 shell 配置**:
   ```bash
   exec fish  # 或者你使用的 shell
   ```

2. **检查 PATH**:
   ```bash
   echo $PATH
   ```
   应该包含 `~/.nix-profile/bin` 和 `/nix/var/nix/profiles/default/bin`

### 问题: 字体不显示

1. **刷新字体缓存**:
   ```bash
   fc-cache -f -v
   ```

2. **验证字体安装**:
   ```bash
   fc-list | grep -i "JetBrains\|Nerd"
   ```

### 问题: 权限错误

如果遇到 Nix store 权限问题,确保 Nix daemon 正在运行:
```bash
sudo systemctl status nix-daemon
```

## 与其他配置的区别

- **macOS (`.#smile`)**: 使用 nix-darwin + home-manager,包含系统级配置
- **Ubuntu smile 用户 (`.#smile@linux`)**: standalone home-manager,管理 smile 用户环境
- **Ubuntu root 用户 (`.#root@linux`)**: standalone home-manager,管理 root 用户环境
- **NixOS (`.#smile-server`)**: 完整的系统配置,使用 `nixos-rebuild`

### 用户选择建议

- ✅ **推荐**: 创建普通用户(如 smile)使用 `.#smile@linux`
- ⚠️ **不推荐**: 使用 root 用户 `.#root@linux` (仅用于测试或特殊需求)

## 自定义配置

### 添加软件包

编辑 `home/default.nix`,在 `home.packages` 的 Linux 部分添加:

```nix
++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
  # 添加你的软件包
  neofetch
  tmux
  # ...
])
```

### 配置具体程序

可以在 `home/shared/` 目录下添加新的配置文件,然后在 `home/default.nix` 中导入:

```nix
imports = [
  ./shared/my-program.nix
  # ...
];
```

## 参考资源

- [Home Manager 官方文档](https://nix-community.github.io/home-manager/)
- [Home Manager 配置选项](https://nix-community.github.io/home-manager/options.html)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
