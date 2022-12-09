#all
apt -y install software-properties-common  
add-apt-repository cloud-archive:victoria -y  
apt -y update && apt -y dist-upgrade 
apt -y install crudini 
reboot

#controller