{inputs, ...}: {
  configurations.nixos.x1-carbon.module = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-10th-gen
      inputs.self.modules.nixos.x1CarbonHardware
      inputs.self.modules.nixos.laptopDisko
      inputs.self.modules.nixos.x1CarbonDisko
      inputs.self.modules.nixos.x1CarbonPower
      inputs.self.modules.nixos.common
      inputs.self.modules.nixos.hyprland
      inputs.self.modules.nixos.sops
      inputs.self.modules.nixos.printing
    ];

    home-manager.users.eivbro = {
      imports = [
        inputs.self.modules.homeManager.x1Carbon
        inputs.self.modules.homeManager.vscodium
        inputs.self.modules.homeManager.starship
      ];

      # This home was first activated on 23.05, under the previous
      # configuration.
      home.stateVersion = "23.05";
    };

    sops.secrets = {
      "users/eivbro" = {
        sopsFile = ./secrets.yaml;
        neededForUsers = true;
      };
      "users/root" = {
        sopsFile = ./secrets.yaml;
        neededForUsers = true;
      };
      "wifi/laptop" = {
        sopsFile = ./secrets.yaml;
      };
      "ssh/backup-x1-carbon" = {
        sopsFile = ./secrets.yaml;
        mode = "0400";
        owner = "root";
      };
    };

    users.users.eivbro = {
      hashedPasswordFile = config.sops.secrets."users/eivbro".path;
      extraGroups = [
        "docker"
        "audio"
        "video"
        "networkmanager"
        "adbusers"
      ];
    };

    users.users.root = {
      hashedPasswordFile = config.sops.secrets."users/root".path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODszKxVNbFzpfLPTrnx9hP/LBuBgv5lHEAPU9Mq5pXQ eivbro@nixos"
      ];
    };

    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      supportedFilesystems = ["ntfs"];
      kernel.sysctl."kernel.sysrq" = 1;
    };

    networking = {
      # The machine's hostname. The flake attribute stays x1-carbon, so a
      # rebuild names the configuration explicitly.
      hostName = "carbon";
      networkmanager.enable = true;
      firewall.enable = false;
    };

    # Unfree here is steam and the other packages the previous configuration
    # allowed through a blanket flag.
    nixpkgs.config.allowUnfree = true;

    # cuda-maintainers.cachix.org answers 401, and the old hyprland.cachix.org
    # key was mistyped so it never verified. Hyprland comes from nixpkgs now.
    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    programs.direnv = {
      enable = true;
      loadInNixShell = true;
      nix-direnv.enable = true;
    };

    programs.ssh.extraConfig = ''
      Host m920q-backup
        Hostname 192.168.70.1
        User btrbk
        IdentityFile /run/secrets/ssh/backup-x1-carbon
        StrictHostKeyChecking yes
        BatchMode yes
    '';

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    hardware.bluetooth.enable = true;

    environment.systemPackages = with pkgs; [
      android-tools
      hfsprogs
      wireguard-tools
    ];

    environment.pathsToLink = ["/share/bash-completion"];

    time.timeZone = "Europe/Oslo";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "dvorak-no";
    };

    services.openssh.enable = true;

    system.stateVersion = "23.05";
  };
}
