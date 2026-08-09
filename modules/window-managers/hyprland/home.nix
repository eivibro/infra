{
  flake.modules.homeManager.hyprland = {
    config,
    pkgs,
    ...
  }: {
    home.sessionVariables.HYPRLAND_CONFIG = "${config.xdg.configHome}/hypr/hyprland.conf";

    stylix.targets = {
      hyprland.enable = true;
      hyprland.hyprpaper.enable = true;
    };

    home.packages = [pkgs.grimblast];

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      configType = "hyprlang";

      settings = {
        "$mainMod" = "SUPER";

        monitor = ", preferred, auto, auto";

        env = [
          "GDK_BACKEND,wayland"
          "XKB_DEFAULT_LAYOUT,no"
          "XKB_DEFAULT_VARIANT,dvorak"
        ];

        general = {
          gaps_in = 5;
          gaps_out = 5;
          border_size = 2;
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;

          blur = {
            enabled = true;
            ignore_opacity = true;
            size = 3;
            passes = 1;
          };

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
          };
        };

        input = {
          kb_layout = "no,no";
          kb_variant = "dvorak,";
          kb_options = "grp:alt_shift_toggle";
          follow_mouse = 1;
          resolve_binds_by_sym = true;
          sensitivity = 0;

          touchpad = {
            natural_scroll = true;
            "tap-to-click" = false;
          };
        };

        misc = {
          disable_hyprland_logo = true;
          disable_watchdog_warning = true;
          force_default_wallpaper = 0;
        };

        xwayland.force_zero_scaling = true;
        dwindle.preserve_split = true;

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        bind = [
          "$mainMod, Q, exec, kitty"
          "$mainMod SHIFT, M, exit,"
          "$mainMod, B, exec, firefox"
          "$mainMod, C, killactive,"
          "$mainMod, F, fullscreen, 0"
          "$mainMod, V, togglefloating,"
          "$mainMod, D, exec, tofi-drun --drun-launch=true"
          "$mainMod SHIFT, D, exec, tofi-run | xargs hyprctl dispatch exec"
          "$mainMod, P, pseudo,"
          "$mainMod SHIFT, L, exec, loginctl lock-session"
          "$mainMod CONTROL, L, cyclenext,"

          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          "$mainMod, H, movefocus, l"
          "$mainMod, L, movefocus, r"
          "$mainMod, J, movefocus, u"
          "$mainMod, K, movefocus, d"

          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          "$mainMod, TAB, workspace, previous"

          "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
          "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
          "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
          "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
          "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
          "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
          "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
          "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
          "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
          "$mainMod SHIFT, 0, movetoworkspacesilent, 10"

          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

          "$mainMod, S, pin,"
          "$mainMod, T, exec, hyprctl switchxkblayout all next"
        ];

        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
        ];

        bindl = [
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPause, exec, playerctl play-pause"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        windowrule = [
          "match:class ^(mpv)$, float on, no_initial_focus on, move monitor_w*0.75 monitor_h*0.70, size monitor_w*0.20 monitor_h*0.20"
          "match:title ^(Picture-in-Picture)$, float on, move monitor_w*0.75 monitor_h*0.70, size monitor_w*0.20 monitor_h*0.20"
        ];
      };
    };
  };
}
