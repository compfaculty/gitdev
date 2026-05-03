#!/usr/bin/env bash
#
# Lightweight “what upstream calls latest” helpers — complements OSV scanning in CI/GitLab EE.
#
# Complexity: bounded HTTP GET parse O(package index window); failures are intentionally obvious.
#
set -euo pipefail

echo "=== GitLab security / release trackers (human) ==="
echo "https://about.gitlab.com/releases/categories/security/"
echo ""

echo "=== Debian packages (gitlab-ce amd64 stable index excerpt) ==="
# Bookworm aligns with ubuntu2404-era glibc lineage for quick eyeball comparisons.
PKG_URL="${PKG_INDEX_URL:-https://packages.gitlab.com/gitlab/gitlab-ce/debian/dists/bookworm/main/binary-amd64/Packages.gz}"
TMP="$(mktemp)"
trap 'rm -f "$TMP" "${TMP}.gz"' EXIT

if curl -fsSL "$PKG_URL" -o "${TMP}.gz"; then
  gzip -dc "${TMP}.gz" >"$TMP"
  awk '/^Package: gitlab-ce$/{p=1} /^Package: / && !/^Package: gitlab-ce$/{p=0}
       p && /^Version: /{print; exit}' "$TMP"
  echo "(full index: ${PKG_URL})"
else
  echo "SKIP: offline or URL blocked — set PKG_INDEX_URL to internal mirror Packages.gz."
fi

echo ""
echo "=== Operationalize ==="
echo "Pin Omnibus APT: ansible-playbook infra/ansible/playbooks/patch_critical_stack.yml ..."
echo "docs/howto/security_patching_and_cves.md"
