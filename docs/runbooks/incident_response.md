# Incident response runbook (platform)

Use alongside GitLab outage + infra provider tickets.

## Triggers

- VPN endpoint saturation / asymmetric UDP flood.
- Abnormal outbound traffic from runners (egress anomalies).
- Mass failed Git authentications correlated with geopolitical escalation.

## Severity table

| S | Condition | Immediate action |
|---|-----------|------------------|
| SEV1 | GitLab unavailable + no DR path | Freeze Terraform applies, escalate provider DDoS, shift to mirrored backup artifact pull |
| SEV2 | Runners poisoning CI queue | Isolate runner subnets at Hetzner firewall, revoke runners |
| SEV3 | SSO misconfig lockout | Enable break glass per `auth_security_setup` |

After vendor confirms **patched Omnibus DEB** available, converge using [`patch_critical_stack.yml`](../../infra/ansible/playbooks/patch_critical_stack.yml) plus [`security_patching_and_cves.md`](../howto/security_patching_and_cves.md).

## Containment playbook

1. Snapshot affected hosts (Hetzner snapshot API or console).
2. Apply emergency firewall narrowing on bastion WG UDP allowlist (`terraform.tfvars`).
3. De-register suspicious runners GitLab UI → deactivate tokens.
4. Rotate registration tokens (`vault_gitlab_runner_registration_token`).

## Recovery validation

```bash
terraform -chdir=infra/terraform/environments/prod plan
ansible-playbook infra/ansible/playbooks/gitlab.yml --check --diff -i infra/ansible/inventory/prod.yml
gitlab-rake gitlab:check SANITIZE=true
```

## Evidence retention

Preserve:

- Omnibus `/var/log/gitlab`
- nftables counters (`nft list ruleset > incident.nft`)

## Complexity

Incident steps O(operators); forensic log correlation O(volume of audit events forwarded to SIEM).
