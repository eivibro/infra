{
  flake.modules.nixos.intelVideo = {pkgs, ...}: {
    hardware.graphics = {
      enable = true;
      extraPackages = [pkgs.intel-media-driver];
    };

    environment.systemPackages = [pkgs.libva-utils];
  };
}
