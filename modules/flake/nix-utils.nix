{inputs, ...}: {
  flake-file.inputs.nix-utils = {
    url = "github:femtodata/nix-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # switch-fix makes `nixos-rebuild switch` restart units that a plain switch
  # would leave running on the old closure. Carried over from the previous
  # configuration; drop it if remote rebuilds turn out not to need it.
  flake.modules.nixos.switchFix = {
    imports = [
      inputs.nix-utils.nixosModules.switch-fix
    ];
  };
}
