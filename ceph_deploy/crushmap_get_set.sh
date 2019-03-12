#! /bin/bash
#------------------------------------------------------------------------#
# Program: get/set crushmap
#		   
# History:
# 2018/03/06	you 	First release
#------------------------------------------------------------------------#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -x

function usage()
{
    echo "usage: $0 get/set"
}

arg=$1

## Main
if [[ $arg == "get" ]] ; then
    if [ ! -d "crushmap" ];then
       mkdir crushmap
    fi
    cd crushmap
    ceph osd getcrushmap -o crushmap
    crushtool -d crushmap -o crush.map
    cd ../
elif [[ $arg == "set" ]] ; then
    if [ ! -d "crushmap" ];then
        echo "please firsh get crushmap."
	exit 0
    fi
    cd crushmap
    crushtool -c crush.map -o crushmap
    ceph osd setcrushmap -i crushmap
    cd ../
else
    usage
fi



