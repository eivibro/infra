{inputs, ...}: {
  flake.modules.nixos.hyprland = {
    imports = [
      inputs.self.modules.nixos.graphical
    ];

    programs.hyprland.enable = true;

    security.pam.services.hyprlock = {};

    home-manager.users.eivbro.imports = [
      inputs.self.modules.homeManager.hyprland
    ];
  };
}
