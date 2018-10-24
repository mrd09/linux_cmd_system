#!/bin/bash

# Set PS3 prompt
PS3="Select option to copy:"

# Function def:
# 1. Function print_log:
count=1
Log_Dir="/home/vt_admin/usageONME_copy/log"

mkdir -p ${Log_Dir}

function print_log {
		echo "`date +%F_%T` $1" | tee -a $Log_Dir/`date "+%F-%H%M%S"`_cp.log
}

# 2. Function copy file:
function copy_month {
	ftp_folder=/home/onme_download
	file=$(cat ${ftp_folder}/listFileONME_exist.txt | grep ${month} | cut -d ' ' -f9)
	mkdir -p ${ftp_folder}/${month} && cd ${ftp_folder}/${month}
	chmod a+rw ${ftp_folder}/${month}
	for i in ${file};do
	  asset=$(ls ${i} | cut -d '/' -f8)
	  if [[ -f ${ftp_folder}/${month}/${asset} ]];then 
	     print_log "--------------"
	     print_log "Processing ${month}..."
	     print_log "--------------"
	     print_log "[INFO]- File ${ftp_folder}/${month}/${asset} exist"
	     continue;
	  fi
	  cp ${i} ${ftp_folder}/${month}/
	  chmod a+rw ${ftp_folder}/${month}/${asset}
	  print_log "--------------"
	  print_log "Processing ${month}..." 
	  print_log "--------------"
	  print_log "[INFO]- Copy ${i} finished - Count ${count}"
	  ((count++));done
}

# set months in the list:
select month in 201803 201804 201805 201806 201807 201808 201809 Quit 
do
	case ${month} in
	201803)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	201804)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	201805)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	201806)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	201807)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	201808)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	201809)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
		
	Quit)
		break
		;;
	*)		
		echo "Error: Please try again (select 1..9)!"
		;;		
	esac
done
