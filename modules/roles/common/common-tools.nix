{
  flake.modules.nixos.common = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      curl
      git
	  htop
      neovim
      tmux
      tree
	  unzip
      wget
    ];
  };
}
