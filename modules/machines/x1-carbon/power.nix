{
  # Power tuning from the previous standard-laptop profile, unchanged.
  flake.modules.nixos.x1CarbonPower = {
    services.system76-scheduler = {
      enable = true;
      settings.cfsProfiles.enable = true;
    };

    environment.etc."system76-scheduler/config.toml".text = ''
      [cfs_profiles]
      enable = true

      [hybrid]
      enable = true
      background = "efficiency"
      foreground = "performance"
      default = "balance"
    '';

    services.thermald.enable = true;
    services.power-profiles-daemon.enable = false;

    services.tlp = {
      enable = true;
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
        CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
        ENERGY_PERF_POLICY_ON_AC = "performance";
        ENERGY_PERF_POLICY_ON_BAT = "power";
        USB_EXCLUDE_BTUSB = 1;
        START_CHARGE_THRESH_BAT0 = 50;
        STOP_CHARGE_THRESH_BAT0 = 80;
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";
        NVME_APST_ON_AC = 1;
        NVME_APST_ON_BAT = 1;
        INTEL_GPU_MIN_FREQ_ON_AC = "300";
        INTEL_GPU_MAX_FREQ_ON_AC = "1300";
        INTEL_GPU_MIN_FREQ_ON_BAT = "300";
        INTEL_GPU_MAX_FREQ_ON_BAT = "1000";
      };
    };
  };
}
