{
  # Where the X1's home differs from the shared desktop roles.
  flake.modules.homeManager.x1Carbon = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      appimage-run
      croc
      darktable
      element-desktop
      freecad-wayland
      jellyfin-desktop
      moonlight-qt
      nmap
      p7zip
      powertop
      steam
      tor-browser
      unrar
    ];

    wayland.windowManager.hyprland.settings = {
      # Plain Norwegian first and Dvorak second, the reverse of the shared
      # order. The shared catch-all monitor line covers the internal panel.
      input.kb_variant = lib.mkForce ",dvorak";

      device = [
        {
          name = "zmk-project-broxboard-keyboard";
          kb_layout = "no";
        }
        {
          name = "broxboard-keyboard";
          kb_layout = "no";
        }
      ];
    };

    programs.git = {
      ignores = [
        ".direnv"
        ".venv"
        "__pycache__"
        "*.pyc"
      ];

      settings = {
        pull.rebase = false;
        merge.ff = "false";
      };
    };

    programs.neovim = {
      # Both default to true only because home.stateVersion predates 26.05.
      # No plugin here uses either provider, so take the current default.
      withPython3 = false;
      withRuby = false;
    };

    # Pinned to where the profile already lives. The 26.05 default is under
    # ~/.config, and adopting it means moving the profile directory by hand.
    programs.firefox.configPath = ".mozilla/firefox";

    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyFileSize = 10000;
    };
  };
}
