{inputs, ...}: {
  configurations.nixos.m920q-home.module = {pkgs, ...}: {
    imports = [
      inputs.self.modules.nixos.m920qHardware
      inputs.self.modules.nixos.m920qDisko
      inputs.self.modules.nixos.common
      inputs.self.modules.nixos.homeManager
      inputs.self.modules.nixos.router
      inputs.self.modules.nixos.sops
      inputs.self.modules.nixos.switchFix
      inputs.self.modules.nixos.m920qHomeNetwork
      inputs.self.modules.nixos.m920qHomeFirewall
      inputs.self.modules.nixos.m920qHomeWireguard
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking = {
      hostName = "m920q-home";
      enableIPv6 = false;

      # dnsmasq is the resolver for this machine as well as for the LAN.
      nameservers = ["127.0.0.1"];
    };

    services.dnsmasq = {
      enable = true;
      settings = {
        interface = ["br-lan"];
        bind-interfaces = true;
        listen-address = ["127.0.0.1" "192.168.80.1"];
        dhcp-range = ["192.168.80.100,192.168.80.200,12h"];
        server = ["1.1.1.1" "8.8.8.8"];
        domain-needed = true;
        bogus-priv = true;
      };
    };

    # Everything else this machine had is already in the common role or the
    # router role.
    environment.systemPackages = [pkgs.s-tui];

    services.fstrim.enable = true;
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = ["/" "/home"];
    };

    # This flake sets pipe-operators through nixConfig, which is only honoured
    # when the evaluating machine accepts it.
    nix.settings.accept-flake-config = true;

    time.timeZone = "Europe/Oslo";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "no";
    };

    services.openssh.enable = true;

    system.stateVersion = "26.05";
  };
}
