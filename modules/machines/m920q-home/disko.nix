{inputs, ...}: let
  # The three backup disks are identical apart from which device they sit on
  # and where they mount.
  backupDisk = device: name: mountpoint: {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions.luks = {
        size = "100%";
        content = {
          inherit name;
          type = "luks";
          initrdUnlock = false;
          passwordFile = "/tmp/secret.key";
          settings.allowDiscards = true;
          content = {
            type = "btrfs";
            extraArgs = ["-f"];
            subvolumes."@backup" = {
              inherit mountpoint;
              mountOptions = ["nofail" "compress=zstd:3" "noatime" "noauto"];
            };
          };
        };
      };
    };
  };
in {
  flake-file.inputs = {
    disko.url = "github:nix-community/disko";
  };

  # Devices are addressed by id because this machine has four disks of similar
  # size, and disko is destructive if it picks the wrong one.
  flake.modules.nixos.m920qDisko = {
    imports = [
      inputs.disko.nixosModules.disko
    ];

    disko.devices.disk = {
      os = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNX3M618715_1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["defaults"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  "@rootfs" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd:3" "noatime"];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd:3" "noatime"];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd:3" "noatime"];
                  };
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "16G";
                    mountOptions = ["noatime"];
                  };
                };
              };
            };
          };
        };
      };

      backup1 =
        backupDisk
        "/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNX0M295149_1"
        "backup-1"
        "/mnt/backup-1";

      backup2 =
        backupDisk
        "/dev/disk/by-id/nvme-LENSE20256GMSP34MEAT2TA_1227066303382_1"
        "backup-2"
        "/mnt/backup-2";

      backup3 =
        backupDisk
        "/dev/disk/by-id/ata-LITEONIT_LMT-256L9M-11_MSATA_256GB_TW0N42H7550854BO1282"
        "backup-3"
        "/mnt/backup-3";
    };
  };
}
