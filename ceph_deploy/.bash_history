lsblk
shutdown -h now
lsblk
parted /dev/vda
lsblk
pvcreate /dev/vda3
vgextend /dev/vda3 centos-root
vgextend  centos-root centos-root
vgextend  centos-root /dev/vda3
vgextend  /dev/mapper/centos-root /dev/vda3
vgextend /dev/mapper/centos-root  /dev/vda3
vgs
vgextend centos  /dev/vda3
lvextend  -L  +100%  /dev/centos01/baknewlvm
lvextend  -L  +100%  /dev/centos/root 
lvextend   +100%  /dev/centos/root 
lvextend   +100%FREE /dev/centos/root 
lvextend  -l  +100%FREE /dev/centos/root 
lsblk
xfs_growfs /dev/centos/root 
yum update -y
reboot
lsblk
ip a
sudo subscription-manager repos --enable=rhel-7-server-extras-rpms
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo subscription-manager repos --enable=rhel-7-server-extras-rpms
ls /etc/yum.repos.d/
cat << EOM > /etc/yum.repos.d/ceph.repo
[ceph]
name=ceph
baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/x86_64/
gpgcheck=0
[ceph-noarch]
name=ceph-noarch
baseurl=http://mirrors.163.com/ceph/rpm-luminous/el7/noarch/
gpgcheck=0  
EOM

ls /etc/yum.repos.d/
yum install ceph-deploy -y
yum install ntp ntpdate ntp-doc -y
systemctl status firewalld.service 
systemctl disable firewalld.service 
systemctl stop firewalld.service 
getenforce 
vim /etc/selinux/config 
reboot
lsblk
systemctl status smbd
systemctl status smb
ls
vim 1_system.sh
ls
chmod +x 1_system.sh 
./1_system.sh 
ls
cd /etc/yum.repos.d/
ls
vim ceph.repo 
ls
ced
ls
cd
ls
vim 1_system.sh 
./1_system.sh 
yum install snappy leveldb gdisk python-argparse gperftools-libs -y 
vim /etc/resolv.conf 
vim /etc/yum.conf 
yum install snappy leveldb gdisk python-argparse gperftools-libs -y 
yum install ceph -y
hostnamectl set-hostname controller1
exit
