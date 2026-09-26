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
      inputs.self.modules.nixos.m920qHomeIotDevices
      inputs.self.modules.nixos.m920qHomeCertificates
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
        # bind-dynamic rather than bind-interfaces: with three segments plus a
        # trunk that may have no carrier, binding a fixed address list at
        # startup means dnsmasq can fail before networkd has finished.
        interface = [
          "lo"
          "br-lan"
          "vlan81"
          "vlan82"
        ];
        bind-dynamic = true;

        # dnsmasq advertises itself as gateway and resolver per interface, from
        # that interface's own address.
        dhcp-range = [
          "192.168.80.100,192.168.80.200,12h"
          # The IoT pool starts at .150 to leave room for the reservations,
          # which carry over the last octet each device had under pfSense.
          "192.168.81.150,192.168.81.250,12h"
          "192.168.82.100,192.168.82.200,12h"
        ];

        server = ["1.1.1.1" "8.8.8.8"];
        domain-needed = true;
        bogus-priv = true;
      };
    };

    # Time is served locally so that IoT devices denied internet access still
    # get a clock, and so the nat prerouting redirect has somewhere to land.
    services.timesyncd.enable = false;
    services.chrony = {
      enable = true;
      extraConfig = ''
        allow 192.168.80.0/24
        allow 192.168.81.0/24
        allow 192.168.82.0/24
      '';
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
