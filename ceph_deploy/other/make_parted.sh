#!/bin/bash
#------------------------------------------------------------------------#
# Program: create partition
#
# History:
# 2018/03/06	you 	First release
#------------------------------------------------------------------------#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin 
export PATH

set -x

function parted_disk()
{
        #$1--->指定盘符
        #$2--->指定分区大小

        echo "parted_disk function----->para:$1,$2"

        TOTAL_CAP=`parted -s /dev/$1 unit mb print free | grep "Disk /dev/" | awk '{print $3}' |cut -d "M" -f1`
        FREE_CAP=`parted -s /dev/$1 unit mb print free | grep Free | awk '{print $3}' | cut -d "M" -f1|awk 'END {print}'`

        if [[ ${FREE_CAP} -le 10 ]];then
                echo "parted_disk function----->free capacity less than 10MB"
                return
        fi

        #最开始的1MB多空间
        let FREE_CAP=${FREE_CAP}-2

        if [ "${FREE_CAP}" -lt "$2" ];then
                echo "parted_disk function-----> free capacity less than $2"
        fi

        let START_CAP=${TOTAL_CAP}-${FREE_CAP}
        let END_CAP=${START_CAP}+$2  #50G=50*1024MB
        if [[ ${END_CAP} -gt ${TOTAL_CAP} ]];then
                END_CAP=${TOTAL_CAP}
        fi

        parted -s --align optimal /dev/$1 mkpart primary ${START_CAP}  ${END_CAP}
        partprobe /dev/$1

}


dev_list="sda sdb"
for device in ${dev_list}  
do
	FREE_CAP=`parted -s /dev/${device} unit mb print free | grep Free | awk '{print $3}' | cut -d "M" -f1|awk 'END {print}'`
	SIZE_CAP=$(echo "${FREE_CAP}/2"|bc)
	parted_disk ${device} ${SIZE_CAP}
	parted_disk ${device} ${SIZE_CAP}
done


