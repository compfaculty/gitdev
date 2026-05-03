# OIDC enablement checklist (Omnibus CI template)

When setting `gitlab_oidc_enabled: true` in `group_vars/gitlab.yml`:

1. **Issuer URL** — TLS valid, discovery document reachable from GitLab VM (outbound 443).
2. **Redirect URI** — register `(external_url without trailing slash)/users/auth/openid_connect/callback`.
3. **Client** — confidential client; vault `vault_gitlab_oidc_client_id` / `vault_gitlab_oidc_client_secret`.
4. **Claims** — IdP returns `sub`, `email`; map groups in GitLab EE or use username provisioning policy.
5. **Break-glass** — keep one local root path until SSO burn-in completes.

Re-run `ansible-playbook ... playbooks/gitlab.yml` then **`gitlab-ctl reconfigure`**.
