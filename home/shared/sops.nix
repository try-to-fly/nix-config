{
  config,
  pkgs,
  lib,
  ...
}:

{
  sops = {
    # age 密钥文件位置
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

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
