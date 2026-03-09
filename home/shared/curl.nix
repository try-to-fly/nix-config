{ pkgs, lib, ... }:
{
  # 通过 home.file 创建 .curlrc 配置文件
  home.file.".curlrc".text = ''
    # 自动跟随 HTTP 重定向
    location

    # 显示错误信息（即使在静默模式下）
    show-error

    # 设置合理的超时时间（60秒）
    max-time = 60

    # 设置连接超时（10秒）
    connect-timeout = 10

    # 失败时返回非零退出码，同时保留响应体
    fail-with-body

    # 在下载时显示进度条
    progress-bar

    # 设置用户代理
    user-agent = "curl/8.x"

    # 压缩传输
    compressed
  '';
}
