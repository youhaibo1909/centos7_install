#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pexpect
import os, sys, getpass
import argparse

def ssh_cmd(ip, passwd, cmd):
    ret = -1
    ssh = pexpect.spawn('ssh  root@%s "%s"' % (ip, cmd))
    try:
        i = ssh.expect(['password:', 'continue connecting (yes/no)?'], timeout=5)
        if i == 0 :
            ssh.sendline(passwd)
        elif i == 1:
            ssh.sendline('yes\n')
            ssh.expect('password: ')
            ssh.sendline(passwd)
        ssh.sendline(cmd)
        r = ssh.read()
        print r
        ret = 0
    except pexpect.EOF:
        print "EOF"
        ssh.close()
        ret = -1
    except pexpect.TIMEOUT:
        print "TIMEOUT"
        ssh.close()
        ret = -2
    return ret



def scp2(ip, user, passwd, dst_path, filename):
    if os.path.isdir(filename):
        #cmdline = 'scp -P 25600 -r %s %s@%s:%s' % (filename, user, ip, dst_path)
        cmdline = 'scp -r %s %s@%s:%s' % (filename, user, ip, dst_path)
    else:
        cmdline = 'scp %s %s@%s:%s' % (filename, user, ip, dst_path)
    try:
        child = pexpect.spawn(cmdline)
        i = child.expect(['password:', 'continue connecting (yes/no)?'], timeout=300)
        if i == 0 :
            child.sendline(passwd)
        elif i == 1:
            child.sendline('yes\n')
            child.expect('password: ')
            child.sendline(passwd)
        child.expect(pexpect.EOF,timeout=300)
        child.interact()
        child.read()
        child.expect('$')
        print "uploading is ok."
    except Exception as e:
        print ("upload faild! error:", e)


if __name__=='__main__':
    parser = argparse.ArgumentParser(description='ceph install project arg parse.')
    parser.add_argument('--host', action='store', dest='hostip', default="192.168.10.20", required=True)
    parser.add_argument('--passwd', action='store', dest='password', default="123qwe", required=True)
    given_args = parser.parse_args()
    ipaddr = given_args.hostip
    passwd = given_args.password

    print('to remote host: ', ipaddr)
    

    host_info=[
        {"hostip":ipaddr, "hostpasswd": passwd},
    ]
    for item_host in host_info:
        scp2(item_host["hostip"], "root",item_host["hostpasswd"], "/root/", "../../ceph_deploy")
    
    
