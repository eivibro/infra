{inputs, ...}: {
  flake-file.inputs.nur.follows = "stylix/nur";

  flake.modules.homeManager.graphical = {
    imports = [
      inputs.self.modules.homeManager.firefox
    ];
  };

  flake.modules.homeManager.firefox = {pkgs, ...}: let
    firefoxAddons =
      inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee.firefox-addons;
  in {
    stylix.targets.firefox = {
      enable = true;
      profileNames = ["default"];
      colorTheme.enable = true;
    };

    programs.firefox = {
      enable = true;

      nativeMessagingHosts = [
        pkgs.gnome-browser-connector
        pkgs.tridactyl-native
      ];

      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;

        settings = {
          "browser.startup.homepage" = "https://duckduckgo.com";
          "extensions.autoDisableScopes" = 0;
          "gfx.font_rendering.fontconfig.max_generic_substitutions" = 127;
          # Stylix themes Firefox's chrome, while these tell web content that
          # the system's preferred color scheme is dark.
          "layout.css.prefers-color-scheme.content-override" = 0;
          "ui.systemUsesDarkTheme" = 1;
        };

        extensions = {
          force = true;
          packages = with firefoxAddons; [
            ublock-origin
            bitwarden
            privacy-badger
            clearurls
            decentraleyes
            duckduckgo-privacy-essentials
            sponsorblock
            unpaywall
            h264ify
            tridactyl
          ];
        };

        bookmarks = {
          force = true;
          settings = [
            {
              name = "Home Assistant intents";
              url = "https://github.com/home-assistant/intents/tree/main/tests/en";
            }
            {
              name = "NixOS Guide";
              url = "https://github.com/mikeroyal/NixOS-Guide#nixos-developer-resources";
            }
            {
              name = "Getting inputs to modules in flakes";
              url = "https://blog.nobbz.dev/2022-12-12-getting-inputs-to-modules-in-a-flake/";
            }
            {
              name = "Lading plass 47";
              url = "https://lading.fjordkraft.no";
            }
            {
              name = "NixOS options";
              url = "https://mynixos.com/";
            }
            {
              name = "NetworkManager to Nix";
              url = "https://github.com/Janik-Haag/nm2nix";
            }
            {
              name = "Running non-NixOS binaries";
              url = "https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos/522823#522823";
            }
          ];
        };
      };
    };
  };
}
