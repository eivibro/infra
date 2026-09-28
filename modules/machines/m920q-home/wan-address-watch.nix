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

      # Every command the script calls, named explicitly. A unit's PATH is not
      # the login shell's: an earlier version reached for awk, which is not in
      # NixOS's default service PATH, and the failure fell into the "no
      # address" branch and exited 0 — looking like a clean run every time.
      path = [
        pkgs.coreutils
        pkgs.curl
        pkgs.iproute2
      ];

      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "wan-address-watch";
      };

      script = ''
            set -u

            # Parsed with shell builtins rather than awk or cut, so the only
            # thing this needs on PATH is ip itself. Field 3 of -brief output
            # is the address with its prefix:
            #   wan0  UP  198.51.100.4/24  metric 1024
            set -- $(ip -4 -brief addr show wan0)
            if [ "$#" -lt 3 ]; then
              echo "wan0 has no address yet; nothing to compare"
              exit 0
            fi
            address="''${3%%/*}"

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
