{
  # Reverse proxy for the handful of services reached by name on the LAN,
  # taking over from HAProxy on pfSense.
  #
  # The point of a proxy here is that the public name is decoupled from where
  # the service actually runs. Porting a service off the Arch box becomes a
  # per-entry `host` override, and the Arch box's own move at cutover is a
  # single change to archBox.
  flake.modules.nixos.m920qHomeProxy = {lib, ...}: let
    domain = "brox.tech";

    # The Arch box being phased out. Its address disappears with the
    # 192.168.41.0/24 segment at cutover, at which point this is the only line
    # that changes.
    archBox = "192.168.41.2";

    # Where the names resolve to on the LAN: this router.
    proxyAddress = "192.168.80.1";

    # Ports carried over from the pfSense HAProxy backends. Add `host = ...` to
    # an entry once that service has been ported somewhere else.
    proxied = {
      hass.port = 8123;
      navidrome.port = 4533;
      ntfy.port = 8085;
      paperless.port = 8001;
      vaultwarden.port = 8082;
      zigbee.port = 8083;
    };
  in {
    services.nginx = {
      enable = true;

      # Bound to the LAN rather than every interface. nftables already drops
      # this on wan0, but this machine is becoming the edge router and a single
      # firewall mistake should not expose six services to the internet.
      defaultListenAddresses = [
        proxyAddress
        "127.0.0.1"
      ];

      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;

      virtualHosts =
        proxied
        |> lib.mapAttrs' (
          name: service:
            lib.nameValuePair "${name}.${domain}" {
              useACMEHost = domain;
              forceSSL = true;

              locations."/" = {
                proxyPass = "http://${service.host or archBox}:${toString service.port}";

                # Home Assistant, zigbee2mqtt and ntfy all push over
                # websockets; without this their pages load but never update.
                proxyWebsockets = true;
              };
            }
        );
    };

    # The names currently resolve to pfSense's HAProxy through its unbound.
    # Answering them here means anything resolving through this router reaches
    # the new proxy, while everything else carries on unchanged — so the whole
    # path can be exercised before cutover.
    services.dnsmasq.settings.address =
      proxied
      |> lib.mapAttrsToList (name: _: "/${name}.${domain}/${proxyAddress}");
  };
}
