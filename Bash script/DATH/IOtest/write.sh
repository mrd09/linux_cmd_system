#!/bin/bash

LOGTIME=`date "+%F-%H%M%S"`
#LOGPATH=/home/dath/write
LOGPATH=/home/dath/write6
RESULTPATH=/home/dath/result

mkdir -p ${LOGPATH}
mkdir -p ${RESULTPATH}

#for ((i=1; i<101; i++)); do
# `echo "[${i}] - ${LOGTIME}" >> ${LOGPATH}/write_test_${i}.log` && `dd if=/dev/zero of=${LOGPATH}/test${i} bs=4096 count=10000 conv=fdatasync oflag=dsync 2>> ${LOGPATH}/write_test_${i}.log &`;  
#done;

# Function to run multiple I/O

#multiple_io(){
#for ((i=1; i<401; i++)); do
# `echo "[${i}] - ${LOGTIME}" >> ${LOGPATH}/write_test_${i}.log` && `dd if=/dev/zero of=${LOGPATH}/test${i} bs=4096 count=10000 conv=fdatasync oflag=dsync 2>> ${LOGPATH}/write_test_${i}.log &`;
#done;
#}

multiple_io(){
	for ((i=1; i<401; i++)); do
		 `echo "[${i}] - ${LOGTIME}" >> ${LOGPATH}/write_test_${i}.log` && `dd if=/dev/zero of=${LOGPATH}/test${i} bs=4096 count=10000 conv=fdatasync 2>> ${LOGPATH}/write_test_${i}.log &`;
		 done;
}

# Function to get the result
result(){
  if [[ -z `ps aux | grep -w dd | grep -v grep` ]];then
     for ((i=1; i<401; i++)); do
     `cat ${LOGPATH}/write_test_${i}.log >> ${LOGPATH}/temp.txt`;
     done   
     `cat ${LOGPATH}/temp.txt | cut -d',' -f3 | sed '/+/d' >> ${LOGPATH}/write_result.txt`;
     rm -rf ${LOGPATH}/temp.txt && `cat ${LOGPATH}/write_result.txt >> ${LOGPATH}/temp.txt` && `cat ${LOGPATH}/temp.txt | sed '/-/d' >> ${LOGPATH}/write_raw.txt`;
     cp ${LOGPATH}/write*.txt ${RESULTPATH}/;
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
