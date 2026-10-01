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
  flake.modules.nixos.m920qHomeVaultwarden = {
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";

      # nginx here already owns every vhost; letting this module write its own
      # would mean two places deciding how it is served.
      configureNginx = false;

      config = {
        # Must match the URL actually used, or the web vault misbehaves and
        # WebAuthn refuses to enrol.
        DOMAIN = "https://vaultwarden.brox.tech";

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;

        # Closes public registration. The admin page that would invite new
        # accounts is disabled too — no ADMIN_TOKEN reaches the service
        # environment, which is what Vaultwarden gates the page on — so this
        # instance currently has no way to create an account at all. That is
        # deliberate with a single user, and it also keeps the admin UI from
        # writing the config.json described above.
        #
        # The token itself is kept, still encrypted, as vaultwarden/env in
        # secrets.yaml. To add an account later, restore the two things this
        # module no longer has — a sops.secrets."vaultwarden/env" entry and an
        # environmentFile pointing at it — then deploy, invite the address at
        # /admin, and register that same address at /#/signup. With no SMTP the
        # invite
        # sends no mail, it only creates the invited row that makes the signup
        # legal. Do not reach for DISABLE_ADMIN_TOKEN; it bypasses the password
        # rather than disabling the page.
        SIGNUPS_ALLOWED = false;

        # A password hint is a hint to anyone who can ask for it, not just to
        # the owner.
        SHOW_PASSWORD_HINT = false;
      };
    };
  };
}
