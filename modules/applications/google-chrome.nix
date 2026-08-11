{
  flake.modules.homeManager.googleChrome = {pkgs, ...}: {
    home.packages = [pkgs.google-chrome];
  };
}
