{
  flake.modules.homeManager.graphical = {
    stylix.targets.dunst.enable = true;

    services.dunst = {
      enable = true;
      settings = {
        global = {
          width = 300;
          height = 300;
          offset = "30x50";
          origin = "top-right";
          corner_radius = 10;
        };

        urgency_normal.timeout = 10;
      };
    };

    services.gammastep = {
      enable = true;
      # Coarse Oslo-area coordinates avoid publishing a precise location.
      latitude = 59.9;
      longitude = 10.7;
      tray = true;
      temperature.night = 2800;
    };
  };
}
