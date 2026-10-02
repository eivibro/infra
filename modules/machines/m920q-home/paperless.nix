{
  # Paperless-ngx, taking over from the container on the Arch box.
  #
  # NOT YET LIVE. This file is deliberately not imported by m920q-home.nix,
  # and services-proxy.nix still points paperless.brox.tech at the container
  # on the Arch box. Going live is those two edits together — the import line
  # and the proxied entry — never one without the other, or the vhost proxies
  # to a port nothing listens on.
  #
  # What is blocking: nixpkgs' paperless-ngx depends unconditionally on
  # sentence-transformers, hence torchaudio, hence torchcodec 0.16.0, whose
  # test suite fails eight mp3 encoder cases on the pinned nixpkgs
  # (b6c8664de9b6, 2026-09-29). Not local and not in the binary cache —
  # Hydra fails it identically. Upstream already fixed it twice over, in
  # NixOS/nixpkgs#568426 (skip the failing test, merged 2026-09-30) and
  # #568668 (0.17.0, merged 2026-10-01), but neither has reached the
  # nixpkgs-unstable channel yet: as of 2026-10-02 that channel is still at
  # the very revision pinned here, so `nix flake update nixpkgs` is a no-op.
  # Re-check the channel, update the pin, then flip the two lines.
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
  # Migrated with document_exporter and document_importer rather than by
  # copying the database. The export is a JSON manifest plus the files, which
  # is what allowed the container's PostgreSQL to become SQLite here. Two
  # things about that route are worth not rediscovering: the importer wants an
  # otherwise empty instance, and it refuses an export written by a different
  # version of paperless — which is why the container had to be walked from
  # 1.7.1 up to this version before exporting, by way of 2.20.15, because v3
  # can only be upgraded to from 2.20.15.
  flake.modules.nixos.m920qHomePaperless = {
    services.paperless = {
      enable = true;

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
