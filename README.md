```bash
nix build .#darwinConfigurations.smile.system --extra-experimental-features 'nix-command flakes'   
```

```bash
./result/sw/bin/darwin-rebuild switch --flake .#smile
```