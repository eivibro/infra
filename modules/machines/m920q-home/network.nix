{
  flake.modules.nixos.m920qHomeNetwork = {
    # Ports are named by MAC rather than by predictable name, because which
    # riser slot enumerates first is not something to depend on.
    systemd.network.links = {
      "10-wan" = {
        matchConfig.MACAddress = "00:e2:59:02:7b:8e";
        linkConfig.Name = "wan0";
      };
      "10-lan0" = {
        matchConfig.MACAddress = "00:e2:59:02:7b:8f";
        linkConfig.Name = "lan0";
      };
      "10-lan1" = {
        matchConfig.MACAddress = "00:e2:59:02:7b:90";
        linkConfig.Name = "lan1";
      };
      "10-lan2" = {
        matchConfig.MACAddress = "00:e2:59:02:7b:91";
        linkConfig.Name = "lan2";
      };
      "10-lan3" = {
        matchConfig.MACAddress = "f8:75:a4:c5:6d:f3";
        linkConfig.Name = "lan3";
      };
    };

    systemd.network.netdevs."br-lan".netdevConfig = {
      Name = "br-lan";
      Kind = "bridge";
    };

    systemd.network.networks = {
      "10-lan-port0" = {
        matchConfig.Name = "lan0";
        networkConfig.Bridge = "br-lan";
      };
      "10-lan-port1" = {
        matchConfig.Name = "lan1";
        networkConfig.Bridge = "br-lan";
      };
      "10-lan-port2" = {
        matchConfig.Name = "lan2";
        networkConfig.Bridge = "br-lan";
      };
      "10-lan-port3" = {
        matchConfig.Name = "lan3";
        networkConfig.Bridge = "br-lan";
      };

      "20-br-lan" = {
        matchConfig.Name = "br-lan";
        address = ["192.168.80.1/24"];

        # The bridge has to carry its address even with every port empty, or
        # dnsmasq has nothing to bind to.
        networkConfig.ConfigureWithoutCarrier = true;
      };

      "30-wan" = {
        matchConfig.Name = "wan0";
        networkConfig.DHCP = "ipv4";

        # dnsmasq holds the upstream resolvers instead.
        dhcpV4Config.UseDNS = false;
      };
    };
  };
}
