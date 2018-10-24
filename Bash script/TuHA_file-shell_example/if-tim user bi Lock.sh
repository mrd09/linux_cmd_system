#!/bin/bash
read user
if grep $user /etc/shadow | cut -d: -f2 | cut -b1 | grep !
then 
echo $user bi lock
else 
echo Khong bi lock $user
fi
