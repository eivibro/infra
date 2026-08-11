{inputs, ...}: {
  flake.modules.homeManager.graphical = {
    imports = [
      inputs.self.modules.homeManager.libreoffice
    ];
  };

  flake.modules.homeManager.libreoffice = {pkgs, ...}: {
    home.packages = with pkgs; [
      hunspell
      hunspellDicts.nb_NO
      libreoffice-qt
    ];
  };
}
