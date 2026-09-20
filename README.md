# NixOS infrastructure

A dendritic NixOS configuration built with flake-parts and import-tree.

## Validate

```console
nix fmt
nix flake show
nix flake check -L
nix build .#nixosConfigurations.l390-work.config.system.build.toplevel
```

## Secrets

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) and
committed in that form. `nix develop` provides `sops`, `age`, and `ssh-to-age`.

Recipients live in `.sops.yaml`, which currently holds two placeholders. Both
have to be replaced before `sops` will run.

Create the personal identity once, and back the file up somewhere outside this
repository — losing it makes every secret encrypted to it unrecoverable:

```console
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

Hosts decrypt with an age key derived from their own SSH host key. Generate
that key before installing the host, so secrets can be encrypted to it in
advance:

```console
keydir=~/.local/share/nixos-host-keys/m920q-router
mkdir -p $keydir
ssh-keygen -t ed25519 -N "" -C m920q-router -f $keydir/ssh_host_ed25519_key
ssh-to-age -i $keydir/ssh_host_ed25519_key.pub
```

Put both public keys into `.sops.yaml`, then create a secret file next to the
module that consumes it:

```console
sops modules/machines/m920q-router/secrets.yaml
```

Reference it from that module with `sops.secrets.<name>`, which decrypts to
`/run/secrets/<name>` at activation time.

## Install

```console
nix run .#deploy -- m920q-router root@ADDRESS
```

This wraps `nixos-anywhere`, passing the host key generated above through
`--extra-files` so it is in place before the first boot. A host that cannot
decrypt on its first activation comes up with no password on any account, so
the key has to precede the install rather than follow it.
