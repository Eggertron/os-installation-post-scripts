#!/bin/bash

############################################
# Run as root after new OS install
if [ $(whoami) != 'root' ]; then
  echo "need to run as root"
  exit 1
fi

############################################
# Some global variables
MYHOSTNAME=nexus
SERVICENAME=ansible
SERVICESSHKEY=""
SERVICEPASSWD=""
SERVICEDIR="/home/$SERVICENAME"

# Reconfigure lan network as enabled
sed -i 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-ens32

# Restart the network device
ifdown ens32 && ifup ens32

# Firewall stop and disable
systemctl disable firewalld
systemctl stop firewalld

# SELinux permissive mode
setenforce 0

# yum update
yum update --skip-broken -y

# install vmware tools
yum install open-vm-tools -y

# vmware tools start and enable
systemctl enable vmtoolsd
systemctl start vmtoolsd

# update the hostname
hostname set-hostname $MYHOSTNAME

# create service account
useradd -g wheel -d $SERVICEDIR -s /bin/bash -p $SERVICEPASSWD $SERVICENAME

# install service account ssh keys
mkdir -p $SERVICEDIR/.ssh
echo "$SERVICESSHKEY" >> $SERVICEDIR/.ssh/authorized_keys
