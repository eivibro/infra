{inputs, ...}: {
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      # Without this, disko drags in a second nixpkgs of its own.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # The same shape as laptopDisko, but not interchangeable with it. disko
  # derives partition labels from the disk's attribute name, and this machine
  # was installed with the disk named nvme0n1: its fstab and LUKS device point
  # at disk-nvme0n1-ESP and disk-nvme0n1-luks. Renaming the attribute would
  # leave the system looking for partitions that do not exist.
  flake.modules.nixos.masterchiefDisko = {
    imports = [
      inputs.disko.nixosModules.disko
    ];

    disko.devices.disk.nvme0n1 = {
      type = "disk";
      device = "/dev/nvme0n1";
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
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              passwordFile = "/tmp/secret.key";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "16G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
