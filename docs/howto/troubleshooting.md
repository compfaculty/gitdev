# Troubleshooting operators’ guide

## Terraform state lock stuck

Symptom: `Error acquiring the state lock` with lock ID UUID.

Remediation:

```bash
cd infra/terraform/environments/prod
terraform force-unlock <LOCK_ID>
```

Only run after verifying no teammate has an active apply. Prefer **avoid** force-unlock in automation; escalate in chat/OOB channel first.

Complexity: O(1) API call — risks split-brain apply if abused.

---

## Terraform plan inconsistent after drift

Symptom: repeated unexpected changes across runs.

Steps:

```bash
terraform -chdir=infra/terraform/environments/prod refresh -refresh-only -input=false
terraform -chdir=infra/terraform/environments/prod plan
```

If unmanaged resources leaked: import or `terraform state rm` with architecture review approval.

---

## GitLab Runner registration failures

Symptoms:

- `POST /runners/register` forbidden / HTTP 403.
- `gitlab-runner register` exits non-zero despite correct URL.

Remediation:

| Cause | Fix |
|-------|-----|
| Token typo / vaulted wrong file | Rotate registration token GitLab UI → Ansible vault `vault_gitlab_runner_registration_token` |
| `creates=` guard refuses re-register | Remove `/etc/gitlab-runner/config.toml` on runner or use `unregister` CLI then re-playbook |
| URL mismatch HTTPS cert | Align `gitlab_external_url` (`group_vars/all.yml`) with reachable GitLab SAN |
| Firewall blocks egress from CI subnet | Confirm Hetzner firewall allows outbound TCP443 from runners + GitLab allows runner IP subnet |

Verify from runner VM:

```bash
curl -skI "https://${GITLAB_IP}/-/health"
gitlab-runner verify
```

---

## VPN identity / WireGuard drift

Symptoms:

- Handshakes stale (`wg show` last handshake never updates).
- Office IP changed but WG allowlist stale.

Remediation:

1. Update `vpn_ingress_allowlist` / `ssh_bootstrap_allowlist` in `terraform.tfvars`, terraform apply bastion SG only if separated (here: full stack).
2. On bastion reload WireGuard role:
   ```bash
   ansible-playbook infra/ansible/playbooks/bastion.yml --ask-vault-pass -l bastion --diff
   ```
3. Rotate peer keys if suspicion of compromise: regenerate client keys, revoke old `PublicKey` from `bastion_wireguard/templates/wg0.conf.j2` peer list.

Emergency fallback documented in **[auth_security_setup.md](auth_security_setup.md)** break-glass.

---

## Scheduled Terraform drift fails (missing variables)

Ensure scheduled pipelines expose the same **`TF_VAR_*`** surface as developer laptops (typically `TF_VAR_ssh_public_key` plus non-secret sizing). Guidance: **[ci_pipeline_variables.md](ci_pipeline_variables.md)**.

---

## Omnibus converge failures

Tail logs:

```bash
gitlab-ctl tail
journalctl -u gitlab-runsvdir -xe
```

Common first-run OOM GitLab oversized `server_type` — scale via Terraform `gitlab_server_type` before re-running Ansible converge.
