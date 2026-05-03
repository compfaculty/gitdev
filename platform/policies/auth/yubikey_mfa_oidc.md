# Hardware token MFA + OIDC

## Targets

Admin and Maintainer roles MUST authenticate with:

- SSO provider enforcing **FIDO2 / WebAuthn** (passkey or YubiKey).
- Fallback TOTP forbidden for Maintainer+ unless exemption approved quarterly.

## GitLab SSO (OIDC / SAML)

Configure IdP-first login for `gitlab admins` via OpenID Connect in Omnibus (`gitlab.rb` excerpt managed by Ansible vault):

```
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_providers'] = [
  # JSON export from OmniAuth-compatible provider (populate via Ansible vault)
]
```

Operational steps:

1. Create dedicated OIDC clients with short-lived confidential tokens rotated via vault automation.
2. Map IdP groups to GitLab roles (Owner/Maintainer/Developer) explicit least-privilege defaults.
3. Disable local password resets for Maintainer+ (`gitlab_force_common_password_changes` tuning per policy revision).

## Break-glass

Single-use offline root + IdP outage procedure documented in [docs/howto/auth_security_setup.md](../../docs/howto/auth_security_setup.md).

## Complexity

FIDO assertions are O(user login); IdP outages drive need for deterministic break-glass.
