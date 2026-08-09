{
  flake.modules.homeManager.hyprland = {
    stylix.targets.waybar = {
      enable = true;
      addCss = false;
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings.mainBar = {
        layer = "top";
        position = "top";
        mode = "dock";
        exclusive = true;
        passthrough = false;
        gtk-layer-shell = true;

        modules-left = [
          "clock"
          "hyprland/workspaces"
        ];
        modules-center = ["hyprland/window"];
        modules-right = [
          "battery"
          "backlight"
          "tray"
          "pulseaudio"
        ];

        backlight = {
          format = "{icon} {percent}%";
          format-icons = [""];
          on-scroll-up = "brightnessctl set 1%+";
          on-scroll-down = "brightnessctl set 1%-";
          min-length = 6;
        };

        battery = {
          bat = "BAT0";
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%  {power:.1f} W";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          format-charging = "  {capacity}%";
          format-plugged = "  {capacity}%";
          format-alt = "{time} {icon}";
        };

        clock = {
          format = "  {:%R    %d/%m}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar-weeks-pos = "right";
          format-calendar-weeks = "<span color='#99ffdd'><b>W{:%V}</b></span>";
        };

        "hyprland/window" = {
          format = "{}";
          separate-outputs = true;
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-icons = [
            ""
            ""
            ""
          ];
          min-length = 7;
        };

        "hyprland/workspaces".on-click = "activate";
      };

      style = ''
        * {
          border: none;
          border-radius: 0;
          font-weight: bold;
          min-height: 0;
        }

        window#waybar,
        window#waybar.hidden {
          background: transparent;
        }

        tooltip {
          background: @base00;
          border: 2px solid @base01;
          border-radius: 10px;
        }

        tooltip label {
          padding: 8px 10px;
        }

        #workspaces button {
          padding: 5px;
          color: @base04;
          margin-right: 5px;
        }

        #workspaces button:last-child {
          margin-right: 0;
        }

        #workspaces button.active {
          color: @base05;
        }

        #workspaces button.focused {
          color: @base07;
          background: @base08;
          border-radius: 10px;
        }

        #workspaces button.urgent {
          color: @base00;
          background: @base0B;
          border-radius: 10px;
        }

        #workspaces button:hover {
          color: @base05;
          background: @base01;
          border-radius: 10px;
        }

        #window,
        #clock,
        #battery,
        #pulseaudio,
        #workspaces,
        #tray,
        #backlight {
          font-size: 12px;
          background: @base00;
          border: 1px solid @base01;
          border-radius: 10px;
          margin: 5px 0 3px;
        }

        #window,
        #clock,
        #battery,
        #pulseaudio,
        #tray,
        #backlight {
          padding: 2px 10px;
        }

        #tray {
          margin-left: 10px;
          margin-right: 10px;
        }

        #workspaces {
          margin-left: 10px;
          padding: 0 5px;
        }

        #window {
          margin-left: 60px;
          margin-right: 60px;
        }

        #clock {
          color: @base07;
          margin-left: 5px;
        }

        #pulseaudio {
          color: @base05;
        }

        #battery {
          color: @base0C;
          margin-right: 10px;
        }
      '';
    };
  };
}
