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

    systemd.network.netdevs = {
      "br-lan".netdevConfig = {
        Name = "br-lan";
        Kind = "bridge";
      };

      # The VLANs carried on the trunk to the TL-SG105PE. They hang off lan3
      # rather than off the bridge, because a VLAN interface on a bridge
      # *member* never receives anything: the bridge claims frames first. lan3
      # is deliberately not a bridge member, so its VLAN children work, and
      # vlan80 is enslaved to the bridge instead.
      #
      # The switch presents 80 untagged to the access point and tagged to this
      # trunk, so the AP keeps its management VLAN native and recovery through
      # its fallback address stays possible.
      "vlan80" = {
        netdevConfig = {
          Name = "vlan80";
          Kind = "vlan";
        };
        vlanConfig.Id = 80;
      };
      "vlan81" = {
        netdevConfig = {
          Name = "vlan81";
          Kind = "vlan";
        };
        vlanConfig.Id = 81;
      };
      "vlan82" = {
        netdevConfig = {
          Name = "vlan82";
          Kind = "vlan";
        };
        vlanConfig.Id = 82;
      };
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

      # Trunk to the switch. Carries no address of its own; everything rides on
      # the tagged children.
      "15-trunk" = {
        matchConfig.Name = "lan3";
        vlan = [
          "vlan80"
          "vlan81"
          "vlan82"
        ];
        networkConfig.LinkLocalAddressing = "no";
      };

      # VLAN 80 joins the flat LAN, so the access point's main network shares
      # one broadcast domain with the wired ports.
      "16-vlan80" = {
        matchConfig.Name = "vlan80";
        networkConfig.Bridge = "br-lan";
      };

      # ConfigureWithoutCarrier throughout: dnsmasq needs an address to serve
      # from even when nothing is plugged into the trunk yet.
      "20-br-lan" = {
        matchConfig.Name = "br-lan";
        address = ["192.168.80.1/24"];
        networkConfig.ConfigureWithoutCarrier = true;
      };

      "21-iot" = {
        matchConfig.Name = "vlan81";
        address = ["192.168.81.1/24"];
        networkConfig.ConfigureWithoutCarrier = true;
      };

      "22-guest" = {
        matchConfig.Name = "vlan82";
        address = ["192.168.82.1/24"];
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
