# Deploy • start • restart • destroy runbook

## Deploy (cold start)

Complexity dominated by Omnibus converge `O(download + chef phase)` (~20–45 min VM dependent).

```bash
# Network + compute
terraform -chdir=infra/terraform/environments/prod apply -auto-approve

# Baseline NFT + WG + GitLab + runners (after inventory updated)
(cd infra/ansible && ansible-playbook playbooks/hardening.yml playbooks/bastion.yml \
  playbooks/gitlab.yml playbooks/runners.yml -i inventory/prod.yml --ask-vault-pass)
```

## Start / restart services

SSH via bastion (ProxyJump):

```bash
ssh -J root@BASTION_PUBLIC root@GITLAB_PRIVATE
gitlab-ctl status
gitlab-ctl restart nginx
gitlab-runner restart
```

Terraform **does not** auto-start systemd units beyond cloud-init installs; Omnibus configures own services via `gitlab-ctl`.

## Operational refresh (Ansible converge)

Fire-and-forget push:

```bash
ansible-playbook infra/ansible/playbooks/hardening.yml -i infra/ansible/inventory/prod.yml
ansible-playbook infra/ansible/playbooks/gitlab.yml -i infra/ansible/inventory/prod.yml --ask-vault-pass
ansible-playbook infra/ansible/playbooks/runners.yml -i infra/ansible/inventory/prod.yml --ask-vault-pass
```

## Destroy (infra wipe)

Terraform removes Hetzner resources; snapshots/backups buckets must be emptied separately:

```bash
terraform -chdir=infra/terraform/environments/prod destroy -auto-approve
```

Post-destroy housekeeping:

- Invalidate runner registration tokens recorded in Ansible vault.
- Revoke SSO sessions + rotate GitLab PATs/reg tokens (if accidentally created offline).

## Scheduled drift detection

In GitLab: **Build → Pipeline schedules** → create a daily job on the default branch using the same CI file. The **`terraform_plan_drift`** job fails the pipeline when `terraform plan -detailed-exitcode` reports changes (exit **2**). Wire failure notifications to your comms channel.

For lock / runner / VPN operational bugs see **[troubleshooting.md](troubleshooting.md)**.
