#!/bin/bash

LOGTIME=`date "+%F-%H%M%S"`
#LOGPATH=/home/dath/read
LOGPATH=/home/dath/read6
RESULTPATH=/home/dath/result
#W_LOGPATH=/home/dath/write
W_LOGPATH=/home/dath/write6

mkdir -p ${LOGPATH}
mkdir -p ${RESULTPATH}

# Function to run multiple I/O

multiple_io(){
for ((i=1; i<401; i++)); do
 `echo 3 > /proc/sys/vm/drop_caches` && `echo "[${i}] - ${LOGTIME}" >> ${LOGPATH}/read_test_${i}.log` && `dd if=${W_LOGPATH}/test${i} of=/dev/zero bs=4096 count=10000 2>> ${LOGPATH}/read_test_${i}.log &`;  
done;
}

# Function to get the result
result(){
  if [[ -z `ps aux | grep -w dd | grep -v grep` ]];then
   for ((i=1; i<401; i++)); do
	`cat ${LOGPATH}/read_test_${i}.log >> ${LOGPATH}/temp.txt`;
   done
   `cat ${LOGPATH}/temp.txt | cut -d',' -f3 | sed '/+/d' >> ${LOGPATH}/read_result.txt`;
   rm -rf ${LOGPATH}/temp.txt && `cat ${LOGPATH}/read_result.txt >> ${LOGPATH}/temp.txt` && `cat ${LOGPATH}/temp.txt | sed '/-/d' >> ${LOGPATH}/read_raw.txt`;
   cp ${LOGPATH}/read*.txt ${RESULTPATH}/;
  fi
}

# Function pause
pause_ps(){
	while [[ ! -z `ps aux | grep -w dd | grep -v grep` ]];do
		 sleep 5
		 done;
}

# Body Handle

pause_ps;
multiple_io;

pause_ps;
result;
