{
  # wg1 carries a roadwarrior phone, wg2 is the site-to-site link to the
  # m920q at the parents' house and takes over what the pfSense
  # WG_HAAKONSVEI_M920Q tunnel does today.
  #
  # Both private keys come from sops.
  flake.modules.nixos.m920qHomeWireguard = {config, ...}: {
    # networkd reads PrivateKeyFile as systemd-network when it creates the
    # netdev, so a root-only secret yields an interface with no key and no
    # obvious error.
    sops.secrets = let
      forNetworkd = {
        sopsFile = ./secrets.yaml;
        owner = "systemd-network";
        group = "systemd-network";
        mode = "0400";
        restartUnits = ["systemd-networkd.service"];
      };
    in {
      "wireguard/wg1" = forNetworkd;
      "wireguard/wg2" = forNetworkd;
    };

    systemd.network.netdevs = {
      "30-wg1" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg1";
        };
        wireguardConfig = {
          PrivateKeyFile = config.sops.secrets."wireguard/wg1".path;
          ListenPort = 51436;
        };
        wireguardPeers = [
          {
            PublicKey = "aUIYehx6eqdlmCKNu+erVL9a6grudv/XwBOivY1hBkU=";
            AllowedIPs = ["10.202.0.2/32"];
            PersistentKeepalive = 25;
          }
        ];
      };

      "40-wg2" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg2";
        };
        wireguardConfig = {
          PrivateKeyFile = config.sops.secrets."wireguard/wg2".path;
          ListenPort = 51437;
        };
        wireguardPeers = [
          {
            PublicKey = "0kd/HJkbp8uPx+rtWsjjrc8SNULocOvrb/7PddHYoyQ=";
            Endpoint = "wireguard.ebrox.xyz:51437";
            AllowedIPs = [
              "10.203.0.2/32"
              "192.168.70.0/24"
            ];
            PersistentKeepalive = 25;
          }
        ];
      };
    };

    systemd.network.networks = {
      "30-wg1" = {
        matchConfig.Name = "wg1";
        address = ["10.202.0.1/24"];
        networkConfig.IPv4Forwarding = true;
      };

      "40-wg2" = {
        matchConfig.Name = "wg2";
        address = ["10.203.0.1/24"];
        networkConfig.IPv4Forwarding = true;
        routes = [
          {Destination = "192.168.70.0/24";}
        ];
      };
    };
  };
}
