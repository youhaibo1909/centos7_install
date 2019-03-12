#!/bin/bash
#------------------------------------------------------------------------#
# Program: del partition
#
# History:
# 2018/03/06	you 	First release
#------------------------------------------------------------------------#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin 
export PATH

set -x

echo $#  #//num of parameter
if [ $# -lt 1 ]; then
    echo "example: $0 \"sda sdb\""
    exit 1
fi

#dev_list="sda sdb"
dev_list=$1

for device in ${dev_list}  #//traverse all device
do
	echo "operate device /dev/${device} start."
	echo "------------------------------------>"
	num=`ls -l /dev | grep ${device}. |awk '{print $10}' | wc -l`
	if [[ "${num}" -ge 1 ]];then  #//judge devices is exist partition?
		for ((integer = 1; integer <= ${num}; integer++))  #//traverse all partition
		do  
			echo "del device ${device} parttion ${integer}." 
			parted -s /dev/${device}  rm ${integer}	
		done  
	fi
	echo "operate device /dev/${device} end."
	echo "------------------------------------<"
done
