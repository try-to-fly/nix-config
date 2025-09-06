{ config, lib, pkgs, ... }:

{
  # Use Home Manager to manage direnv and nix-direnv, with Fish integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
