#install
apt -y install qemu qemu-kvm qemu-system qemu-utils \
libvirt-clients libvirt-daemon-system virtinst libguestfs-tools

#config kernel
modprobe br_netfilter

cat <<'EOF' >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
EOF

#enable and restart
sysctl -p /etc/sysctl.conf

systemctl enable libvirtd

systemctl restart libvirtd

