#!/bin/bash

find /Users/kealiasshenji/Downloads/Viettel/ | grep xsh > tempFile
while read item;
do
	ip=`grep Host "${item}" | cut -d'=' -f2 | sed -e 's/[[:space:]]*$//'`
	user=`grep UserName "${item}" | cut -d'=' -f2 | sed -e 's/[[:space:]]*$//'`
	hostName=`echo ${item} | rev | cut -d'/' -f1 | rev | sed -e 's/\.xsh//g' | tr '[:upper:]' '[:lower:]' | tr -s ' ' | tr ' ' '-' | sed -e 's/[[:space:]]*$//'`
	echo "${hostName} ${ip} ${user}"
done < tempFile
rm -f tempFile