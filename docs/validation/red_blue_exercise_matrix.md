# Red/blue validation matrix (Stage 6–7)

Each scenario documents expected detection + containment.

| ID | Scenario | Red action | Blue detection | Containment success criteria |
|----|----------|------------|----------------|------------------------------|
| RB-01 | Stolen CI_JOB_TOKEN | MR pipeline exfil env | GitLab audit + rate limits | Token scope limited; job fails |
| RB-02 | Malicious Terraform MR | Add open SG | plan job diff review | Manual apply gate blocks |
| RB-03 | Runner breakout | escalate container | nftables egress deny | outbound blocked / alert |
| RB-04 | Auth brute-force storm | OTP spray | SSO lockout thresholds | WG allowlist tightened |
| RB-05 | UDP volumetric WG DoS | high PPS handshake | telemetry spike | drop non-listed CIDRs |

Evidence collection: Omnibus nginx logs + provider metrics + WG handshake counters (`wg show wg0 transfer`).

## Execution cadence

- Tabletop quarterly.
- Purple technical rehearsal bi-annual.
