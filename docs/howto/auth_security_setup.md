# Authentication & continuity hardening setup

## 1. Tailscale vs Headscale (WireGuard-backed)

Recommended pattern:

- **Headscale** self-hosted coordination + plain WireGuard data plane keeps control fully inside perimeter.
- **Tailscale SaaS** acceptable if SOC reviews ToS/residency posture (EU-focused teams often pick Headscale on bastion VLAN).

Operational tasks:

1. Pin controller version + backup SQLite/Postgres datastore (out of scope IaC snippets here).
2. Enforce SSO device posture + disable password sharing mode.
3. Document emergency peer enrollment when primary controller degraded (alternate Headscale standby or manual static WireGuard configs with short TTL).

Configure firewall allowlists **`vpn_ingress_allowlist`** in Terraform to drop volumetric abusive UDP scans while allowing legit peers.

## 2. MFA + hardware tokens only (YubiKey)

See [`platform/policies/auth/yubikey_mfa_oidc.md`](../../platform/policies/auth/yubikey_mfa_oidc.md).

Operational checklist:

- [ ] IdP enforces FIDO2/WebAuthn for Maintainer+ cohorts.
- [ ] Backup codes disabled or locked in sealed envelope for break glass only.
- [ ] Periodic access review exporting IdP memberships vs GitLab group mapping.

Break-glass (LAB):

1. Envelope Procedure: Offline paper + Shamir shards for Omnibus emergency root SSH only after incident commander approval recorded in ticketing.

## 3. Signed commits

Follow [`platform/policies/signing/commit_signing_policy.md`](../../platform/policies/signing/commit_signing_policy.md).

Server-side acceptance:

GitLab Settings → Repository → reject unsigned commits on protected refs.

SSH signing snippet:

```bash
ssh-keygen -t ed25519 -C "$(whoami)+signing@$(hostname)"
git config gpg.format ssh
git config user.signingkey ~/.ssh/gitlab_sign.pub
git config commit.gpgsign true
```

## 4. CI credentials / IaC tokens

- Store `HCLOUD_TOKEN`, Terraform backend creds as **Masked + Protected** GitLab CI variables.
- TTL tokens where possible (`HCLOUD_TOKEN` rotate monthly).
- Use dedicated least-privilege Hetzner project + API token scopes.
