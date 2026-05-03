# Security patching — fast, repeatable CVE response

Governance complements technical steps: [**`supply_chain_patching`**](../../platform/policies/supply_chain_patching.md).

## Triage cadence

| Severity | SLA (lab suggestion) |
|----------|---------------------|
| RCE actively exploited affecting your major | Deploy within maintenance window ≤ 72 h |
| DoS without auth impacting availability | Firewall mitigations immediate; package patch ≤ 7 d |
| Informational deps | Monthly bundle |

Sources (subscribe / RSS): [GitLab security releases](https://about.gitlab.com/releases/categories/releases/#security-release), Debian/Ubuntu **USN**, Hetzner **status**, Compose image **GHSA/OSV**.

## Patch path A — Omnibus GitLab CVE

1. **Read** advisory: exact CVE range, patched **CE** Debian package version (`x.y.z-ce.0`).
2. **Snapshot** hypervisor/API VM snapshot OR at minimum successful **`gitlab-backup create`** (`SKIP` narrowing only after risk acceptance — see playbook default).
3. **Stage gate** (`stage/` stack mirror) if you maintain one — same pin version.
4. **Apply prod** pin + converge:
   ```bash
   cd infra/ansible
   ansible-playbook playbooks/patch_critical_stack.yml -i inventory/prod.yml \
     -e gitlab_ce_apt_pin_version=XX.YY.ZZ-ce.0 \
     --ask-vault-pass
   ```
5. **`gitlab-rake`** smoke: `gitlab:check`; browser login; MR pipeline sanity.
6. **Clear pin** (`gitlab_ce_apt_pin_version: ""` + `latest`) on next housekeeping window once satisfied, or retain pin until next deliberate bump.

Performance: APT + `gitlab-ctl reconfigure` is **single-host serial** bottleneck `O(bundle size)`; plan **≤30–90 min** window on large Omnibus VMs.

## Patch path B — GitLab Runner

Runner apt versions track Linux package suffixes from GitLab:

```bash
ansible-playbook infra/ansible/playbooks/patch_critical_stack.yml -i inventory/prod.yml \
  --tags runners \
  -e gitlab_runner_apt_pin_version=17.YY.ZZZ-1 \
  --skip-tags gitlab
```

Unset pin → next converge returns to **`latest`**.

## Patch path C — Host OS unattended security

Ubuntu **`unattended-upgrades`** is installed via `common_baseline`. Tune `/etc/apt/apt.conf.d/` on bastion/GitLab/runners for **`-security` origins only** to avoid accidental feature upgrades during hot week.

Complexity **O(automation scope)** vs manual apt per host.

## Patch path D — Terraform / providers / Compose

- **Terraform Hetzner provider**: bump semver ceiling in **`versions.tf`**, **`terraform init -upgrade`**, plan/apply deltas.
- **Headscale etc.**: edit [`infra/compose/headscale/docker-compose.yml`](../../infra/compose/headscale/docker-compose.yml) pinned tag → **`docker compose pull && up -d`** with maintenance note + ACL backup.

Use **`scripts/check-upstream-versions.sh`** for a quick plaintext signal for the current **gitlab-ce** Debian line (swap `PKG_INDEX_URL` for Ubuntu mirrors when your runner AMIs differ).

**Today’s OmniBus DEB targets (Ubuntu 24.04 noble amd64)** — authoritative table: **`docs/gitlab_recommended_versions_current.md`** (re-scrape APT after each advisory).

**Broader IaC toolchain pins**: **`docs/upstream_versions_log.md`**.

## Runner drain (avoid tearing active jobs)

Pause or **maintain mode** runners in GitLab UI / API before package restart, or tolerate serial restarts (`serial: 1`) during low-traffic slots.
