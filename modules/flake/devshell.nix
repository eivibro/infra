{
  perSystem = {pkgs, ...}: {
    # `nix develop` provides the tools needed to create and edit secrets, so
    # they do not have to be installed on every machine that edits this
    # repository.
    devShells.default = pkgs.mkShellNoCC {
      packages = [
        pkgs.age
        pkgs.sops
        pkgs.ssh-to-age
      ];
    };
  };
}
