{inputs, ...}: {
  configurations.nixos.l390-work.module = {...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad
      inputs.self.modules.nixos.l390Hardware
      inputs.self.modules.nixos.laptopDisko
      inputs.self.modules.nixos.common
      inputs.self.modules.nixos.hyprland
      inputs.self.modules.nixos.intelVideo
      inputs.self.modules.nixos.work
    ];

    home-manager.users.eivbro.media.av1.enable = false;
    home-manager.users.eivbro.imports = [
      inputs.self.modules.homeManager.vscodium
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "l390-work";
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Oslo";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "dvorak-no";
    };

    services.openssh.enable = true;

    system.stateVersion = "26.05";
  };
}
