{
  description = "Nix for macOS configuration";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    substituters = [
      # Use the official Nix binary cache for stability.
      "https://cache.nixos.org"
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # Pin nixpkgs to the 25.05 Darwin branch (stable).
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    # home-manager, used for managing user configuration
    home-manager = {
      # Match Home Manager with the 25.05 series for compatibility.
      url = "github:nix-community/home-manager/release-25.05";
      # Keep HM's nixpkgs input in lockstep with this flake's nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      # Pin nix-darwin to the 25.05 release branch to match nixpkgs
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Prebuilt nix-index database for fast command-not-found suggestions
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix 原生 pre-commit hooks，用于提交前自动格式化等检查
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs =
    inputs@{
      self,
      nixpkgs,
      darwin,
      home-manager,
      pre-commit-hooks,
      ...
    }:
    let
      # TODO replace with your own username, system and hostname
      username = "smile";
      system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin
      hostname = "smile";
      useremail = "wang1234561211@outlook.com";

      specialArgs = inputs // {
        inherit username useremail hostname;
      };
      # 统一声明支持的 Darwin 架构，便于 formatter / checks / devShell 一致
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) systems
        );
      # 仅在需要时评估重型输出；配合 NIX_FMT_ONLY=1 可让 nix fmt 只评估 formatter
      fmtOnly = builtins.getEnv "NIX_FMT_ONLY" == "1";
    in
    ({
      # 统一 Nix 代码 formatter：使用 nixfmt-tree 包装，支持目录参数与递归
      # 说明：nix 正在弃用向 formatter 传递目录/非 Nix 文件；nixfmt-tree 可安全处理目录
      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.nixfmt-tree
      );
    })
    // (
      if fmtOnly then
        { }
      else
        {
          darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
            inherit system specialArgs;
            modules = [
              {

                ids.gids.nixbld = 350;
              }
              ./modules/nix-core.nix
              ./modules/system.nix
              ./modules/macos-defaults.nix
              ./modules/apps.nix
              ./modules/homebrew-mirror.nix
              ./modules/host-users.nix

              # home manager
              home-manager.darwinModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = specialArgs;
                  users.${username} = import ./home;
                };
              }
            ];
          };
          # 提交前自动格式化（Nix 版 pre-commit hooks）
          checks = forAllSystems (
            system:
            let
              pkgs = import nixpkgs { inherit system; };
            in
            {
              # 运行方式：`nix build .#checks.${system}.pre-commit` 或 CI 中引用
              pre-commit = pre-commit-hooks.lib.${system}.run {
                src = ./.;
                hooks = {
                  # 启用 nixfmt-rfc-style 进行 Nix 文件格式化
                  nixfmt-rfc-style.enable = true;
                };
              };
            }
          );

          # 开发环境（可选）：提供 pre-commit 与 nixfmt-rfc-style，便于本地安装/运行 hooks
          devShells = forAllSystems (
            system:
            let
              pkgs = import nixpkgs { inherit system; };
            in
            {
              default = pkgs.mkShell {
                packages = with pkgs; [
                  nixfmt-rfc-style
                  pre-commit
                ];
                # 提示信息更友好
                shellHook = ''
                  export PRE_COMMIT_COLOR=always
                '';
              };
            }
          );
        }
    );
}
