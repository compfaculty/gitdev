# Secure Red/Blue Development Platform — Infra-as-a-Service

Self-hosted GitLab footprint on **Hetzner Cloud (EU-first)** using **Terraform + Ansible**. Designed for abusive-hostile-threat models: **minimal public ingress**, privileged access over **VPN (WireGuard/Headscale-compatible Ansible role)**, **hardware-backed SSO policy**, isolated GitLab Runner tiering, reproducible IaC pipelines.

> **Operational warning:** Narrow `vpn_ingress_allowlist` + `ssh_bootstrap_allowlist` before any production traffic. Leaving `0.0.0.0/0` on WireGuard exposes operator endpoints to brute-force churn.

---

## Repo map

| Path | Purpose |
|------|---------|
| [`infra/terraform`](infra/terraform) | Hetzner modules + **`environments/prod`** and **`environments/stage`** |
| [`infra/ansible`](infra/ansible) | Hardening, WireGuard bastion skeleton, Omnibus GitLab, GitLab Runner + Docker executor |
| [`infra/ci/terraform.gitlab-ci.yml`](infra/ci/terraform.gitlab-ci.yml) | Terraform: `fmt/validate/plan`, manual `apply`, **scheduled drift** job |
| [`infra/ci/ansible.gitlab-ci.yml`](infra/ci/ansible.gitlab-ci.yml) | Ansible playbook **syntax-check** (converge from CI needs VPN-runner) |
| [`infra/terraform/modules/ingress_edge`](infra/terraform/modules/ingress_edge) | Optional CDN-allowlisted HTTPS edge (`enable_ingress_edge`) |
| [`platform/policies`](platform/policies) | Branch protections, MFA/OIDC/Yubi guidance, signing policy |
| [`docs`](docs) | Quickstart & runbooks aligned with staged delivery plan |
| [`infra/compose/headscale`](infra/compose/headscale) | Optional Headscale coordinator (Compose reference) |
| [`scripts/gitlab-bootstrap-api.example.sh`](scripts/gitlab-bootstrap-api.example.sh) | Bootstrap shared runners OFF + 2FA scaffold via GitLab API |
| [**`security_patching_and_cves`**](docs/howto/security_patching_and_cves.md) | Omnibus/runner pinning + **`patch_critical_stack.yml`** hotfix playbook |
| [**`upstream_versions_log`**](docs/upstream_versions_log.md) | Dated registry/API checks Terraform / Ansible / Headscale |
| [**GitLab DEB pins**](docs/gitlab_recommended_versions_current.md) | OmniBus CE + Runner versions for Ubuntu **noble** (today’s APT scrape) |

---

## Architecture (summary)

```
Operator(YubiKey) --WireGuard(+IdP SSO)--> bastion(+Headscale-compatible)
                                             |
                                             +--> GitLab Omnibus (private HTTPS)
                                                      |
                                                      +--> Runners(ci_subnet, docker executor)
```

- **Firewalling:** Terraform `hcloud_firewall` restricts GitLab ingress to RFC1918 management + CI ranges.
- **DDoS posture:** Primary control plane hides behind VPN; only bastion WG/SSH faces limited public IPs.
- **Backups:** Cron-driven Omnibus backup hook (mirror off-host object storage yourselves).

---

## Quickstart

Detailed flow: **[`docs/howto/quickstart.md`](docs/howto/quickstart.md)**

```bash
# 1) Terraform
cp infra/terraform/environments/prod/terraform.tfvars.example infra/terraform/environments/prod/terraform.tfvars
export HCLOUD_TOKEN=***   # NEVER commit / log
make terraform-plan && make terraform-apply

# Capture inventory snippet
(cd infra/terraform/environments/prod && terraform output ansible_inventory_snippet)

# 2) Secrets for Ansible / WireGuard / GitLab
cp infra/ansible/group_vars/vault.yml.example infra/ansible/group_vars/vault.yml
ansible-vault encrypt infra/ansible/group_vars/vault.yml

# 3) Ansible (after fixing inventory + Vault secrets)
ansible-playbook -i infra/ansible/inventory/prod.yml infra/ansible/playbooks/hardening.yml infra/ansible/playbooks/bastion.yml --ask-vault-pass
ansible-playbook -i infra/ansible/inventory/prod.yml infra/ansible/playbooks/gitlab.yml --ask-vault-pass
ansible-playbook -i infra/ansible/inventory/prod.yml infra/ansible/playbooks/runners.yml --ask-vault-pass
```

---

## Operational commands

See **[`docs/howto/deploy_start_destroy.md`](docs/howto/deploy_start_destroy.md)** — deploy, restart, converge, teardown.

Terraform destroy wipes all resources created by prod stack:

```bash
make terraform-destroy
```

---

## Authentication & continuity

Operational recipe (Tailscale vs Headscale, OIDC SSO, MFA, signed commits):

- **[`docs/howto/auth_security_setup.md`](docs/howto/auth_security_setup.md)**

Policies:

- [`platform/policies/auth/yubikey_mfa_oidc.md`](platform/policies/auth/yubikey_mfa_oidc.md)
- [`platform/policies/gitlab/branch_protection.md`](platform/policies/gitlab/branch_protection.md)
- [`platform/policies/signing/commit_signing_policy.md`](platform/policies/signing/commit_signing_policy.md)

---

## Runner isolation roadmap

Networking guidance for locked-down egress defaults:

- **[`docs/howto/runner_network_isolation.md`](docs/howto/runner_network_isolation.md)**

---

## CI variables (Terraform / drift schedules)

[`docs/howto/ci_pipeline_variables.md`](docs/howto/ci_pipeline_variables.md) — **`HCLOUD_TOKEN`**, **`TF_VAR_ssh_public_key`**, schedule caveats.

## Troubleshooting & handover

- **[`docs/howto/troubleshooting.md`](docs/howto/troubleshooting.md)** — Terraform lock, runner VPN, converge failures  
- **[`docs/howto/ddos_edge_pattern.md`](docs/howto/ddos_edge_pattern.md)** — optional CDN / edge in front of limited public services  
- **Usage-first docs:** quickstart, deploy/start/destroy, auth setup, troubleshooting, incident response, disaster recovery  

## Incident + DR readiness

| Doc | Covers |
|-----|--------|
| [`docs/runbooks/incident_response.md`](docs/runbooks/incident_response.md) | DDoS, runner poisoning, SSO lockouts |
| [`docs/runbooks/disaster_recovery.md`](docs/runbooks/disaster_recovery.md) | Omnibus restore + runner rebuild |
| [`docs/validation/red_blue_exercise_matrix.md`](docs/validation/red_blue_exercise_matrix.md) | Purple-team validation scenarios |

---

## GitLab CI (after platform online)

Root [`.gitlab-ci.yml`](.gitlab-ci.yml) wires Terraform validation. Required variables (protected + masked):

| Variable | Purpose |
|----------|---------|
| `HCLOUD_TOKEN` | Terraform Hetzner provider |
| Backend creds | If enabling S3-compatible remote state |

`terraform_apply` job is **manual** and requires the `terraform_plan` artifact in the **same pipeline** (merge to default branch, then trigger).

---

## Product requirements

Authoritative PRD + threat model: **[`docs/prd/platform_prd.md`](docs/prd/platform_prd.md)**

## Finish line

Operate from the concrete runbooks and how-to docs:

- [`docs/howto/quickstart.md`](docs/howto/quickstart.md)
- [`docs/howto/deploy_start_destroy.md`](docs/howto/deploy_start_destroy.md)
- [`docs/howto/auth_security_setup.md`](docs/howto/auth_security_setup.md)
- [`docs/runbooks/incident_response.md`](docs/runbooks/incident_response.md)
- [`docs/runbooks/disaster_recovery.md`](docs/runbooks/disaster_recovery.md)

---

## Complexity / performance notes

- **Terraform apply:** O(number of resources) cloud API calls; parallelizes per provider limits.
- **Ansible Omnibus:** Dominated by `gitlab-ctl reconfigure` Chef phase (single-threaded sections).
- **nftables baselines:** Per-packet O(1) classification on edge hosts.

---

## Legal / ethical use

All offensive simulation content is scoped to authorized lab workloads; mirror local laws + RoE.
