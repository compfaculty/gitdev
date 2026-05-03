# Terraform environments — promotion ladder

This repo uses **EU / Hetzner–first** compute. Operational promotion path:

| Tier | Folder | Intended use |
|------|--------|----------------|
| `prod/` | current full stack (`main.tf`) | authoritative platform |
| [`stage/`](stage/) | full parallel stack (`10.10.0.0/16`) smaller types | rehearsal / pre-prod |
| `dev/` *(optional)* | single runner + tiny cx22 GitLab POC | ephemeral developer sandboxes |

**Fire-and-forget rule:** MR merges to default branch kick GitLab Pipeline:

1. Validate (`terraform validate`, `ansible --syntax-check`)
2. Branch / MR `terraform plan`
3. Manual guarded `terraform apply` on protected default branch artifact
4. **Schedule** nightly `terraform_plan_drift` to fail pipeline on unexpected diff (wired in [`infra/ci/terraform.gitlab-ci.yml`](../../ci/terraform.gitlab-ci.yml))

Promotion pattern: terraform workspace **or** separate state file per folder — duplicate `prod` into `stage` when needed; keep module versions pinned identically across folders.
