{
  flake.modules.nixos.common = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      curl
      git
      neovim
      tmux
      tree
      wget
    ];
  };
}
