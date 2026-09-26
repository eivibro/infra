{
  # One list of IoT devices, driving both the DHCP reservations and the egress
  # allow-list. Keeping them together means a device cannot end up with a
  # stable address but the wrong internet policy, or vice versa.
  #
  # Addresses carry over the last octet each device had under pfSense, so the
  # only change is the third octet. All of them sit below the DHCP pool, which
  # matters: the allow-list keys on address, so a device must have a
  # reservation before it can be granted egress.
  flake.modules.nixos.m920qHomeIotDevices = {
    config,
    lib,
    ...
  }: {
    options.iot.devices = lib.mkOption {
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

          internet = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Whether this device is allowed out to the internet. Off by
              default: most of these only ever talk to Home Assistant, and
              still get DHCP, DNS and NTP from the router either way.
            '';
          };
        };
      });
      default = {};
    };

    config = {
      iot.devices = {
        # Shelly Gen2 — outbound WebSocket to Home Assistant, local control.
        "shellyplus1-kitchen" = {
          mac = "44:17:93:aa:04:e8";
          address = "192.168.81.15";
        };
        "shellyplus1-bedroom" = {
          mac = "7c:87:ce:64:30:7c";
          address = "192.168.81.16";
        };
        "shellyplusplugs-computer" = {
          mac = "e4:65:b8:b8:e0:1c";
          address = "192.168.81.17";
        };
        "shellyplusplugs-c82e180a12b0" = {
          mac = "c8:2e:18:0a:12:b0";
          address = "192.168.81.107";
        };

        # Shelly Gen1 — CoIoT push to Home Assistant over UDP 5683.
        "shellydimmer2-bathroom" = {
          mac = "c4:5b:be:78:69:f2";
          address = "192.168.81.101";
        };
        "shellydimmer2-kitchen" = {
          mac = "c4:5b:be:78:39:09";
          address = "192.168.81.102";
        };
        "shellydimmer2-hallway" = {
          mac = "c8:c9:a3:3c:f3:a3";
          address = "192.168.81.106";
        };
        "shellyswitch25-zip-screen" = {
          mac = "10:52:1c:07:aa:df";
          address = "192.168.81.103";
        };
        "shellyswitch25-kitchen-dual" = {
          mac = "10:52:1c:07:96:c7";
          address = "192.168.81.104";
        };
        "shellyplug-s1" = {
          mac = "c8:c9:a3:b9:3d:5c";
          address = "192.168.81.105";
        };

        # ESPHome — Home Assistant connects to these on TCP 6053.
        "pwm-fan1" = {
          mac = "68:b6:b3:79:12:c0";
          address = "192.168.81.30";
        };
        "plant-light-controller" = {
          mac = "dc:06:75:a9:6c:0c";
          address = "192.168.81.31";
        };
        "senseair" = {
          mac = "70:04:1d:22:85:ec";
          address = "192.168.81.32";
        };
        "pms" = {
          mac = "dc:06:75:9d:8c:b4";
          address = "192.168.81.34";
        };
        "uv" = {
          mac = "dc:06:75:9d:69:1c";
          address = "192.168.81.36";
        };
        "everything-presence-lite" = {
          mac = "68:b6:b3:bc:5a:24";
          address = "192.168.81.37";
        };

        # Appliances. Their smart features go unused, so there is nothing to
        # lose by denying the cloud and something to gain by not being talked
        # about to Samsung.
        "samsung-washer" = {
          mac = "40:ca:63:23:4b:af";
          address = "192.168.81.21";
        };
        "samsung-dryer" = {
          mac = "88:57:1d:c3:e8:5a";
          address = "192.168.81.22";
        };

        # Robot vacuum, cloud-dependent for now.
        "zoe" = {
          mac = "24:18:c6:15:01:26";
          address = "192.168.81.19";
          internet = true;
        };
      };

      # dnsmasq also serves these names in DNS, so Home Assistant can use
      # hostnames rather than addresses.
      services.dnsmasq.settings.dhcp-host =
        config.iot.devices
        |> lib.mapAttrsToList (name: device: "${device.mac},${device.address},${name}");
    };
  };
}
