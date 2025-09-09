{ pkgs, lib, ... }:

{
  # enable flakes globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use this instead of services.nix-daemon.enable if you
  # don't wan't the daemon service to be managed for you.
  # nix.useDaemon = true;

  nix.package = pkgs.nix;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Disable auto-optimise-store because of this issue:
  #   https://github.com/NixOS/nix/issues/7273
  # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
  nix.settings = {
    auto-optimise-store = false;
    # Add community binary caches to speed up builds. You can keep the official cache.
    # Note: For Cachix caches, you must also add the matching public keys below.
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    # Pair public keys for the added substituters. The official cache key is included by default,
    # but listing it here is harmless. Add nix-community’s key to enable that cache.
    # To avoid errors from an incorrect key, the nix-community key is commented; uncomment after verifying.
    trusted-public-keys = [
      # Official cache
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # nix-community (uncomment after verifying the key string)
      # "nix-community.cachix.org-1:REPLACE_WITH_OFFICIAL_PUBLIC_KEY"
    ];
  };
}
