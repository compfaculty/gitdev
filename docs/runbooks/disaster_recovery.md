# Disaster recovery checklist

Aligned with PRD objectives RPO≤15 min (backup cadence configurable) / RTO≤4 h.

## Backups GitLab Omnibus

Nightly Omnibus cron job created by Ansible role pushes artifacts into `/var/opt/gitlab/backups` (mirror to immutable object storage externally — integrate S3/Backblaze separately).

Smoke restore (LAB):

```bash
# On fresh VM restored from snapshots + Omnibus reinstall matching version pins
scp backup.tar gitlab-vm:/var/opt/gitlab/backups/
gitlab-backup restore BACKUP=timestamp_gitlab_backup.tar
gitlab-ctl reconfigure
gitlab-ctl restart
```

## Runner rebuild

Machines ephemeral; rerun:

```bash
ansible-playbook infra/ansible/playbooks/runners.yml --ask-vault-pass -i inventory/prod.yml
```

Terraform reprovision if metadata lost:

```bash
terraform -chdir=infra/terraform/environments/prod apply
```

## Verification matrix

| Test | Frequency | Expected |
|------|-----------|---------|
| Git push over VPN | Monthly | Signed commit merges |
| CI job fetch internal registry asset | Quarterly | Artifact digest unchanged |
| Terraform plan clean | Weekly | No drift |

## Cold site warm standby (optional)

Terraform module duplication for secondary project + rsync object storage recommended for advanced posture.

## Performance / cost

Full Git restore bandwidth bound by object storage throughput O(backup size).
