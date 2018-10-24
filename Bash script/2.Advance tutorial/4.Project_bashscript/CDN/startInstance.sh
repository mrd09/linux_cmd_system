#!/bin/bash

checkRunning=`ps ax | grep monitor_vip.sh | grep -v grep`
programPath="/castis/bin/monitor_vip.sh"
logFolder="/castis/log/monitor_vip_log"
mkdir -p ${logFolder}

if [[  -f ${programPath} ]]; then
    if [[ ${#checkRunning} -eq 0 ]]; then
        echo "[`date +"%Y-%m-%d-%H:%M:%S"`] VIP monitoring not running. Start processs!" >> ${logFolder}/$(date +%d-%m-%Y)_monitor_vip.log
        ${programPath} &
    else
        echo "[`date +"%Y-%m-%d-%H:%M:%S"`] VIP monitoring IS RUNNING. Do NOTHING!" >> ${logFolder}/$(date +%d-%m-%Y)_monitor_vip.log
    fi
else
    echo "[`date +"%Y-%m-%d-%H:%M:%S"`] Monitor VIP program NOT FOUND. Exit !" >> ${logFolder}/$(date +%d-%m-%Y)_monitor_vip.log
fi
