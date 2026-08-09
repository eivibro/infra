{
  inputs,
  lib,
  ...
}: {
  imports = ["${inputs.files}/flake-module.nix"];

  config = {
    flake-file.inputs.files = {
      url = "github:mightyiam/files";
      flake = false;
    };

    perSystem = psArgs: {
      options.text = lib.mkOption {
        default = {};
        type = lib.types.lazyAttrsOf (
          lib.types.oneOf [
            (lib.types.separatedString "")
            (lib.types.submodule {
              options = {
                parts = lib.mkOption {
                  type = lib.types.lazyAttrsOf lib.types.str;
                };
                order = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                };
              };
            })
          ]
        );
        apply = lib.mapAttrs (
          name: text:
            if lib.isAttrs text
            then
              lib.pipe text.order [
                (map (lib.flip lib.getAttr text.parts))
                lib.concatStrings
              ]
            else text
        );
      };

      config = {
        #treefmt.settings.global.excludes = lib.attrNames psArgs.config.files.file;
        files.writer.app = true;
      };
    };
  };
}
