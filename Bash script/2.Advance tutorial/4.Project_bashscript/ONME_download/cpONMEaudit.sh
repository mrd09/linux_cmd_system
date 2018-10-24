#!/bin/bash

ftp_folder=/home/onme_download
file=$(cat ${ftp_folder}/listFileONME_exist.txt | cut -d ' ' -f9)
count=1
Log_Dir="/home/vt_admin/usageONME_copy/log"

mkdir -p ${Log_Dir}

function print_log {
		echo "`date +%F_%T` $1" | tee -a $Log_Dir/`date "+%F-%H%M%S"`_cp.log
}


for i in ${file};do
  asset=$(ls ${i} | cut -d '/' -f8)
  if [[ -f ${ftp_folder}/${asset} ]];then 
     #echo "[INFO]- `date +%F_%T` File ${ftp_folder}/${asset} exist"
     #echo "[INFO]- `date +%F_%T` File ${ftp_folder}/${asset} exist" >> $Log_Dir/`date +%F`_cp.log;
     print_log "[INFO]- File ${ftp_folder}/${asset} exist"
     continue;
  fi
  cp ${i} ${ftp_folder}
  chmod a+rw ${ftp_folder}/${asset}
  #echo "[INFO]- Copy ${i} finished" - Count ${count}"
  print_log "[INFO]- Copy ${i} finished - Count ${count}"
  ((count++));done
