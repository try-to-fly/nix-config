#!/bin/bash

# Fish Shell 自动设置脚本
# 用于将 fish 设置为默认 shell

set -e  # 遇到错误立即退出

echo "🐟 Fish Shell 设置脚本"
echo "===================="

# 1. 应用 home-manager 配置
# echo "1. 应用 home-manager 配置..."
# if command -v home-manager &> /dev/null; then
#     home-manager switch
#     echo "✅ home-manager 配置已应用"
# else
#     echo "❌ 未找到 home-manager 命令，请先安装 home-manager"
#     exit 1
# fi

# 2. 检查 fish 是否安装
echo
echo "2. 检查 fish 安装..."
if command -v fish &> /dev/null; then
    FISH_PATH=$(which fish)
    echo "✅ Fish 已安装在: $FISH_PATH"
else
    echo "❌ Fish 未安装，请检查 nix 配置"
    exit 1
fi

# 3. 检查 fish 是否已在 /etc/shells 中
echo
echo "3. 检查 fish 是否在允许的 shell 列表中..."
if grep -q "$FISH_PATH" /etc/shells; then
    echo "✅ Fish 已在 /etc/shells 中"
else
    echo "🔧 添加 fish 到 /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
    echo "✅ Fish 已添加到 /etc/shells"
fi

# 4. 检查当前默认 shell
echo
echo "4. 检查当前默认 shell..."
CURRENT_SHELL=$(dscl . -read /Users/$USER UserShell | cut -d' ' -f2)
echo "当前默认 shell: $CURRENT_SHELL"

if [ "$CURRENT_SHELL" = "$FISH_PATH" ]; then
    echo "✅ Fish 已经是默认 shell"
else
    echo "🔧 设置 fish 为默认 shell..."
    chsh -s "$FISH_PATH"
    echo "✅ Fish 已设置为默认 shell"
fi

# 5. 验证设置
echo
echo "5. 验证设置..."
echo "Fish 路径: $FISH_PATH"
echo "Fish 版本: $(fish --version)"

echo
echo "🎉 设置完成！"
echo
echo "⚠️  重要提醒:"
echo "   请重启终端应用程序以使更改生效"
echo
echo "🔍 验证命令:"
echo "   echo \$SHELL  # 应该显示 fish 路径"
echo "   fish --version  # 显示 fish 版本"
echo
echo "📚 更多信息请查看 FISH_SETUP.md" 