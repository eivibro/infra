{inputs, ...}: {
  configurations.nixos.masterchief.module = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.self.modules.nixos.masterchiefHardware
      inputs.self.modules.nixos.masterchiefNvidia
      inputs.self.modules.nixos.masterchiefDisko
      inputs.self.modules.nixos.masterchiefInitrdUnlock
      inputs.self.modules.nixos.common
      inputs.self.modules.nixos.hyprland
      inputs.self.modules.nixos.sops
      inputs.self.modules.nixos.masterchiefAi
      inputs.self.modules.nixos.masterchiefSunshine
      inputs.self.modules.nixos.masterchiefPaseo
    ];

    home-manager.users.eivbro = {
      imports = [
        inputs.self.modules.homeManager.masterchief
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
    };

    users.users.eivbro = {
      hashedPasswordFile = config.sops.secrets."users/eivbro".path;
      extraGroups = [
        "docker"
        "audio"
        "video"
        "networkmanager"
        "adbusers"
        "uinput"
        "input"
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
      binfmt.emulatedSystems = ["aarch64-linux"];
    };

    networking = {
      hostName = "masterchief";
      networkmanager.enable = true;
      firewall.enable = false;
    };

    nixpkgs.config = {
      # Unfree here spans the NVIDIA driver, Steam and the CUDA libraries,
      # which is too many names for an allowUnfreePredicate list.
      allowUnfree = true;
      cudaSupport = false;
    };

    # cache.nixos-cuda.org replaces cuda-maintainers.cachix.org, which now
    # answers 401 for everything.
    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
      download-buffer-size = 524288000;
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

    programs.steam.enable = true;

    virtualisation = {
      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
      docker.enable = true;
    };

    hardware.bluetooth.enable = true;

    environment.systemPackages = with pkgs; [
      android-tools
      better-adb-sync
      cryptsetup
      hfsprogs
      podman-compose
      wireguard-tools
    ];

    environment.pathsToLink = ["/share/bash-completion"];

    services.fstrim.enable = true;
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = ["/" "/home"];
    };

    time.timeZone = "Europe/Oslo";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "no";
    };

    services.openssh.enable = true;

    system.stateVersion = "23.05";
  };
}
