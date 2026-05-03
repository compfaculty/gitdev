# Branch protection policy (GitLab)

## Scope

All `production` and `security-tooling` protected groups.

## Rules

1. **Default branch protection**
   - No direct pushes to `main` / `master` / `release/*`.
   - Merge method: fast-forward or merge commit with linear history only (team choice per repo).
2. **Approvals**
   - Minimum **2** approvals for platform/IaC repositories.
   - At least one approver from **CODEOWNERS** security path.
3. **Status checks**
   - Required pipeline success for `terraform plan` jobs on IaC merges.
   - Optional but recommended: secret scanning stage.
4. **Signed commits**
   - Enforce SSH or GPG signing on protected refs (mirror `platform/policies/signing/`).
5. **Tag protection**
   - Only maintainers create annotated signed tags (`v*`).
6. **Variable protection**
   - CI/CD vars marked **protected** map to environments `prod`; disable **masked** vars from logging.

## Complexity

Administrative overhead O(developers); enforcement is amortized via GitLab group templates.
