#!/bin/bash

# Variables
originalBond="eth0"
bondName="eth0:1"
ip="10.60.70.245"
netMask="255.255.255.192"
runInterval="3"
logFolder="/castis/log/monitor_vip_log"
mkdir -p ${logFolder}

while true; do
    process=`ps ax | grep CiGLB | grep -v grep`
    bond1=`ifconfig ${originalBond} | grep "Device not found"`
    vipUp=`ifconfig ${bondName} | grep ${ip}`
    if [[ ${#process} -gt 0 && ${#bond1} -eq 0 ]]; then
        if [[ ${#vipUp} -eq 0 ]]; then
            ifconfig ${bondName} ${ip} netmask ${netMask} 1>2 2>/dev/null
            checkVIP=`ifconfig ${bondName} | grep ${ip}`
            # Check if VIP successfully created.
            if [[ ${#checkVIP} -gt 0 ]]; then
                echo "[`date +"%Y-%m-%d-%H:%M:%S"`] VIP ${bondName} ${ip} is successfully created !"
            else
                echo "[`date +"%Y-%m-%d-%H:%M:%S"`] VIP ${bondName} ${ip} FAIL to create !"
            fi
        else
            echo "[`date +"%Y-%m-%d-%H:%M:%S"`] VIP ${bondName} ${ip} already UP. Do nothing !"
        fi
    else
        if [[ ${vipUp} -gt 0 ]]; then
            ifconfig ${bondName} down 1>2 2>/dev/null
            echo "[`date +"%Y-%m-%d-%H:%M:%S"`] Service down on this server ==> ${bondName} shutdown !"
        else
            echo "[`date +"%Y-%m-%d-%H:%M:%S"`] VIP ${bondName} ${ip} already DOWN. Do nothing !"
        fi
    fi
    sleep ${runInterval}
done >> ${logFolder}/$(date +%d-%m-%Y)_monitor_vip.log
