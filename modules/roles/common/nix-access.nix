{
  flake.modules.nixos.common = {
    nix.settings.trusted-users = [
      "eivbro"
    ];
  };
}
