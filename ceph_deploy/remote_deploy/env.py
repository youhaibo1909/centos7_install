#-*- coding:utf-8 -*-
import os

pkg_list = ['python-pip', '*.whl']
#install package
failed_install_list = []
for pkg in pkg_list:
    if 'python-pip' in pkg:
        try:
            os.system('pip -V')
        except Exception as e:
            print ("pip not install, -_-", e)    
            os.system('yum install -y '+pkg)
    else:
        try:
            import pexpect
        except Exception as e:
            print ("pexpect not install, -_-", e)
            os.system('pip install  '+pkg)
            
    output = os.popen('echo $?')
    re_st = output.read().strip('\n')
    if str(re_st) != "0":
        failed_install_list.append(pkg)

        
if len(failed_install_list) != 0:
    print ('Install Failed Pkgs:')
    print ('xxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    for i in failed_install_list:
        print i
else:
    print ("============================")
    print ("Successfully Installed !")
    
    
