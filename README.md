# NixOS infrastructure

A dendritic NixOS configuration built with flake-parts and import-tree.

## Validate

```console
nix fmt
nix flake show
nix flake check -L
nix build .#nixosConfigurations.l390-work.config.system.build.toplevel
```
