{
  flake.modules.homeManager.graphical = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      brightnessctl
      pavucontrol
      playerctl
      wl-clipboard
      wlopm
      wlr-randr
    ];

    stylix.targets = {
      gtk = {
        enable = true;
        flatpakSupport.enable = false;
      };
      kitty.enable = true;
      tofi.enable = true;
    };

    gtk.iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    programs.kitty = {
      enable = true;
      font.size = lib.mkForce 10;
    };

    programs.tofi = {
      enable = true;
      settings = {
        horizontal = true;
        height = "5%";
        border-width = 3;
        outline-width = 0;
        prompt-padding = 10;
        result-spacing = 20;
        corner-radius = 10;
        anchor = "top";
        padding-top = 2;
        width = "99%";
        clip-to-padding = true;
        margin-top = "1%";
      };
    };
  };
}
