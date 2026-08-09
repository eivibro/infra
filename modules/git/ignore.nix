{
  config,
  lib,
  ...
}: {
  options.git.ignore = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    apply = lib.naturalSort;
  };

  config = {
    perSystem = {
      files.file.".gitignore".text = config.git.ignore |> lib.concatLines;

      #treefmt.settings.global.excludes = ["*/.gitignore"];
    };
    git.ignore = ["/result*"];
  };
}
