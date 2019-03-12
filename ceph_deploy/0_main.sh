#!/bin/bash
#------------------------------------------------------------------------#
# Program: ceph install entrance
#
# History:
# 2018/03/06	you 	First release
#------------------------------------------------------------------------#

set -e

function install_master_node(){
	#install master node
	echo "#------------>install ./1_system_mimic.sh<------------------#"
	./1_system_mimic.sh

	echo "#------------>install ./2_ceph_install.sh<------------------#"
	./2_ceph_install.sh

	echo "#------------>install ./3_ceph_mon_mgr.sh<------------------#"
	./3_ceph_mon_mgr.sh

	echo "#------------>install ./4_ceph_add_osd.sh<------------------#"
	./4_ceph_add_osd.sh

	echo "#------------>install ./5_ceph_create_pool.sh<------------------#"
	./5_ceph_create_pool.sh

	echo "#------------>install master node is ok.<------------------#"
}

function install_slave_node(){
	echo "#------------>install ./1_system.sh<------------------#"
	./1_system.sh

	echo "#------------>install ./2_ceph_install.sh<------------------#"
	./2_ceph_install.sh

	echo "#------------>install ./4_ceph_add_osd.sh<------------------#"
	./4_ceph_add_osd.sh
}


read -p "Please input install type[(master/slave) or (m/s)]: " intype
if [[ "${intype}" == "master" ]] || [[ "${intype}" == "m" ]];then
	install_master_node
elif [[ ${intype} == "slave" ]] || [[ "${intype}" == "s" ]];then
	install_slave_node
else
	echo "please re-input."
fi	

