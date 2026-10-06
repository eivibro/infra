{
  flake.modules.homeManager.starship = {lib, ...}: {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;
        format = lib.concatStrings [
          "$hostname"
          "$directory"
          "$nix_shell"
          "$python"
          "$git_branch"
          "$git_status"
          "$direnv"
          "$line_break"
          "$character"
        ];

        nix_shell = {
          disabled = false;
          format = "via [$symbol$name]($style) ";
          symbol = "❄️ ";
        };

        python = {
          disabled = false;
          detect_extensions = ["py"];
          format = "via [$symbol$version (\\($virtualenv\\))]($style) ";
          symbol = "🐍 ";
        };

        git_branch.symbol = "";
        git_status.disabled = false;

        direnv = {
          disabled = false;
          format = "[$symbol$loaded/$allowed]($style) ";
          symbol = "direnv ";
          style = "bold orange";
          allowed_msg = "✅";
          not_allowed_msg = "⛔";
          loaded_msg = "loaded";
          unloaded_msg = "not loaded";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };
      };
    };
  };
}
