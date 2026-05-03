# Code signing policy

## Objectives

- Bind authorship to cryptographic identity (hardware-backed keys encouraged).
- Enable server-side rejection of tampered histories on protected branches.

## Engineer workstation

1. **SSH signing (preferred for GitLab)**
   ```bash
   git config gpg.format ssh
   git config user.signingkey ~/.ssh/signing-gitlab.pub
   git config commit.gpgsign true
   ```

2. **GPG fallback**
   - Subkey marked `Signing` stored on hardware token (`keytocard`).
   ```bash
   git config gpg.format gpg
   git config commit.gpgsign true
   ```

3. **Upload public SSH signing key**
   - GitLab → Preferences → SSH Keys → mark as signing key OR use dedicated signing-only key uploaded per policy.

## GitLab settings (group/project)

Settings → Repository → Protected branches → **Reject unsigned commits**.

## Rotation

Rotate signing keys yearly or on personnel change; revocation MR must precede disabling old keys in GitLab.

## Performance note

Signing adds negligible CPU latency vs commit time dominated by tooling.
