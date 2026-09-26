{
  flake.modules.nixos.m920qHomeFirewall = let
    # Only these IoT addresses reach the internet. Everything else on vlan81
    # still gets DHCP, DNS and NTP from the router, which for most devices is
    # all they need. Adding a device here is the one-line change that gives it
    # egress.
    iotInternetAllowed = [
      # "192.168.81.21" # Samsung washer, needs SmartThings
      # "192.168.81.22" # Samsung dryer, needs SmartThings
      #
      # Only addresses outside the DHCP pool belong here. Allow-listing a
      # dynamic lease grants egress to whichever device happens to hold it, so
      # a device needs a static reservation before it gets a line above.
    ];

    iotOnlineSet =
      if iotInternetAllowed == []
      then ""
      else "elements = { ${builtins.concatStringsSep ", " iotInternetAllowed} }";
  in {
    boot.kernel.sysctl = {
      "net.ipv4.conf.wan0.rp_filter" = 1;

      # Loose mode on the bridge: return paths differ once traffic can leave
      # through a tunnel rather than through wan0.
      "net.ipv4.conf.br-lan.rp_filter" = 2;

      # The VLAN segments each have exactly one path, so strict is correct.
      "net.ipv4.conf.vlan81.rp_filter" = 1;
      "net.ipv4.conf.vlan82.rp_filter" = 1;

      "net.ipv4.conf.wan0.send_redirects" = 0;
      "net.ipv4.conf.wan0.accept_redirects" = 0;
      "net.ipv4.conf.wan0.accept_source_route" = 0;
      "net.ipv4.conf.wan0.log_martians" = 1;
    };

    networking.nftables.tables = {
      filter = {
        family = "inet";
        content = ''
          set iot_online {
            type ipv4_addr
            ${iotOnlineSet}
          }

          chain input {
            type filter hook input priority filter; policy drop;

            iifname "wan0" udp dport 51437 accept comment "wg2 site-to-site"
            iifname "wg2" accept comment "wg2 to router"
            iifname "wg1" accept comment "WireGuard to router"

            # REMOVE BEFORE THIS MACHINE BECOMES THE EDGE ROUTER. Reachable
            # only from the pfSense LAN while it sits behind pfSense; on the
            # frontier it is SSH published to the internet.
            iifname "wan0" tcp dport 22 accept comment "temporary SSH from WAN"

            iifname "wan0" udp dport 51436 accept comment "wg1 roadwarrior handshake"

            iifname "wan0" ip saddr {
              0.0.0.0/8, 10.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16,
              172.16.0.0/12, 192.168.0.0/16, 224.0.0.0/4, 240.0.0.0/4,
              255.255.255.255/32
            } log prefix "SPOOF-INP: " drop comment "anti-spoofing"

            iif "lo" accept
            ct state established,related accept
            iifname { "br-lan", "lan0", "lan1", "lan2", "lan3" } accept comment "LAN to router"

            # IoT and Guest get the router's services and nothing else: no SSH,
            # no node exporter.
            iifname { "vlan81", "vlan82" } udp dport { 53, 67, 123 } accept comment "DNS, DHCP, NTP"
            iifname { "vlan81", "vlan82" } tcp dport 53 accept comment "DNS over TCP"

            iifname "wan0" log prefix "DROP-WAN-UNWANTED: " drop comment "drop all other WAN input"
          }

          chain forward {
            type filter hook forward priority filter; policy drop;

            iifname "wg2" oifname "br-lan" accept
            iifname "wg2" oifname "wan0" accept comment "parents LAN via home exit"
            iifname "br-lan" oifname "wg2" accept

            ct state established,related accept

            iifname "br-lan" oifname "wan0" accept comment "LAN to WAN"
            iifname "wg1" oifname "wan0" accept comment "wg1 phone to internet (full tunnel)"
            iifname "wg1" oifname "br-lan" accept comment "wg1 phone to LAN"
            iifname "br-lan" oifname "wg1" accept comment "LAN to wg1 phone"

            # The LAN reaches IoT so devices stay controllable; IoT cannot open
            # anything toward the LAN, and conntrack above carries the replies.
            iifname "br-lan" oifname "vlan81" accept comment "LAN to IoT"

            iifname "vlan81" oifname "wan0" ip saddr @iot_online accept comment "allow-listed IoT to internet"
            iifname "vlan82" oifname "wan0" accept comment "Guest to internet"

            # Everything unstated is dropped by policy: IoT to LAN, Guest to
            # anything local, IoT and Guest to each other, either into the
            # tunnels.
          }
        '';
      };

      nat = {
        family = "ip";
        content = ''
          chain prerouting {
            type nat hook prerouting priority dstnat; policy accept;

            # Cheap IoT hardware routinely hardcodes its NTP and DNS servers
            # and ignores what DHCP offers. Redirecting means time and name
            # resolution are local services rather than firewall exceptions,
            # and no device quietly resolves through someone else's server.
            iifname { "vlan81", "vlan82" } udp dport 123 redirect to :123 comment "hijack NTP"
            iifname { "vlan81", "vlan82" } udp dport 53 redirect to :53 comment "hijack DNS"
            iifname { "vlan81", "vlan82" } tcp dport 53 redirect to :53 comment "hijack DNS over TCP"
          }

          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;

            ip saddr 192.168.70.0/24 oifname "wan0" masquerade comment "parents LAN via home exit"
            ip saddr 192.168.80.0/24 oifname "wan0" masquerade comment "NAT LAN to WAN"
            ip saddr 192.168.81.0/24 oifname "wan0" masquerade comment "NAT IoT to WAN"
            ip saddr 192.168.82.0/24 oifname "wan0" masquerade comment "NAT Guest to WAN"
            ip saddr 10.202.0.0/24 oifname "wan0" masquerade comment "NAT wg1 phone to WAN"
          }
        '';
      };
    };
  };
}
