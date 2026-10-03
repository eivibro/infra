{inputs, ...}: {
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.homeManager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";

      users.eivbro.imports = [
        inputs.self.modules.homeManager.eivbro
      ];
    };
  };

  flake.modules.homeManager.eivbro = {lib, ...}: {
    home = {
      username = "eivbro";
      homeDirectory = "/home/eivbro";

      # A default rather than a plain value, because a host whose home
      # directory predates this repository has to keep the release it was
      # first activated with.
      stateVersion = lib.mkDefault "26.05";
    };

    programs.home-manager.enable = true;
  };
}
