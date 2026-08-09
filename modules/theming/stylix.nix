{inputs, ...}: {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.stylix = {pkgs, ...}: {
    imports = [
      inputs.self.modules.nixos.homeManager
      inputs.stylix.nixosModules.stylix
    ];

    stylix = {
      enable = true;
      autoEnable = false;
      image = ./wallpaper.jpg;
      imageScalingMode = "fill";
      polarity = "dark";

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 16;
      };

      opacity = {
        desktop = 0.9;
        terminal = 0.9;
      };
    };
  };
}
