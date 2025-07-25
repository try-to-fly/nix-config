# Fish Shell 设置指南

## 概述
本配置已将原来的 zsh 配置转换为 fish shell 配置。fish 是一个现代、智能且用户友好的 shell。

## 配置变更
- 将 `home/zsh.nix` 替换为 `home/fish.nix`
- 修改 `home/default.nix` 中的导入
- 更新 `starship.nix` 以启用 fish 集成
- 更新 `zoxide.nix` 以启用 fish 集成

## 设置 fish 为默认 shell

### 1. 应用 home-manager 配置
```bash
home-manager switch
```

### 2. 找到 fish 的路径
```bash
which fish
# 通常是 /Users/你的用户名/.nix-profile/bin/fish
```

### 3. 将 fish 添加到系统允许的 shell 列表
```bash
echo $(which fish) | sudo tee -a /etc/shells
```

### 4. 将 fish 设置为默认 shell
```bash
chsh -s $(which fish)
```

### 5. 重启终端
关闭并重新打开终端应用程序，新的会话将使用 fish shell。

## Fish 配置亮点

### Shell 别名
保持了与原 zsh 配置相同的别名：
- `ls` → `eza --time-style=long-iso --icons --hyperlink`
- `cat` → `bat --paging=never`
- `j` → `z` (zoxide 跳转)

### Fish 缩写 (Abbreviations)
Fish 的智能缩写功能，会在输入时展开：
- `g` → `git`
- `ga` → `git add`
- `gc` → `git commit`
- `..` → `cd ..`
- `...` → `cd ../..`

### 自定义函数
- `mkcd` - 创建目录并进入
- `extract` - 解压各种格式的压缩文件
- `psgrep` - 搜索进程

### 插件
- `z` - 智能目录跳转
- `autopair` - 自动配对括号和引号

## Fish 的优势
- 智能自动补全
- 语法高亮
- 基于历史的建议
- 更友好的脚本语法
- 开箱即用的现代功能

## 验证设置
```bash
echo $SHELL
# 应该显示 fish 的路径

fish --version
# 显示 fish 版本信息
```

## 疑难解答

### 如果需要临时使用 bash/zsh
```bash
bash  # 或 zsh
```

### 如果需要回到 zsh
```bash
chsh -s /bin/zsh
```

## 注意事项
- Fish 的语法与 bash/zsh 略有不同
- 大多数常见任务在 fish 中更简单
- 环境变量使用 `set -gx VAR value` 而不是 `export VAR=value`
- 条件语句使用 `if test` 而不是 `if [...]`

配置完成后，你将拥有一个现代化、智能且高效的 shell 环境！ 