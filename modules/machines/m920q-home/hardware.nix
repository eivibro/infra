{
  # Derived from the Facter report the previous configuration carried, so that
  # this repository can stay Facter-free. ThinkCentre M920q (10RS0033MX),
  # i5-8500T, four igc ports on a riser card plus one onboard e1000e, three
  # NVMe drives and one SATA.
  flake.modules.nixos.m920qHardware = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];

      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    hardware = {
      # No nixos-hardware profile covers the M920q, so the firmware the NICs
      # and the microcode update want is requested here.
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}
