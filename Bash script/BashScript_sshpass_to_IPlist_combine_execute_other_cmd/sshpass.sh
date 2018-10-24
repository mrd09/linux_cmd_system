#!/bin/bash

export SSHPASS=dat@1234
while read ip; do
  sshpass -v -e scp /root/IPlist.txt root@$ip:/home && sshpass -e ssh root@$ip ls -l /home
done < IPlist.txt

