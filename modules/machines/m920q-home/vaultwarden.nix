{
  # Vaultwarden, taking over from the container on the Arch box.
  #
  # Migrated by exporting the vault from the browser extension and importing
  # into a fresh account here, rather than by copying the SQLite database. That
  # avoids the database snapshot going stale, and avoids config.json — which
  # Vaultwarden writes when settings are changed through its admin page, and
  # which silently overrides the environment variables set below.
  #
  # Note that an export carries logins, cards, identities, notes, folders,
  # custom fields and TOTP secrets, but not file attachments, per-item password
  # history, Sends, or trash.
  flake.modules.nixos.m920qHomeVaultwarden = {config, ...}: {
    sops.secrets."vaultwarden/env" = {
      sopsFile = ./secrets.yaml;

      # Read by systemd as EnvironmentFile before privileges are dropped, so
      # this stays root-owned rather than being handed to the service user.
      mode = "0400";
      restartUnits = ["vaultwarden.service"];
    };

    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";

      # nginx here already owns every vhost; letting this module write its own
      # would mean two places deciding how it is served.
      configureNginx = false;

      environmentFile = config.sops.secrets."vaultwarden/env".path;

      config = {
        # Must match the URL actually used, or the web vault misbehaves and
        # WebAuthn refuses to enrol. Points at the temporary hostname while the
        # old instance still owns vaultwarden.brox.tech; both this and the vhost
        # change together at cutover.
        DOMAIN = "https://vault-new.brox.tech";

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;

        # The account is created once through the admin page, which is what
        # ADMIN_TOKEN in the environment file is for.
        SIGNUPS_ALLOWED = false;

        # A password hint is a hint to anyone who can ask for it, not just to
        # the owner.
        SHOW_PASSWORD_HINT = false;
      };

      # Periodic SQLite snapshots. Same disk as the live database, so this
      # guards against corruption and mistakes rather than hardware — the
      # offsite copy to the m920q at the parents' house is the real answer.
      backupDir = "/var/backup/vaultwarden";
    };
  };
}
