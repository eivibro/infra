{
  # Fixed addresses on the flat LAN, for infrastructure that should not wander.
  #
  # Kept separate from iot.devices deliberately: those sit on their own segment
  # and carry an egress policy, whereas these are ordinary LAN hosts where the
  # only thing being declared is a stable address. Folding them together would
  # mean an `internet` flag that is meaningless for half the entries.
  #
  # Addresses are kept low and out of the DHCP pool (.100-.200):
  #   .1  this router
  #   .2  the service host, statically configured on the box itself
  #   .3  the access point
  #   .4  the managed switch
  flake.modules.nixos.m920qHomeLanDevices = {
    config,
    lib,
    ...
  }: {
    options.lan.reservations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          mac = lib.mkOption {
            type = lib.types.str;
            description = "Hardware address the reservation matches on.";
          };

          address = lib.mkOption {
            type = lib.types.str;
            description = "Reserved address, which must be outside the DHCP pool.";
          };
        };
      });
      default = {};
      description = "Fixed addresses handed out on the flat LAN.";
    };

    config = {
      lan.reservations = {
        # Zyxel NWA50AX. Its management and main SSID ride the native VLAN, so
        # it belongs here rather than on the IoT segment it also serves.
        "nwa50ax" = {
          mac = "b8:ec:a3:dc:4e:60";
          address = "192.168.80.3";
        };

        # TP-Link TL-SG105PE. Its management took a DHCP address on this
        # segment of its own accord once the VLANs were in place, which is
        # tidier than the VLAN 1 arrangement it started on — but a pool address
        # on the one device that carries the router's trunk is worth pinning.
        "tl-sg105pe" = {
          mac = "b0:a7:b9:6f:49:47";
          address = "192.168.80.4";
        };
      };

      services.dnsmasq.settings.dhcp-host =
        config.lan.reservations
        |> lib.mapAttrsToList (name: device: "${device.mac},${device.address},${name}");
    };
  };
}
