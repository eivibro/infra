{
  # The wildcard certificate that currently lives on pfSense, for the handful
  # of services reached by name on the LAN. DNS-01 because none of them are
  # published to the internet, so there is no inbound path for HTTP-01.
  flake.modules.nixos.m920qHomeCertificates = {config, ...}: {
    sops.secrets = {
      "namecheap/api-user".sopsFile = ./secrets.yaml;
      "namecheap/api-key".sopsFile = ./secrets.yaml;
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "eivbro@gmail.com";

      certs."brox.tech" = {
        # One wildcard rather than a certificate per name: Let's Encrypt counts
        # certificates per set of names, and six subdomains would otherwise eat
        # the rate limit on every reissue.
        domain = "*.brox.tech";

        dnsProvider = "namecheap";

        # credentialFiles strips the _FILE suffix and hands lego
        # NAMECHEAP_API_USER and NAMECHEAP_API_KEY through systemd credentials,
        # so the values never reach a unit's environment or the store.
        credentialFiles = {
          NAMECHEAP_API_USER_FILE = config.sops.secrets."namecheap/api-user".path;
          NAMECHEAP_API_KEY_FILE = config.sops.secrets."namecheap/api-key".path;
        };

        # REMOVE ONCE A CERTIFICATE HAS ACTUALLY ISSUED. Production allows five
        # duplicate certificates a week, which a misconfigured DNS provider
        # will exhaust before the configuration is right. A staging
        # certificate is untrusted by browsers, and that is the signal the
        # whole chain worked: API accepted, TXT record propagated, cert issued.
        server = "https://acme-staging-v02.api.letsencrypt.org/directory";

        # group stays at its default until nginx exists to consume this; it
        # then becomes "nginx" so the proxy can read the key.
      };
    };
  };
}
