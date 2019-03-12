#!/bin/bash
#------------------------------------------------------------------------#
# Program: add second mon
#
# History:
# 2018/03/06	you 	First release
#------------------------------------------------------------------------#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -x

source ./ceph_config.ini


function add_mon()
{
	mkdir /var/lib/ceph/mon/ceph-$local_name
	
	monmap=/tmp/monmap
	monkeyring=/tmp/mon-keyring
	#ceph auth get mon. -o ${monkeyring}
	ceph mon getmap -o ${monmap}
	ceph-mon -i $local_name --mkfs --monmap $monmap
	ceph-mon -i $local_name --public-addr $local_ip
	
	touch /var/lib/ceph/mon/ceph-$local_name/done
	chown -R ceph:ceph /var/lib/ceph/mon/ceph-$local_name
	systemctl enable ceph-mon@$local_name
	systemctl start ceph-mon@$local_name
}

add_mon



