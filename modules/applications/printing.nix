{
  flake.modules.nixos.printing = {pkgs, ...}: {
    services.printing.enable = true;

    # Avahi for mDNS/Bonjour (needed for dnssd:// URIs).
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };

    # Scanning support (ET-2850 is an AIO).
    hardware.sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
    };
    services.saned.enable = true;

    environment.systemPackages = with pkgs; [
      cups
      sane-airscan
      simple-scan
      system-config-printer
    ];
  };
}
