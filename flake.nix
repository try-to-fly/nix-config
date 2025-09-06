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
  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs =
    inputs @ { self
      , nixpkgs
      , darwin
      , home-manager
      , ...
      }:
    let
      # TODO replace with your own username, system and hostname
      username = "smile";
      system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin
      hostname = "smile";
      useremail = "wang1234561211@outlook.com";

      specialArgs =
        inputs
        // {
          inherit username useremail hostname;
        };
    in
    {
      darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
        inherit system specialArgs;
        modules = [
          {

            ids.gids.nixbld = 350;
          }
          ./modules/nix-core.nix
          ./modules/system.nix
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
      # nix code formatter
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    };
}
