# Supply chain patching policy

## Principles

1. **Pin by default where blast radius is high**: Omnibus CE and Runner APT versions SHOULD be pinned after each successful production upgrade until the next deliberate change.
2. **Prove in stage first** when **`infra/terraform/environments/stage`** is live.
3. **Immutable artifacts**: Compose images SHOULD use digest (`image: repo@sha256:…`) after smoke test promotion.
4. **Evidence**: every production patch MR links CVE ID + advisory URL + changelog snippet.

## MR requirements (IaC repo)

- Bump **`gitlab_ce_apt_pin_version`** / **`gitlab_runner_apt_pin_version`** in `group_vars` **or** pass **`-e`** only for tactical hotfix documented in MR.
- Attach **`terraform plan`** / **`ansible-playbook --check`** output for infra-affecting merges.

## Out of scope deferrals

Deferrals MUST record risk acceptance ticket id + expiry date ≤ 90 days unless architectural dependency exists.
