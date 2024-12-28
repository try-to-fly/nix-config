```bash
nix build .#darwinConfigurations.smile.system --extra-experimental-features 'nix-command flakes'
```

```bash
./result/sw/bin/darwin-rebuild switch --flake .#smile
```

### 技巧

1. 搜索app、cli的配置

```
https://github.com/search?q=language:Nix+programs.ripgrep&type=code
```
