#!/bin/bash 
#------------------------------------------------------------------------#
# Program: backup /etc/yum.repos.d/*, install new repo, 
#		   close firewalld, close selinux
#
# History:
# 2018/03/06	you 	First release
#------------------------------------------------------------------------#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -x

if [ ! -f "/root/repobk" ];then
	mkdir -p /root/repobk
fi
mv /etc/yum.repos.d/* /root/repobk


#-----------------------------配置163源--------------------------#
cat << EOM >/etc/yum.repos.d/ceph.repo
[ceph]
name=Ceph packages for x86_64
baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/x86_64
enabled=1
gpgcheck=1
priority=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/noarch
enabled=1
gpgcheck=1
priority=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/SRPMS
enabled=0
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1
EOM


cat << EOM >/etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 7 - x86_64
#baseurl=http://download.fedoraproject.org/pub/epel/7/x86_64
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=x86_64
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 7 - x86_64 - Debug
#baseurl=http://download.fedoraproject.org/pub/epel/7/x86_64/debug
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-7&arch=x86_64
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 7 - $basearch - Source
#baseurl=http://download.fedoraproject.org/pub/epel/7/SRPMS
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-source-7&arch=x86_64
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1
EOM

cat << EOM >/etc/yum.repos.d/CentOS-Base.repo
[base]
name=CentOS-$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=x86_64&repo=os&infra=\$infra
#baseurl=http://mirror.centos.org/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates 
[updates]
name=CentOS-$releasever - Updates
mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=updates&infra=\$infra
#baseurl=http://mirror.centos.org/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=extras&infra=\$infra
#baseurl=http://mirror.centos.org/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=centosplus&infra=\$infra
#baseurl=http://mirror.centos.org/centos/\$releasever/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOM



#本地源
cat >> /etc/yum.repos.d/CentOS-Local.repo <<EOF
[Local]
name = this-ceph-repo
baseurl = file:///yum/ceph_luminous_package
gpgcheck=0
enabled=1
cost=88
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
if [ ! -f "/yum" ];then
    mkdir -p /yum
fi
\cp -r ./ceph_luminous_package /yum/
yum-config-manager --disable Local
yum install -y createrepo
yum-config-manager --enable Local
createrepo /yum/ceph_luminous_package                                
yum clean all && yum makecache


#关闭selinux、防火墙
systemctl stop firewalld.service
systemctl disable firewalld.service
firewall-cmd --state
sed -i '/^SELINUX=.*/c SELINUX=disabled' /etc/selinux/config
sed -i 's/^SELINUXTYPE=.*/SELINUXTYPE=disabled/g' /etc/selinux/config
grep --color=auto '^SELINUX' /etc/selinux/config
setenforce 0


yum install ntp ntpdate ntp-doc -y

username=insceph
useradd -d /home/${username} -m ${username}
echo "1" |passwd --stdin ${username}
echo "${username} ALL = (root) NOPASSWD:ALL" > /etc/sudoers.d/${username}
sudo chmod 0440 /etc/sudoers.d/${username}










