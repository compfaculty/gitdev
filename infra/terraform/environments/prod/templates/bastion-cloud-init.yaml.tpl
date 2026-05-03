#cloud-config
package_update: true
package_upgrade: true
packages:
  - wireguard
  - nftables
  - unattended-upgrades
runcmd:
  - sysctl -w net.ipv4.ip_forward=1
