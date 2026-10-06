{
  # laptopDisko already matches this machine's layout, including the disk
  # attribute name sda that the live labels were derived from
  # (disk-sda-ESP, disk-sda-luks). The only extra is the Pictures subvolume.
  flake.modules.nixos.x1CarbonDisko = {
    disko.devices.disk.sda.content.partitions.luks.content.content.subvolumes."/home/eivbro/Pictures" = {
      mountpoint = "/home/eivbro/Pictures";
      mountOptions = ["compress=zstd" "noatime"];
    };
  };
}
