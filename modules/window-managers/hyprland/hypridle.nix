{
  flake.modules.homeManager.hyprland = {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          ignore_dbus_inhibit = false;
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
        ];
      };
    };
  };
}
