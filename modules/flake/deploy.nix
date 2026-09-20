{
  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    # Installs a host with nixos-anywhere, placing that host's SSH host key on
    # the target before the first boot.
    #
    # The key has to exist beforehand rather than being generated during the
    # install, because it is also the host's age identity: secrets can only be
    # encrypted to a host whose key is already known. Pre-placing it means the
    # very first activation can already decrypt, which matters for secrets
    # marked neededForUsers — a host that cannot read those comes up with no
    # password set on any account.
    apps.deploy.program = lib.getExe (pkgs.writeShellApplication {
      name = "deploy";

      runtimeInputs = [
        pkgs.openssh
        pkgs.ssh-to-age
      ];

      text = ''
        host=''${1:-}
        target=''${2:-}

        if [ -z "$host" ] || [ -z "$target" ]; then
          echo "usage: nix run .#deploy -- <host> <user@address>" >&2
          echo "   eg: nix run .#deploy -- m920q-router root@192.168.10.1" >&2
          exit 2
        fi

        keydir="''${NIXOS_HOST_KEYS:-$HOME/.local/share/nixos-host-keys}/$host"
        key="$keydir/ssh_host_ed25519_key"

        if [ ! -f "$key" ]; then
          echo "No host key for '$host' at $key" >&2
          echo >&2
          echo "Create one, then add the age key it prints to .sops.yaml and" >&2
          echo "re-encrypt whatever secrets this host has to read:" >&2
          echo >&2
          echo "  mkdir -p $keydir" >&2
          echo "  ssh-keygen -t ed25519 -N \"\" -C $host -f $key" >&2
          echo "  ssh-to-age -i $key.pub" >&2
          exit 1
        fi

        extra=$(mktemp -d)
        trap 'rm -rf "$extra"' EXIT

        install -d -m 0755 "$extra/etc/ssh"
        install -m 0600 "$key" "$extra/etc/ssh/ssh_host_ed25519_key"
        install -m 0644 "$key.pub" "$extra/etc/ssh/ssh_host_ed25519_key.pub"

        echo "deploying $host to $target"
        echo "host age identity: $(ssh-to-age -i "$key.pub")"

        exec nix run github:nix-community/nixos-anywhere -- \
          --flake ".#$host" \
          --extra-files "$extra" \
          "$target"
      '';
    });
  };
}
