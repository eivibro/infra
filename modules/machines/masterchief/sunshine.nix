{
  # Game streaming to Moonlight clients, encoding on the NVIDIA card.
  flake.modules.nixos.masterchiefSunshine = {pkgs, ...}: {
    # Sunshine injects input through uinput and uhid.
    hardware.uinput.enable = true;

    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
      KERNEL=="uhid", MODE="0660", GROUP="input"
    '';

    services.sunshine = {
      enable = true;
      # Required for capture under Wayland.
      capSysAdmin = true;
      openFirewall = true;

      # CUDA for this one package only; nixpkgs.config.cudaSupport stays off.
      package = pkgs.sunshine.override {
        cudaSupport = true;
        cudaPackages = pkgs.cudaPackages;
      };

      settings = {
        encoder = "nvenc";
        # A low-latency preset suited to Turing (RTX 20-series); p6 or p7 trade
        # a little latency for quality.
        nv_preset = "p5";
        hevc_mode = "1";
      };
    };
  };
}
