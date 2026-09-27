{
  # Where the self-hosted services currently live.
  #
  # This is the one line that changes at cutover. The Arch box holds
  # 192.168.41.2 on pfSense's LAN today; when 192.168.41.0/24 ceases to exist
  # it moves to 192.168.80.2 on this router's LAN. Both the nginx proxy and the
  # firewall rules that let Shelly devices reach Home Assistant read it from
  # here, so they cannot disagree — and neither has to be edited under pressure
  # while six services are down.
  flake.modules.nixos.m920qHomeServiceHost = {lib, ...}: {
    options.homeServices.host = lib.mkOption {
      type = lib.types.str;
      example = "192.168.80.2";
      description = ''
        Address of the machine running the proxied services. Read by the nginx
        backends and by the IoT-to-Home-Assistant firewall rules.
      '';
    };

    config.homeServices.host = "192.168.41.2";
  };
}
