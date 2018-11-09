#!/bin/bash

# Set PS3 prompt
PS3="Select option to copy:"

# Function def:
# 1. Function print_log:
count=1
Log_Dir="/home/vt_admin/usageONME_copy/log"

mkdir -p ${Log_Dir}

function print_log {
		echo "`date +%F_%T` $1" | tee -a $Log_Dir/`date +%F`_cp.log
}

# 2. Function copy file:
function copy_month {
	ftp_folder=/NAS_INGEST02/cp_ftp/onme_download
        #file=$(cat ${ftp_folder}/listFileONME_exist_23Oct2018.txt   | grep ${month} | cut -d ' ' -f9)  
	file=$(cat ${ftp_folder}/listFileONME_exist_02Nov2018.txt   | grep ${month} | cut -d ' ' -f9)  
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
        	if [ $? -ne 0 ]
		then
		    echo "[ERROR]- Copy file ${i} failed" | tee -a $Log_Dir/error.log
		else
			print_log "--------------"
	                print_log "Processing ${month}..."
                        print_log "--------------"
			print_log "[INFO]- Copy file ${i} success" 
			chmod a+rw ${ftp_folder}/${month}/${asset}
			print_log "[INFO]- Copy ${i} - Count ${count}"
			print_log "--------------"
		fi
	  ((count++));done
}

# set months in the list:
read -p "Input the year: (Ex: 2018): " year
select month in ${year}01 ${year}02 ${year}03 ${year}04 ${year}05 ${year}06 ${year}07 ${year}08 ${year}09 ${year}10 ${year}11 ${year}12 Quit 
do
	case ${month} in
        ${year}01)
                echo "--------------"
                echo "Processing ${month}..."
                echo "--------------"
                copy_month
                print_log "--------------"
                print_log "Processing Copy ${month} done, please check log if has error"
                print_log "--------------"
                ;;
        ${year}02)
                echo "--------------"
                echo "Processing ${month}..."
                echo "--------------"
                copy_month
                print_log "--------------"
                print_log "Processing Copy ${month} done, please check log if has error"
                print_log "--------------"
                ;;

	${year}03)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	${year}04)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	${year}05)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	${year}06)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	${year}07)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	${year}08)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;
	${year}09)
		echo "--------------"
		echo "Processing ${month}..."
		echo "--------------"
		copy_month
		print_log "--------------"
		print_log "Processing Copy ${month} done, please check log if has error"
		print_log "--------------"
		;;

        ${year}10)
                echo "--------------"
                echo "Processing ${month}..."
                echo "--------------"
                copy_month
                print_log "--------------"
                print_log "Processing Copy ${month} done, please check log if has error"
                print_log "--------------"
                ;;
        ${year}11)
                echo "--------------"
                echo "Processing ${month}..."
                echo "--------------"
                copy_month
                print_log "--------------"
                print_log "Processing Copy ${month} done, please check log if has error"
                print_log "--------------"
                ;;
        ${year}12)
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
		echo "Error: Please try again (select 1..13)!"
		;;		
	esac
done
