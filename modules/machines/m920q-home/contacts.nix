{
  # CardDAV and CalDAV for phone sync, replacing a Nextcloud that was far more
  # machinery than storing 160 contacts warrants.
  #
  # Radicale keeps each contact as a plain vCard file on disk — no database, no
  # PHP — which is both the reason it is light enough to sit on the router and
  # the reason backing it up is a matter of copying a directory.
  flake.modules.nixos.m920qHomeContacts = {
    config,
    lib,
    pkgs,
    ...
  }: {
    # bcrypt below is only honoured if that package is in Radicale's closure.
    # It is a declared dependency in nixpkgs today, but nothing about this
    # configuration would notice if that changed: logins would simply start
    # failing after a flake update, with the service itself running happily.
    # Fail the build instead. Both attribute names are checked because nixpkgs
    # has moved Python dependencies between them before.
    assertions = [
      {
        assertion = let
          declared =
            (pkgs.radicale.dependencies or [])
            ++ (pkgs.radicale.propagatedBuildInputs or []);
        in
          lib.any (dep: lib.hasInfix "bcrypt" (dep.name or "")) declared;

        message = ''
          Radicale is configured for bcrypt password hashing, but bcrypt is not
          among its declared dependencies in this nixpkgs. Either add it to the
          package or set htpasswd_encryption to sha512, which needs nothing
          beyond the standard library.
        '';
      }
    ];

    sops.secrets."radicale/htpasswd" = {
      sopsFile = ./secrets.yaml;

      # Radicale reads this itself, so it must be readable by that user rather
      # than only by root.
      owner = "radicale";
      group = "radicale";
      mode = "0400";
      restartUnits = ["radicale.service"];
    };

    services.radicale = {
      enable = true;

      settings = {
        # Bound to loopback: nginx terminates TLS and proxies in, so there is
        # no reason for this to be reachable directly.
        server.hosts = "127.0.0.1:5232";

        auth = {
          type = "htpasswd";
          htpasswd_filename = config.sops.secrets."radicale/htpasswd".path;

          # Radicale only offers bcrypt when the bcrypt package is in its
          # closure, which the pinned nixpkgs provides. Generate the line with:
          #   nix shell nixpkgs#apacheHttpd -c htpasswd -B -n <user>
          htpasswd_encryption = "bcrypt";
        };

        storage.filesystem_folder = "/var/lib/radicale/collections";
      };
    };
  };
}
