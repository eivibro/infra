{
  flake.modules.homeManager.onedrive = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.onedrive];

    xdg.configFile."onedrive/config".text = ''
      threads = "4"
    '';

    xdg.configFile."onedrive/sync_list".text = lib.concatLines [
      "Synkroniser"
    ];

    systemd.user.services.onedrive = {
      Unit = {
        Description = "OneDrive Client for Linux";
        Documentation = "https://github.com/abraunegg/onedrive";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service = {
        ProtectSystem = "full";
        ProtectHostname = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictRealtime = true;
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 15";
        ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor";
        Restart = "on-failure";
        RestartSec = 3;
        RestartPreventExitStatus = 126;
        TimeoutStopSec = 90;
      };

      Install.WantedBy = ["default.target"];
    };
  };
}
