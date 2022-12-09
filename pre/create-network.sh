#!/bin/bash
cat <<'EOF' > mgmt-net.xml
<network>
<name>mgmt-net</name>
<forward mode='nat'/>
<bridge name='virbr1' stp='on' delay='0'/>
<ip address='192.168.123.1' netmask='255.255.255.0'>
<dhcp>
<range start='192.168.123.50' end='192.168.123.99'/>
</dhcp>
</ip>
</network>
EOF

cat <<'EOF' > ext-net.xml
<network>
<name>ext-net</name>
<forward mode='nat'/>
<bridge name='virbr2' stp='on' delay='0'/>
<ip address='203.0.113.1' netmask='255.255.255.0' />
</network>
EOF

#define and start network libvirt
virsh net-define --file mgmt-net.xml
virsh net-define --file ext-net.xml

virsh net-autostart mgmt-net
virsh net-autostart ext-net

virsh net-start mgmt-net
virsh net-start ext-net

# show networks
virsh net-list --all