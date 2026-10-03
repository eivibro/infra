{
  # Carried over from the nixos-generate-config output the previous
  # configuration held. AMD desktop with an NVIDIA card; the GPU is in
  # nvidia.nix.
  flake.modules.nixos.masterchiefHardware = {
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
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        kernelModules = [];
      };

      kernelModules = ["kvm-amd"];
      extraModulePackages = [];
    };

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
