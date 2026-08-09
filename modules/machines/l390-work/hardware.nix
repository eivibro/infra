{
  flake.modules.nixos.l390Hardware = {
    config,
    lib,
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
          "nvme"
          "usb_storage"
          "sd_mod"
          "rtsx_pci_sdmmc"
        ];
        kernelModules = ["i915"];
      };

      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    hardware = {
      bluetooth.enable = true;
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}
