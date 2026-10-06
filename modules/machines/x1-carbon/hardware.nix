{
  # Carried over from the nixos-generate-config output the previous
  # configuration held. The initrd module list is the one that file wrote,
  # including ehci_pci and rtsx_pci_sdmmc and no nvme entry of its own.
  # nixos-hardware's X1 module supplies nvme. Microcode stays commented out
  # here; the nixos-hardware import is what enables it, as before.
  flake.modules.nixos.x1CarbonHardware = {
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "usb_storage"
          "sd_mod"
          "rtsx_pci_sdmmc"
        ];
        kernelModules = [];
      };

      kernelModules = [];
      extraModulePackages = [];
    };

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    #hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
      ];
    };
  };
}
