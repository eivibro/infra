{
  # Warns when the upstream address changes, because certificate renewal
  # silently depends on it: Namecheap's API only answers callers whose address
  # is on an allowlist maintained by hand in their dashboard. A changed address
  # means the next renewal is refused, roughly 30 days before the certificate
  # actually expires, with nothing to announce it.
  #
  # The address is read from wan0 rather than asked of an external service.
  # What Namecheap allowlists is the source address of the API call, which is
  # wan0's address — so this measures the thing that matters rather than a
  # proxy for it.
  flake.modules.nixos.m920qHomeWanAddressWatch = {
    config,
    pkgs,
    ...
  }: let
    # ntfy topic to publish to. Subscribe to this on your phone. Posted
    # straight to the service host rather than through nginx, so an alert does
    # not depend on the proxy being healthy.
    topic = "brox-router-alerts";
  in {
    systemd.services.wan-address-watch = {
      description = "Warn when the upstream address changes";

      after = ["network-online.target"];
      wants = ["network-online.target"];

      path = [pkgs.iproute2 pkgs.curl];

      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "wan-address-watch";
      };

      script = ''
            set -u

            address=$(ip -4 -brief addr show wan0 | awk '{print $3}' | cut -d/ -f1)
            if [ -z "$address" ]; then
              echo "wan0 has no address yet; nothing to compare"
              exit 0
            fi

            state="$STATE_DIRECTORY/address"
            previous=$(cat "$state" 2>/dev/null || true)

            if [ "$address" = "$previous" ]; then
              exit 0
            fi

            # Nothing recorded yet means first run, not a change worth waking
            # anyone for.
            if [ -n "$previous" ]; then
              curl -fsS --max-time 15 \
                -H 'Title: Router WAN address changed' \
                -H 'Priority: high' \
                -H 'Tags: warning' \
                -d "$previous -> $address

        Add the new address to the Namecheap API allowlist, or renewal of the
        *.brox.tech certificate will be refused." \
                'http://${config.homeServices.host}:8085/${topic}'
            fi

            # Only recorded once the alert is away, so a failed notification is
            # retried on the next tick rather than being lost.
            printf '%s' "$address" > "$state"
      '';
    };

    systemd.timers.wan-address-watch = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "3m";
        OnUnitActiveSec = "15m";
        Persistent = true;
      };
    };
  };
}
