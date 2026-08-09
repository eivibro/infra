{
  flake.modules.nixos.common = {
    users.users.eivbro = {
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };
}
