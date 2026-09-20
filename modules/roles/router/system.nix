{
  # Router posture that is not specific to any one topology. Addresses,
  # interface names and the ruleset itself belong to the machine.
  flake.modules.nixos.router = {
    lib,
    pkgs,
    ...
  }: {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = lib.mkDefault 1;
      "net.ipv4.conf.default.rp_filter" = lib.mkDefault 1;
      "net.ipv4.conf.all.rp_filter" = lib.mkDefault 0;
      "net.ipv4.tcp_syncookies" = lib.mkDefault 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkDefault 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = lib.mkDefault 1;
      "net.ipv4.tcp_tw_reuse" = lib.mkDefault 1;
      "net.ipv4.tcp_fin_timeout" = lib.mkDefault 15;
    };

    networking = {
      useNetworkd = lib.mkDefault true;
      useDHCP = lib.mkForce false;

      # nftables owns filtering and NAT outright; the scripted firewall and the
      # nat module would only add a second, partly overlapping ruleset.
      nat.enable = lib.mkDefault false;
      firewall.enable = lib.mkDefault false;

      nftables = {
        enable = true;
        flushRuleset = lib.mkForce true;
        checkRuleset = lib.mkDefault true;
      };
    };

    # A LAN port with nothing plugged into it would otherwise hold up boot.
    systemd.network.wait-online.enable = lib.mkDefault false;

    # networkd pulls in resolved by default, which takes /etc/resolv.conf and
    # points it at a stub. dnsmasq is the resolver on a router, so the stub is
    # one indirection with nothing to add.
    services.resolved.enable = lib.mkForce false;

    # A router that suspends takes the network down with it.
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    services.prometheus.exporters.node = {
      enable = lib.mkDefault true;
      port = lib.mkDefault 9100;
      enabledCollectors = lib.mkDefault ["systemd"];
    };

    environment.systemPackages = with pkgs; [
      dig
      iproute2
      net-tools
      nftables
      tcpdump
      wireguard-tools
    ];
  };
}
