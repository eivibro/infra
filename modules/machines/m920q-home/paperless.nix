{
  # Paperless-ngx on this machine, taking over from the container on the
  # Arch box.
  #
  # Imported by m920q-home.nix. It listens on 127.0.0.1:28981, and
  # services-proxy.nix sends paperless.brox.tech there. The Arch container
  # is still on :8001 and is no longer behind that name.
  #
  # The container could be reached by address but not logged into through
  # https://paperless.brox.tech. Since Django 4.0 an unsafe request — the login
  # POST — is refused unless its Origin appears in CSRF_TRUSTED_ORIGINS, and
  # paperless fills that list from PAPERLESS_URL, which the container never
  # set. Over plain HTTP to the container's own port there is no HTTPS origin
  # to check, so the service looked healthy from the LAN and only the proxied
  # name was broken. `domain` below is what sets PAPERLESS_URL, so logging in
  # works here by virtue of the service having been told its own name.
  #
  # Documents move by copying the container's documents/originals into
  # /var/lib/paperless/consume, which re-OCRs them into this SQLite database.
  # The container's Postgres is not imported. document_importer would refuse
  # that 1.7.1 database anyway: it wants an empty instance of the same version,
  # and v3 can only be upgraded to from 2.20.15.
  flake.modules.nixos.m920qHomePaperless = {config, ...}: {
    # The scheduler's preStart reads this through systemd's credential store
    # and creates the user on first start. A later change of the file resets
    # the password; renaming PAPERLESS_ADMIN_USER leaves the old user in place.
    sops.secrets."paperless/admin-password" = {
      sopsFile = ./secrets.yaml;
      mode = "0400";
      restartUnits = ["paperless-scheduler.service"];
    };

    services.paperless = {
      enable = true;

      passwordFile = config.sops.secrets."paperless/admin-password".path;

      # Sets PAPERLESS_URL, and through it ALLOWED_HOSTS, CORS_ALLOWED_HOSTS
      # and CSRF_TRUSTED_ORIGINS. The hostname only — the module prefixes
      # https:// itself.
      domain = "paperless.brox.tech";

      # nginx here already owns every vhost, the same reasoning as Vaultwarden.
      # services-proxy.nix carries the vhost and the dnsmasq name; the module's
      # own vhost would also add a /static/ shortcut that granian serves itself
      # through whitenoise.
      configureNginx = false;

      # The module's default, written out because it is load-bearing: granian
      # listens on loopback only, so nothing of paperless is reachable without
      # passing through nginx and TLS.
      address = "127.0.0.1";

      # SQLite, which is what this option being false means. Deliberate on a
      # machine that is also the router: no second database process to run,
      # back up or upgrade, and a backup is a copy of /var/lib/paperless. The
      # cost is that writes serialise across the four paperless units, which
      # one user uploading occasionally will not notice.
      database.createLocally = false;

      settings = {
        # Tesseract's default is English alone, which would leave Norwegian
        # documents unsearchable. nixpkgs' tesseract5 ships every language
        # file, so this needs no package override.
        PAPERLESS_OCR_LANGUAGE = "nor+eng";

        # The module's own default is "admin". Set explicitly so a rebuild
        # does not grow a second account beside this one.
        PAPERLESS_ADMIN_USER = "eivbro";
      };

      # configureTika stays at its default false. It would enable both Tika and
      # Gotenberg, which are only reached for Office documents and for
      # rendering HTML .eml files — not for OCR, which is ocrmypdf and
      # tesseract inside the paperless package itself. Turning it on later is
      # this one line plus a redeploy, costs a JVM and a Chromium in the
      # closure, and needs nothing done to existing documents.
    };

    # nginx caps request bodies at 10m by default, and the web UI is the only
    # way documents get in. Scoped to this vhost rather than raised globally.
    # The locations."/" that services-proxy.nix generates sets only proxyPass
    # and proxyWebsockets, so these merge rather than collide.
    services.nginx.virtualHosts."paperless.brox.tech".locations."/".extraConfig = ''
      client_max_body_size 100m;
    '';
  };
}
