#!/bin/bash

#1.Variable

# Directory Variable
Log_dir="/home/vt_admin/expiredOffer/log_getoffer"
Script_dir="/home/vt_admin/expiredOffer"
offerID_list="/home/vt_admin/expiredOffer/offerID_list.txt"

allOfferExport_dir="/home/vt_admin/expiredOffer/allOfferExport"
offerSendSDP_dir="/home/vt_admin/expiredOffer/offerSendSDP"


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

#`date +%F_%T`

mkdir -p ${Log_dir}
mkdir -p ${allOfferExport_dir}
mkdir -p ${offerSendSDP_dir}

#2. Function
function query_check {
	if [[ $? -eq 0 ]]; then
		echo "SUCCESS."
	else
		echo "FAIL."
	fi
	}

#3. Script Body

while read offerID; do
	echo "`date +%F_%T` ::::::::::check and get offer send to SDP::::::::::"
	
	fileName="OFFER-${offerID}-*"
	echo -n "`date +%F_%T` [+] Moving $fileName..."
	#echo $fileName
	mv ${allOfferExport_dir}/${fileName} ${offerSendSDP_dir}/
	query_check
	
	echo "`date +%F_%T`========================================================================================="
done < ${offerID_list} >> ${Log_dir}/getoffer_`date +%F-%H%M%S`.log

#4. Clear Folder
allOfferbk_dir="/home/vt_admin/expiredOffer/allOfferbk/`date +%F-%H%M%S`"

mkdir -p ${allOfferbk_dir}

mv ${allOfferExport_dir} ${allOfferbk_dir}

mkdir -p ${allOfferExport_dir}
echo "`date +%F_%T` Move redundant Offer to bak folder: ${allOfferbk_dir}" >> ${Log_dir}/backupOffer_`date +%F-%H%M%S`.log