# GitLab CI variables for IaC pipelines

## Required for Terraform jobs

Set as **Masked + Protected** on the IaC repo / group defaults:

| Variable | Scope | Notes |
|----------|-------|--------|
| `HCLOUD_TOKEN` | protected branches | Rotate monthly; isolate to dedicated Hetzner project |
| `TF_VAR_ssh_public_key` | pipelines without committed `terraform.tfvars` | Public key string only — never paste private halves |
| `TF_VAR_ssh_bootstrap_allowlist` | optional | Quote JSON-encoded list `"[\"203.0.113.50/32\"]"` |

## Scheduled drift detection

[`terraform_plan_drift`](../../infra/ci/terraform.gitlab-ci.yml) inherits the same Terraform context as interactive plans. Scheduled pipelines commonly miss local `terraform.tfvars`.

Pick one operational pattern:

1. **Committed non-secret sizing** (`instance types`, allowlists placeholders) checked into `infra/terraform/` while secrets stay CI-only.
2. **Inject equivalents** via `TF_VAR_*` on the Schedule owner group.
3. **Remote backend** referencing shared auto‑tfvars in secure object bucket (advanced).

Never seed fake SSH public keys purely to placate drift jobs — rotating state-associated keys is brittle.
