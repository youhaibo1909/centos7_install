#!/bin/bash
#------------------------------------------------------------------------#
# Program: add firsh ceph-monitor, install ceph-mgr
#			
# History:
# 2018/03/06	you 	First release
#------------------------------------------------------------------------#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -x

source ./ceph_config.ini

function config_ceph_mon()
{
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
monmaptool --create --add $local_name $local_ip --fsid $uuid /tmp/monmap

sudo -u ceph mkdir /var/lib/ceph/mon/${cluster_name}-${local_name}
sudo -u ceph ceph-mon --mkfs -i $local_name --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring


touch /var/lib/ceph/mon/${cluster_name}-${local_name}/done
chown -R ceph:ceph /var/lib/ceph/mon/${cluster_name}-${local_name}
systemctl start ceph-mon@${local_name}
systemctl enable ceph-mon@${local_name}

#delete defaut osd
#ceph osd pool delete rbd rbd --yes-i-really-really-mean-it
}

function config_ceph_mgr(){

ceph auth get-or-create mgr.${local_name} mon 'allow profile mgr' osd 'allow *' mds 'allow *'
ceph-mgr -i ${local_name}
systemctl start ceph-mgr@${local_name}
systemctl enable ceph-mgr@${local_name}
}

config_ceph_mon
config_ceph_mgr


