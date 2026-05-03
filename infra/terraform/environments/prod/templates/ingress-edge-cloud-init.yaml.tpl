#cloud-config
package_update: true
package_upgrade: true
packages:
  - nginx
  - curl
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
write_files:
  - path: /var/www/html/healthz
    permissions: "0644"
    content: "ok\n"
