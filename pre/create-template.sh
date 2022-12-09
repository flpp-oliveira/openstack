
cd /var/lib/libvirt/images/

wget http://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

qemu-img resize focal-server-cloudimg-amd64.img 50G

virt-customize -a focal-server-cloudimg-amd64.img \
  --run-command 'growpart /dev/sda 1' \
  --run-command 'resize2fs /dev/sda1'

virt-customize -a focal-server-cloudimg-amd64.img \
  --timezone "America/Sao_Paulo" \
  --update --network --uninstall cloud-init \
  --root-password password:85885072 \
  --firstboot-command "dpkg-reconfigure -f noninteractive openssh-server" \
  --run-command 'sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config' \
  --run-command 'sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config'

qemu-img create -b focal-server-cloudimg-amd64.img   -f qcow2 -F qcow2 os-infra.img
qemu-img create -b focal-server-cloudimg-amd64.img   -f qcow2 -F qcow2 os-controller.img
qemu-img create -b focal-server-cloudimg-amd64.img   -f qcow2 -F qcow2 os-compute01.img
qemu-img create -b focal-server-cloudimg-amd64.img   -f qcow2 -F qcow2 os-compute02.img

#infra
cat << 'EOF' > infra-ens3-config.yaml
network:
  version: 2
  ethernets:
    enp1s0:
      addresses:
         - 192.168.123.10/24
      gateway4: 192.168.123.1
      nameservers:
        search: [openstack.local]
        addresses: [192.168.123.10, 8.8.8.8]
EOF

virt-customize -a /var/lib/libvirt/images/os-infra.img \
  --hostname infra.openstack.local \
  --upload infra-ens3-config.yaml:/etc/netplan/ens3-config.yaml

virt-install --name=os-infra \
  --import --disk path=/var/lib/libvirt/images/os-infra.img,format=qcow2 \
  --ram=2048 --vcpus=2 --os-variant=ubuntu20.04 \
  --network network=mgmt-net,model=virtio \
  --graphics vnc,listen=0.0.0.0 --noautoconsole

#controller
cat << 'EOF' > controller-ens3-config.yaml
network:
  version: 2
  ethernets:
    enp1s0:
      addresses:
        - 192.168.123.11/24
      gateway4: 192.168.123.1
      nameservers:
        search: [openstack.local]
        addresses: [192.168.123.10, 8.8.8.8]
EOF

cat << 'EOF' > controller-ens4-config.yaml
network:
  version: 2
  ethernets:
    enp2s0:
      dhcp4: no
EOF

virt-customize -a /var/lib/libvirt/images/os-controller.img \
  --hostname controller.openstack.local \
  --upload controller-ens3-config.yaml:/etc/netplan/ens3-config.yaml \
  --upload controller-ens4-config.yaml:/etc/netplan/ens4-config.yaml

virt-install --name=os-controller \
  --import --disk path=/var/lib/libvirt/images/os-controller.img,format=qcow2 \
  --ram=6144 --vcpus=4 --os-variant=ubuntu20.04 \
  --network network=mgmt-net,model=virtio \
  --network network=ext-net,model=virtio \
  --graphics vnc,listen=0.0.0.0 --noautoconsole

#compute01
cat << 'EOF' > compute01-ens3-config.yaml
network:
  version: 2
  ethernets:
    enp1s0:
      addresses:
        - 192.168.123.12/24
      gateway4: 192.168.123.1
      nameservers:
        search: [openstack.local]
        addresses: [192.168.123.10, 8.8.8.8]
EOF

cat << 'EOF' > compute01-ens4-config.yaml
network:
  version: 2
  ethernets:
    enp2s0:
      dhcp4: no
EOF

virt-customize -a /var/lib/libvirt/images/os-compute01.img \
  --hostname compute01.openstack.local \
  --upload compute01-ens3-config.yaml:/etc/netplan/ens3-config.yaml \
  --upload compute01-ens4-config.yaml:/etc/netplan/ens4-config.yaml

virt-install --name=os-compute01 \
  --import --disk path=/var/lib/libvirt/images/os-compute01.img,format=qcow2 \
  --ram=4096 --vcpus=2 --os-variant=ubuntu20.04 \
  --network network=mgmt-net,model=virtio \
  --network network=ext-net,model=virtio \
  --graphics vnc,listen=0.0.0.0 --noautoconsole

#compute02
cat << 'EOF' > compute02-ens3-config.yaml
network:
  version: 2
  ethernets:
    enp1s0:
      addresses:
        - 192.168.123.13/24
      gateway4: 192.168.123.1
      nameservers:
        search: [openstack.local]
        addresses: [192.168.123.10, 8.8.8.8]
EOF

cat << 'EOF' > compute02-ens4-config.yaml
network:
  version: 2
  ethernets:
    enp2s0:
      dhcp4: no
EOF

virt-customize -a /var/lib/libvirt/images/os-compute02.img \
  --hostname compute02.openstack.local \
  --upload compute02-ens3-config.yaml:/etc/netplan/ens3-config.yaml \
  --upload compute02-ens4-config.yaml:/etc/netplan/ens4-config.yaml

virt-install --name=os-compute02 \
  --import --disk path=/var/lib/libvirt/images/os-compute02.img,format=qcow2 \
  --ram=4096 --vcpus=2 --os-variant=ubuntu20.04 \
  --network network=mgmt-net,model=virtio \
  --network network=ext-net,model=virtio \
  --graphics vnc,listen=0.0.0.0 --noautoconsole