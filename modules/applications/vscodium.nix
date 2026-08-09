{inputs, ...}: {
  flake-file.inputs.nix-vscode-extensions = {
    url = "github:nix-community/nix-vscode-extensions";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.vscodium = {pkgs, ...}: let
    marketplaceExtensions =
      inputs.nix-vscode-extensions.extensions
      .${pkgs.stdenv.hostPlatform.system}
      .vscode-marketplace;
  in {
    stylix.targets.vscodium = {
      enable = true;
      profileNames = ["default"];
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      initLua = ''
        vim.opt.relativenumber = true
        vim.opt.cursorline = true
        vim.opt.tabstop = 4
        vim.opt.shiftwidth = 4

        if vim.g.vscode then
          return
        end
      '';
    };

    programs.vscodium = {
      enable = true;
      mutableExtensionsDir = false;

      profiles.default = {
        extensions =
          (with pkgs.vscode-extensions; [
            ms-python.python
            ms-python.black-formatter
            asvetliakov.vscode-neovim
            mkhl.direnv
          ])
          ++ [marketplaceExtensions.openai.chatgpt];

        userSettings = {
          "extensions.experimental.affinity" = {
            "asvetliakov.vscode-neovim" = 1;
          };
          "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim}/bin/nvim";

          "workbench.startupEditor" = "none";

          "python.defaultInterpreterPath" = "python3";
          "python.analysis.typeCheckingMode" = "basic";
          "[python]" = {
            "editor.defaultFormatter" = "ms-python.black-formatter";
            "editor.formatOnSave" = true;
          };

          "editor.inlineSuggest.enabled" = true;
        };
      };
    };
  };
}
