{inputs, ...}: {
  flake.modules.nixos.work = {lib, ...}: {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) ["google-chrome"];

    home-manager.users.eivbro.imports = [
      inputs.self.modules.homeManager.work
    ];
  };

  flake.modules.homeManager.work = {
    imports = [
      inputs.self.modules.homeManager.googleChrome
      inputs.self.modules.homeManager.onedrive
    ];
  };
}
