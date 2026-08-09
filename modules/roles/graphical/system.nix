{inputs, ...}: {
  flake.modules.nixos.graphical = {pkgs, ...}: {
    imports = [
      inputs.self.modules.nixos.stylix
    ];

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    fonts.packages = [
      pkgs.font-awesome
      pkgs.nerd-fonts.droid-sans-mono
    ];

    home-manager.users.eivbro.imports = [
      inputs.self.modules.homeManager.graphical
    ];
  };
}
