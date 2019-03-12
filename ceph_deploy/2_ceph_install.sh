#!/bin/bash
#------------------------------------------------------------------------#
# Program: add firsh ceph-monitor, generate /etc/ceph/ceph.conf
#
# History:
# 2018/03/06	you 	First release
#------------------------------------------------------------------------#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -x

source ./ceph_config.ini


yum install snappy leveldb gdisk python-argparse gperftools-libs -y 
yum install ceph -y



function create_ceph_conf()
{
cat > /etc/ceph/ceph.conf <<EOF
[global]
fsid = a7f64266-0894-4f1e-a635-d0aeaca0e993
mon initial members = $local_name
mon host = $mon_ip
public network = $ceph_public_network
cluster network = $ceph_cluster_network

auth cluster required = none
auth service required = none
auth client required = none
osd journal size = 1024
osd pool default size = 2
osd pool default min size = 2
#osd pool default pg num = 333
#osd pool default pgp num = 333
osd crush chooseleaf type = 0
mon_allow_pool_delete = true
EOF
}

create_ceph_conf

