{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  sops = {
    # smile 的 macOS 首次安装直接使用现有 SSH 私钥解密 secrets；
    # 其他平台继续使用手动准备的 age key 文件。
    age =
      if username == "smile" && pkgs.stdenv.isDarwin then
        {
          sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
        }
      else
        {
          keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        };

    # 默认 secrets 文件
    defaultSopsFile = ../../secrets/secrets.yaml;

    # 首次设置时关闭验证，配置完成后可以开启
    validateSopsFiles = false;

    # 定义需要解密的 secrets
    secrets = {
      # git 配置片段，用于 include.path
      "git" = { };
      # OpenAI 相关配置
      "openai_api_key" = { };
      "openai_base_url" = { };
    };
  };
}
