{
  flake.modules.nixos.m920qHomeFirewall = {
    boot.kernel.sysctl = {
      "net.ipv4.conf.wan0.rp_filter" = 1;

      # Loose mode on the bridge: return paths differ once traffic can leave
      # through a tunnel rather than through wan0.
      "net.ipv4.conf.br-lan.rp_filter" = 2;

      "net.ipv4.conf.wan0.send_redirects" = 0;
      "net.ipv4.conf.wan0.accept_redirects" = 0;
      "net.ipv4.conf.wan0.accept_source_route" = 0;
      "net.ipv4.conf.wan0.log_martians" = 1;
    };

    networking.nftables.tables = {
      filter = {
        family = "inet";
        content = ''
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
          }
        '';
      };

      nat = {
        family = "ip";
        content = ''
          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;

            ip saddr 192.168.70.0/24 oifname "wan0" masquerade comment "parents LAN via home exit"
            ip saddr 192.168.80.0/24 oifname "wan0" masquerade comment "NAT LAN to WAN"
            ip saddr 10.202.0.0/24 oifname "wan0" masquerade comment "NAT wg1 phone to WAN"
          }
        '';
      };
    };
  };
}
