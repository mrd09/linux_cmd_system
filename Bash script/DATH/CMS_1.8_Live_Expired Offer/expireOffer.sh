#!/bin/bash

#1.Variable

# Directory Variable
Log_dir="/home/vt_admin/expiredOffer/log"
Script_dir="/home/vt_admin/expiredOffer"
offerID_list="/home/vt_admin/expiredOffer/offerID_list.txt"

allOfferExport_dir="/home/vt_admin/expiredOffer/allOfferExport"

# Improve April 2018
#DB Variable
#Live
#user="cmsuser"
#password="castis!cms!@#"
#dbIp="172.23.40.6"

#TestBed DB
user="root"
password="castis"
dbIp="10.60.70.200"
dbName="cms_test_init"

#Date Expired
time=`date --date "now + 60 minutes" +%F" "%T`

#`date +%F_%T`

mkdir -p ${Log_dir}
mkdir -p ${allOfferExport_dir}

#2. Function

#Print log
#function print_log {
#        echo "`date +%F_%T` $1" >> $Log_Dir/`date +%F`_fix_deploy_failed.log
#}

#Check mysql query status
function query_check {
	if [[ $? -eq 0 ]]; then
		echo "SUCCESS."
	else
		echo "FAIL."
	fi
	}

#3. Script Body

while read offerID; do
	stageCode_check=$(mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "select stageCode from offer where offer.offerId='${offerID}';")
	
	if ! [[ ${stageCode_check} == "85" ]];then
		echo "`date +%F_%T` This offer is not in stage Deploy Complete: ${offerID}" >> ${Script_dir}/error_list.txt
	else
		echo "`date +%F_%T` ::::::::::check and update license date to expire offer::::::::::"
		echo -n "`date +%F_%T` [-] Update date to Expired offer: ${offerID}... "
		mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "update offer set offer.licenseEndDateTime='${time}' where offer.offerId='${offerID}' and offer.stageCode='85';"
		query_check
	fi
	
	echo "`date +%F_%T`========================================================================================="
done < ${offerID_list} >> ${Log_dir}/expire_offer_`date "+%F-%H%M%S"`.log

