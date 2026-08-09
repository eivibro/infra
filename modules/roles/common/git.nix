{
  flake.modules.homeManager.eivbro = {
    programs.git = {
      enable = true;

      settings = {
        user = {
          name = "eivibro";
          email = "eivbro@gmail.com";
        };

        init.defaultBranch = "main";
      };
    };
  };
}

