#!/bin/bash

###------------------------------------------------------start---------------------------------------------------####
### 环境: centos7 + 双活数据库mariadb
### 状态：show slave status \G;
### 问题：
###      情况一：两个控制节点的错误一样
### 	  controller1 ：
###          Got fatal error 1236 from master when reading data from binary log: 
###							'Could not find first log file name in binary log index file'
###       controller2
###          Got fatal error 1236 from master when reading data from binary log: 
###                         'Could not find first log file name in binary log index file'
###-------------------------------------------------------end----------------------------------------------------####

#1.show master status;
#2.change master to master_host="192.168.3.65",master_user="root",master_password="123qwe",master_log_file="mysql.000005",master_log_pos=6992;
#3.start slave;
#4.SHOW SLAVE STATUS\G;
#FLUSH TABLES WITH READ LOCK
#SHOW MASTER STATUS
#UNLOCK TABLES

MASTER_HOST="192.168.3.221"
SALVE_HOST="192.168.3.222"
DBPASSWORD="123qwe"

function repair_slave_host()
{
	#'''修复从数据库'''
	#查看slave host状态
	Status_info=`mysql -uroot -p${DBPASSWORD} -e "SHOW SLAVE STATUS\\G;"  -h ${SALVE_HOST}`
	
	#锁表&停止slave服务
	mysql -uroot -p${DBPASSWORD} -e "FLUSH TABLES WITH READ LOCK;"  -h ${MASTER_HOST}
	mysql -uroot -p${DBPASSWORD} -e "FLUSH TABLES WITH READ LOCK;"  -h ${SALVE_HOST}
	mysql -uroot -p${DBPASSWORD} -e "stop slave;"  -h ${MASTER_HOST}
	mysql -uroot -p${DBPASSWORD} -e "stop slave;"  -h ${SALVE_HOST}

	#获取Position对应的数字
	#mysql -uroot -p123qwe -e "show master status;;"  -h 192.168.3.221 | grep mysql | awk '{print $2}'   
	#+--------------+----------+-------------------------------------------------------------------------+--------------------------+
	#| File         | Position | Binlog_Do_DB                                                            | Binlog_Ignore_DB         |
	#+--------------+----------+-------------------------------------------------------------------------+--------------------------+
	#| mysql.000027 | 95083061 | aodh,ceilometer,cinder,glance,keystone,neutron,nova,nova_api,nova_cell0 | mysql,information_schema |
	#+--------------+----------+-------------------------------------------------------------------------+--------------------------+
	Position=`mysql -uroot -p${DBPASSWORD} -e "show master status;"  -h ${MASTER_HOST} | grep mysql | awk '{print $2}'`   
	File=`mysql -uroot -p${DBPASSWORD} -e "show master status;"  -h ${MASTER_HOST} | grep mysql | awk '{print $1}'`
	mysql -uroot -p${DBPASSWORD} -e "change master to master_host=\"${MASTER_HOST}\",master_user=\"root\",master_password=\"${DBPASSWORD}\",master_log_file=\"${File}\",master_log_pos=${Position};" -h ${SALVE_HOST}

	#解锁表&启动slave服务
	mysql -uroot -p${DBPASSWORD} -e "UNLOCK TABLES;"  -h ${MASTER_HOST}
	mysql -uroot -p${DBPASSWORD} -e "UNLOCK TABLES;"  -h ${SALVE_HOST}
	mysql -uroot -p${DBPASSWORD} -e "start slave;"  -h ${MASTER_HOST}
	mysql -uroot -p${DBPASSWORD} -e "start slave;"  -h ${SALVE_HOST}


	#查看恢复的状态
	sleep 2
	echo "The repaired slave host<${SALVE_HOST}> status info: \n"
	#mysql -uroot -p123qwe -e "SHOW SLAVE STATUS\\G;"  -h 192.168.3.222
	Status_info=`mysql -uroot -p${DBPASSWORD} -e "SHOW SLAVE STATUS\\G;"  -h ${SALVE_HOST}`
	echo "${Status_info}"
}

function sync_db(){
	mysql -uroot -p${DBPASSWORD} -e "stop slave;"  -h ${MASTER_HOST}
	mysql -uroot -p${DBPASSWORD} -e "stop slave;"  -h ${SALVE_HOST}

	# 需要同步的数据库
	# 备份：mysqldump  -uroot -p123qwe nova > nova.sql; -h 192.168.3.221  #从192.168.3.221主机备份
	# 恢复：mysql -uroot -p123qwe nova <nova.sql -h 192.168.3.222         #恢复到192.168.3.222主机
	#| aodh               |
	#| cinder             |
	#| glance             |
	#| keystone           |
	#| neutron            |
	#| nova               |
	#| nova_api           |
	#| nova_cell0         |

        dbname=("aodh" "cinder" "glance" "keystone" "neutron" "nova" "nova_api" "nova_cell0")	

	for dbitem in ${dbname[*]}
	do
                echo ${dbitem}
		mysqldump  -uroot -p${DBPASSWORD} ${dbitem} > ${dbitem}.sql -h ${MASTER_HOST}
	done

	for dbitem in ${dbname[*]}
	do
                echo ${dbitem}
		mysql  -uroot -p${DBPASSWORD} ${dbitem} < ${dbitem}.sql -h ${SALVE_HOST}
	done

	mysql -uroot -p${DBPASSWORD} -e "start slave;"  -h ${MASTER_HOST}
	mysql -uroot -p${DBPASSWORD} -e "start slave;"  -h ${SALVE_HOST}
	
	#查看恢复的状态
	sleep 2
	echo "The repaired slave host<${SALVE_HOST}> status info: \n"
	#mysql -uroot -p123qwe -e "SHOW SLAVE STATUS\\G;"  -h 192.168.3.222
	Status_info=`mysql -uroot -p${DBPASSWORD} -e "SHOW SLAVE STATUS\\G;"  -h ${SALVE_HOST}`
	echo "${Status_info}"
}

#'''修复从数据库'''
repair_slave_host
#'''同步主数据库到从数据库'''
sync_db



