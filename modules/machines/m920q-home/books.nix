{
  # Read-only WebDAV for KOReader, served from disk rather than proxied to a
  # backend. The built-in ngx_http_dav_module only adds the writing verbs
  # (PUT, DELETE, MKCOL, COPY, MOVE), which this share deliberately refuses;
  # PROPFIND and OPTIONS, which KOReader actually needs to list and discover
  # the collection, come from the nginx-dav-ext-module instead.
  flake.modules.nixos.m920qHomeBooks = {
    config,
    pkgs,
    ...
  }: {
    services.nginx.additionalModules = [pkgs.nginxModules.dav];

    sops.secrets."books/htpasswd" = {
      sopsFile = ./secrets.yaml;

      # nginx reads this itself, so it must be readable by that user rather
      # than only by root.
      owner = "nginx";
      group = "nginx";
      mode = "0400";
      restartUnits = ["nginx.service"];
    };

    services.nginx.virtualHosts."books.brox.tech" = {
      useACMEHost = "brox.tech";
      forceSSL = true;

      locations."/" = {
        root = "/var/lib/books";
        basicAuthFile = config.sops.secrets."books/htpasswd".path;

        extraConfig = ''
          dav_ext_methods PROPFIND OPTIONS;
          autoindex on;
          charset utf-8;
        '';
      };
    };

    # The names in services-proxy.nix all proxy_pass to a backend; this vhost
    # serves from disk, so it needs its own dnsmasq line.
    services.dnsmasq.settings.address = ["/books.brox.tech/192.168.80.1"];

    # Owned by the user who fills it, group nginx so the server can read it,
    # setgid so anything created below inherits that group.
    systemd.tmpfiles.rules = ["d /var/lib/books 2750 eivbro nginx -"];
  };
}
