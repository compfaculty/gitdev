# Upstream version verification log

This file captures **point-in-time checks** against public registries. **Re-run quarterly** or before every production promote.

| Check time (UTC) | Source | Finding |
|-----------------|--------|---------|
| 2026-05-03 | [GitHub terraform releases API](https://api.github.com/repos/hashicorp/terraform/releases/latest) | Latest tag **`v1.15.1`** → CI image updated to **`hashicorp/terraform:1.15`**. |
| 2026-05-03 | [Terraform Registry hetznercloud/hcloud versions](https://registry.terraform.io/v1/providers/hetznercloud/hcloud/versions) | Newest listed **`1.59.0`** → provider constraint **`~> 1.59`**. |
| 2026-05-03 | [PyPI ansible-core](https://pypi.org/pypi/ansible-core/json) | **`2.20.5`** → CI range **`>=2.17,<2.21`**. |
| 2026-05-03 | Parsed `gitlab-ce` **`Packages.gz`** ([noble amd64 channel](https://packages.gitlab.com/gitlab/gitlab-ce/ubuntu/dists/noble/main/binary-amd64/Packages.gz)) | Newest Debian revision **`18.11.2-ce.0`** — reflected in Ansible **`gitlab_ce_apt_pin_version`**. |
| 2026-05-03 | Parsed `gitlab-runner` **`Packages.gz`** ([runner noble amd64](https://packages.gitlab.com/runner/gitlab-runner/ubuntu/dists/noble/main/binary-amd64/Packages.gz)) | Newest **`18.11.2-1`** → **`gitlab_runner_apt_pin_version`**. |
| 2026-05-03 | [GitLab API tags (core project)](https://gitlab.com/api/v4/projects/278964/repository/tags) | Tracks upstream EE tag stream (e.g. **`v18.11.2-ee`**); CE OmniBus DEBs follow same minor line. |
| 2026-05-03 | [GitHub headscale releases API](https://api.github.com/repos/juanfont/headscale/releases/latest) | Latest **`v0.28.0`** → Compose image **`headscale/headscale:0.28`**. |

## What this repo does **not** pin

- **GitLab CE / Runner** — default **`apt latest`** (or optional pin). **Operational “non-vulnerable”** = follow [GitLab security releases](https://about.gitlab.com/releases/categories/security/) and run **`patch_critical_stack.yml`** with an advisory-cited DEB revision.
- **Host kernel / hypervisor** — Hetzner-maintained; subscribe to their advisories.

## Quick re-check commands

```bash
./scripts/check-upstream-versions.sh
curl -fsSL https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r .tag_name
```

## Non-guarantee

Registry and API responses **change daily**. This is **not** a substitute for GitLab Dependency Scanning, container image scanners, or distro security mailing lists.
