#!/bin/bash
#------------------------------------------------------------------------#
# Program: calculate pg num, create ceph-pool
#
# History:
# 2018/03/06	you 	First release
#------------------------------------------------------------------------#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -x


function del_pool(){
	ceph osd pool delete $1 $1 --yes-i-really-really-mean-it
}


pool_list="volumes images vms"
for pool in ${pool_list}
do 
	del_pool ${pool}
done


