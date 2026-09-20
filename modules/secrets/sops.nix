{inputs, ...}: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.sops = {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops.age = {
      # Hosts decrypt with an age key derived from their own SSH host key, so
      # each host is its own recipient and no key material is shared between
      # machines.
      #
      # The key is generated before the install and placed by `nix run
      # .#deploy`, not generated on first boot: a secret can only be encrypted
      # to a host whose key is already known. See modules/flake/deploy.nix.
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      # Deriving from the host key is the whole point, so a generated key would
      # only be a second thing to keep track of.
      generateKey = false;
    };

    # Left at its default, sops-install-secrets would also try to import the
    # RSA host key as a PGP key on every activation, fail, and log about it.
    # age is the only backend in use here.
    sops.gnupg.sshKeyPaths = [];
  };
}
