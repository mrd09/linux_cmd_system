#!/bin/bash
read user
if grep $user /etc/passwd
then 
echo co user $user
else 
echo Khong co user $user
fi
