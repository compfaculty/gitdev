# Headscale control plane (optional)

Native WireGuard in [`bastion_wireguard`](../../ansible/roles/bastion_wireguard) covers simple lab VPN.

Compose pins **`headscale/headscale:0.28`** (see **`docs/upstream_versions_log.md`**). **Headscale ≥0.28** requires Tailscale clients **≥ v1.74.0** and includes tag-identity semantics changes — review [release notes](https://github.com/juanfont/headscale/releases) before upgrading an existing datastore.

For **coordinate-plane** akin to Tailscale with self-hosted ACLs, deploy Headscale beside the bastion:

1. Install Docker CE on the bastion (same pattern as runners or reuse `infra/ansible/roles/gitlab_runner/tasks/docker.yml` tasks).
2. Copy this directory to `/opt/headscale` on the bastion as **root:root** `0644` config (review `acl.hujson`!).
3. `docker compose pull && docker compose up -d`
4. Initialise: `docker compose exec headscale headscale users create platform`
   `docker compose exec headscale headscale preauthkeys create …`

Operational security: expose **`8080` only via loopback + SSH `-L`** or Tailscale-derived mesh routing; firewall should **not** publish control API to WAN without mTLS/front proxy.
