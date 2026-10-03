{
  # Where masterchief's home differs from the shared desktop roles.
  flake.modules.homeManager.masterchief = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      appimage-run
      bottles
      claude-code
      croc
      darktable
      element-desktop
      freecad-wayland
      grok-build
      jellyfin-desktop
      mcp-nixos
      moonlight-qt
      nmap
      p7zip
      powertop
      tor-browser
      unrar
    ];

    wayland.windowManager.hyprland.settings = {
      monitor = lib.mkForce [
        "DP-3,2560x1440@144,0x0,1"
        "Unknown-1,disable"
      ];

      # Plain Norwegian first and Dvorak second, the reverse of the shared
      # order.
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

    media = {
      av1.enable = false;
      maxHeight = 1440;
    };

    programs.mpv.config = {
      autofit-larger = lib.mkForce "20%";
      hwdec = lib.mkForce "nvdec-copy";
      hwdec-codecs = "h264,hevc,vp8,vp9";
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      initLua = ''
        vim.opt.relativenumber = true
        vim.opt.cursorline = true
      '';
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyFileSize = 10000;
    };
  };
}
