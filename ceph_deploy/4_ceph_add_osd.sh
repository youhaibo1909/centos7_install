#!/bin/bash
#------------------------------------------------------------------------#
# Program:  import variable $osd_dev from ceph_config.ini file, comma-separated.
#			add osd use blustore storage mode
#
# History:
# 2018/03/06	you 	First release
#------------------------------------------------------------------------#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -x


source ./ceph_config.ini
#导入osd_dev变量
#osd_dev="/dev/vdb;/dev/vdc"  

function add_osd(){
	sudo ceph-volume lvm create --data $1

	#Alternatively
	#uuid="ab693225-742a-480e-8e74-f4480f3ee6e1"
	#osdid=0
	#sudo ceph-volume lvm prepare --data /dev/vdb
	#sudo ceph-volume lvm list
	#sudo ceph-volume lvm activate ${osdid} ${uuid}
}

OLD_IFS="$IFS"
IFS=";"
arr=($osd_dev)
IFS="$OLD_IFS"

for dev_partition in ${arr[@]}
do
	echo "add osd devices is ${dev_partition}."
	add_osd ${dev_partition}
done

 


