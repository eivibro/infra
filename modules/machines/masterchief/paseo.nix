{inputs, ...}: {
  flake-file.inputs.paseo = {
    url = "github:getpaseo/paseo";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.masterchiefPaseo = {pkgs, ...}: {
    imports = [inputs.paseo.nixosModules.default];

    services.paseo = {
      enable = true;

      # Run as the primary user so spawned agents inherit git, ssh keys and the
      # home-manager profile (claude, codex, opencode, ...). State lives in
      # /home/eivbro/.paseo.
      user = "eivbro";
      group = "users";

      # Daemon binds loopback; remote access goes through the hosted relay
      # (app.paseo.sh) which is the module default. Pair this host with the
      # Paseo app to finish setup.
      listenAddress = "127.0.0.1";
      port = 6767;
      relay.enable = true;
      relay.mode = "hosted";

      # Ship node-pty's prebuilt native addon, which upstream's packaging drops.
      #
      # Without pty.node the forked terminal worker throws on require, and every
      # terminal — and so every new worktree workspace — fails with "Terminal
      # worker is not running". nix/package.nix installs only the daemon's traced
      # runtime closure, and scripts/trace-daemon.mjs has to name the addon
      # explicitly because node-pty resolves it at runtime. That glob points at
      # node_modules/node-pty, but the bump to node-pty 1.2.0-beta.15 made npm
      # nest it under packages/server/node_modules instead, so the glob matches
      # nothing and the addon is silently left out.
      #
      # Upstream issue getpaseo/paseo#3249, fix proposed in #4954 (and #3853);
      # all three still open as of 2026-10-02, so this cannot be fixed by
      # bumping the input. The substitution below is #4954's, matching either
      # hoisting location; --replace-fail means this override breaks the build
      # loudly once upstream lands its own fix.
      package =
        inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
        (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              substituteInPlace scripts/trace-daemon.mjs \
                --replace-fail \
                  '`node_modules/node-pty/prebuilds/''${process.platform}-''${process.arch}/**`' \
                  '`{node_modules,packages/server/node_modules}/node-pty/prebuilds/''${process.platform}-''${process.arch}/**`'
            '';

          # The trace list is the only thing standing between a missing addon
          # and a daemon that looks healthy until the first terminal, so assert
          # rather than trust the glob.
          postInstall =
            (old.postInstall or "")
            + ''
              if ! find $out/lib/paseo -name pty.node -print -quit | grep -q .; then
                echo "pty.node missing from the daemon closure; terminals would fail at runtime" >&2
                exit 1
              fi
            '';
        });
    };
  };
}
