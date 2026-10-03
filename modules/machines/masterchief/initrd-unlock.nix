{
  # SSH in the initrd, for unlocking the LUKS root remotely. The host key is
  # state on disk, kept apart from the system's own host key.
  #
  # Carried over as it was. The ip= parameter names enp8s0, but the igc port
  # comes up as eno1, so the initrd network has most likely never come up.
  flake.modules.nixos.masterchiefInitrdUnlock = {
    boot.kernelParams = ["ip=::::masterchief:enp8s0:dhcp:"];

    boot.initrd = {
      availableKernelModules = ["igc"];

      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = ["/etc/secrets/initrd/ssh_host_ed25519_key"];
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2L5pouZVhwl3YAYSc7OEQQseM5fVFYD2/zzVqHzzzA root@auto"
          ];
        };
      };
    };
  };
}
