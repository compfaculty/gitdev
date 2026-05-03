#!/usr/bin/env bash
#
# Apply baseline security knobs via GitLab Admin API after first Omnibus converge.
#
# Prerequisites:
#   export GITLAB_URL="https://10.0.1.10"   # reachable over VPN — trust TLS or add -k
#   export GITLAB_ROOT_TOKEN="$(pass path/to/admin_pat)" # personal access token, api scope OR OAuth token
#
# Complexity: one REST round-trip per PATCH; negligible vs operator time.
set -euo pipefail

: "${GITLAB_URL:?}"
: "${GITLAB_ROOT_TOKEN:?}"

api() {
  curl -fsS -H "PRIVATE-TOKEN: ${GITLAB_ROOT_TOKEN}" -H "Content-Type: application/json" "$@"
}

api -X PATCH "${GITLAB_URL}/api/v4/application/settings" \
  --data "{\"shared_runners_enabled\": false, \"require_two_factor_authentication\": true}"

echo "Applied baseline application settings scaffold — extend with signing enforcement / SSO-only flags per policy."
