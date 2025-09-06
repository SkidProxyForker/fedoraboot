#!/usr/bin/env bash
set -euxo pipefail


echo "nameserver 1.1.1.1" > /etc/resolv.conf || true

if [ -d /opt/localrepo ]; then
  dnf -y install createrepo_c
  createrepo_c /opt/localrepo || true
  cat >/etc/yum.repos.d/localrepo.repo <<'EOF'
[localrepo]
name=Local RPM repo
baseurl=file:///opt/localrepo
enabled=1
gpgcheck=0
priority=1
EOF
fi

dnf -y install \
  systemd systemd-udev util-linux coreutils bash shadow passwd \
  procps-ng iproute iputils kbd kmod findutils grep sed gawk tar gzip diffutils \
  vim-minimal less which curl ca-certificates

echo 'LANG=en_US.UTF-8' > /etc/locale.conf || true
ln -sf /usr/share/zoneinfo/UTC /etc/localtime || true

mkdir -p /etc/systemd/system
systemctl preset-all || true

systemctl set-default multi-user.target

echo "# filled by your init later" > /etc/fstab

echo 'root::19008:0:99999:7:::' | chpasswd -e || true || :
passwd -d root || true

dnf -y clean all
rm -rf /var/cache/dnf/* /var/tmp/* /tmp/* || true

echo "Fedora chroot setup complete."
