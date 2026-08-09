{
  flake.modules.homeManager.hyprland = {config, ...}: let
    colors = config.lib.stylix.colors;
  in {
    stylix.targets.hyprlock = {
      enable = true;
      image.enable = true;
    };

    programs.hyprlock = {
      enable = true;

      settings = {
        general.hide_cursor = true;

        background = {
          blur_passes = 3;
          blur_size = 6;
        };

        input-field = {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          outline_thickness = 5;
          placeholder_text = "Password…";
          shadow_passes = 2;
        };

        label = [
          {
            text = ''cmd[update:1000] date "+%H:%M"'';
            color = "rgb(${colors.base0F})";
            font_size = 96;
            position = "0, 120";
            halign = "center";
            valign = "center";
          }
          {
            text = ''cmd[update:60000] date "+%A, %d %B"'';
            color = "rgb(${colors.base0F})";
            font_size = 28;
            position = "0, 40";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
