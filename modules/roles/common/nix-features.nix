{
  flake.modules.nixos.common = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
  };
}
