# GitLab Runner network isolation (dedicated CI namespace pattern)

## Objective

Runners sit in `ci_subnet` (`10.0.2.0/24`) with:

- **No inbound** from internet (Hetzner firewall module enforces).
- **SSH only** from `mgmt_subnet` for Ansible.
- **Egress** default allow today for package pulls; tighten with host `nftables` forward policy + explicit allowlist to:

| Destination class | Example |
|-------------------|---------|
| GitLab HTTPS API | `https://10.0.1.10` (private) |
| Internal mirrors | Artifactory / apt proxy |
| DNS | Internal recursive resolver |
| CVE feeds (optional) | Signed mirror only |

### Host-level option (Ansible)

[`common_baseline`](../../infra/ansible/roles/common_baseline) supports **`runner_strict_output_egress: true`** with:

- `runner_egress_dns_ipv4_list`
- `runner_egress_https_ipv4_list` (must include GitLab + registries / mirrored CIDR tuples)

Defaults keep **`runner_strict_output_egress: false`** for first boots; flip in `group_vars/runners.yml` only after mirror analysis.

Implementation sketch ( nftables `output` hook ):

```
chain output {
    type filter hook output priority filter; policy drop;
    ct state established,related accept
    oifname "lo" accept
    udp dport 53 ip daddr { 1.1.1.1, 9.9.9.9 } accept
    tcp dport 443 ip daddr { 10.0.1.10, corporate-mirror } accept
}
```

## Kubernetes / systemd-nspawn escalation path

Teams operating at mature purple maturity should graduate runners to ephemeral VMs per job (Firecracker / QEMU) pinned via `gitlab-runner` executor `custom` wrappers.

Performance: enforcing forward filtering adds O(1) per packet vs raw forwarding.
