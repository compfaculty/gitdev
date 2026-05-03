# GitLab CE + Runner pins (maintained expectation)

Canonical **Ubuntu 24.04 (noble) amd64** — matches OmniBus playbook + Terraform `ubuntu-24.04` server images.

If you converge on **Debian bookworm**/other codename, scrape that distro’s Packages index instead—the **`-ce.0`** / **`-1`** suffix revisions **differ**.

Last indexed from **`packages.gitlab.com`** APT `Packages.gz` (**2026-05-03**):

| Artifact | APT version string | Notes |
|---------|---------------------|-------|
| `gitlab-ce` | **`18.11.2-ce.0`** | Includes **CVE-2026-4922**, **CVE-2026-5816**, **CVE-2026-5262**, **CVE-2025-0186**, and others patched in **`18.11.1`** per [patch release notes](https://docs.gitlab.com/releases/patches/patch-release-gitlab-18-11-1-released/); **`18.11.2`** adds further non‑security regressions/fixes ([release note](https://docs.gitlab.com/releases/patches/patch-release-gitlab-18-11-2-released/)). |
| `gitlab-runner` | **`18.11.2-1`** | Latest in runner repo for Noble on same scrape date — adjust if MR shows dependency conflicts. |

Source of truth in Ansible: **`group_vars/gitlab.yml`** + **`group_vars/runners.yml`**.

## Operational bump loop

```bash
# On a Noble GitLab/runner clone (or jq over CI):
ansible-playbook infra/ansible/playbooks/patch_critical_stack.yml -i inventory/prod.yml --ask-vault-pass
```

Re-scrape Noble indices after each GitLab advisory and widen pins in **`group_vars/*`** (+ MR changelog).
