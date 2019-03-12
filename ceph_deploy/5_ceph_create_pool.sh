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

source ./ceph_config.ini

#2 for mumber of copies 
size=2
#3 for volumes,images,vms
poolnum=3

function set_pgs_create_pool()
{
  #calculate pgs number with osd number
  pgnum=32
  osdcount=$(timeout 2 ceph osd tree | grep "osd" | wc -l)
  if [ 0 != $osdcount ];then
    calval=$[100*$osdcount/$size/$poolnum]
    for ((i=6; i<20; i++))
    do
      midnum=$[2**$i]
      if [ $midnum -gt $calval ];then            #if calval=65
        if [ $[$calval-$[midnum/2]] -gt $[$midnum-$calval] ];then
          pgnum=$midnum
        else
          pgnum=$[midnum/2]
        fi
        break
      fi
    done
  else
    echo "no osd here, please check it now ..."
    exit 1
  fi

  echo "the number of pg: $pgnum"
  ceph osd pool delete rbd rbd --yes-i-really-really-mean-it
  ceph osd pool create volumes $pgnum
  ceph osd pool create images $pgnum
  ceph osd pool create vms   $pgnum
  ceph osd pool set volumes size  $size
  ceph osd pool set images size  $size
  ceph osd pool set  vms  size  $size
  
ceph osd pool application enable vms rbd
ceph osd pool application enable volumes rbd
ceph osd pool application enable images rbd
}

set_pgs_create_pool

