#!/bin/bash

# Variables

#dbIp=10.60.67.143
#dbUser=cmsuser
#dbPw="castis!cms!@#"
#db=cms
#sdpIp=172.23.1.232

dbIp=10.60.70.200
dbUser=root
dbPw="castis"
db=cms_test_init
sdpIp=10.60.70.224

sdpUser=adi
sdpPw=adi
adiFolder="/home/vt_admin/expiredOffer/offerSendSDP"
homeFolder=/home/vt_admin/expiredOffer/pushSDP/`date "+%F-%H%M%S"`
Log_dir="/home/vt_admin/expiredOffer/pushSDP/log"
processingAdi=${homeFolder}/processing
bakFolder="ADI_BACKUP"
limit=1000

pushStatus=0

cpIdList="/home/vt_admin/expiredOffer/offerID_list.txt"

mkdir -p ${homeFolder}/${bakFolder}
mkdir -p ${Log_dir}
errorLog="${homeFolder}/error.log"

cp -r ${adiFolder} ${processingAdi}
	
# Collect information from cms
while read list
do
	O=`echo $list`
echo "====================================COLLECTING INFORMATION============================================="
mysql -u${dbUser} -p${dbPw} -N ${db} -h ${dbIp} -e "select contentasset.fileName , offer.offerId from offer inner join offercontentgroup on offer.offerId = offercontentgroup.offerId and offer.stageCode = "85" inner join contentgroup on contentgroup.contentGroupId = offercontentgroup.contentGroupId inner join postergroup on postergroup.contentGroupId = contentgroup.contentGroupId inner join contentasset on contentasset.contentSubsetId = postergroup.posterSubsetId  where offer.offerId='${O}';" >> ${homeFolder}/result.txt
mysql -u${dbUser} -p${dbPw} -N ${db} -h ${dbIp} -e "select contentasset.fileName , offer.offerId from offer inner join offercontentgroup on offer.offerId = offercontentgroup.offerId and offer.stageCode = "85" inner join contentgroup on contentgroup.contentGroupId = offercontentgroup.contentGroupId and contentgroup.seriesId is not null inner join postergroup on contentGroup.seriesId =postergroup.seriesId inner join contentasset on contentasset.contentSubsetId = postergroup.posterSubsetId where offer.offerId='${O}';" >> ${homeFolder}/result.txt

done < ${cpIdList}

#if [[ $? -ne 0 ]]; then
#	echo "[ERROR-`date "+%F %H:%M:%S"`] Fail to get data from CMS database. Exit program."
#	exit 1
#else
#	echo "[INFO-`date "+%F %H:%M:%S"`] Successfully get data from CMS database."
#fi

# Function to push file via ftp
function pushSdp(){
	filePath=$1
	if [[ ! -f ${filePath} ]]; then
		echo "[ERROR]- File ${filePath} not found."
		pushStatus=2
	else
		# push file
		echo -n "[INFO]- Push File: ${filePath} to ${sdpIp}..."
		curl -T ${filePath} ftp://${sdpIp} --user ${sdpUser}:${sdpPw} 2>/dev/null
		if [[ $? -eq 0 ]];then
			echo "DONE."
			pushStatus=0
		else
			echo "FAIL."
			pushStatus=1
		fi
	fi
}

echo "=====================================PUSH ADI FILE VIA FTP============================================="
# Parse information and push file
totalNumber=`cat ${homeFolder}/result.txt | awk '{print $2}' | sort | uniq | wc -l`
startCount=0
exceedLimit=false
for offer in `cat ${homeFolder}/result.txt | awk '{print $2}' | sort | uniq`; do
	# Check SDP
	if [[ `curl ftp://${sdpIp} --user ${sdpUser}:${sdpPw} 2>/dev/null | grep -c OFFER` -gt ${limit} ]]; then
        	echo -n "[INFO-`date "+%F %H:%M:%S"`] OFFER files in SDP folder exceed limit. Waiting for process.." 
		exceedLimit=true
	fi
	while ${exceedLimit}; do
		echo -n "."
		if [[ `curl ftp://${sdpIp} --user ${sdpUser}:${sdpPw} 2>/dev/null | grep -c OFFER` -lt ${limit} ]]; then
			exceedLimit=false
			echo "DONE."
		fi
		sleep 1
	done
	startCount=$(($startCount+1))
	echo "[INFO-`date "+%F %H:%M:%S"`] [${startCount} / ${totalNumber} ]  Working on OFFER : ${offer}."
	offer=`echo ${offer} | sed -e "s/[[:space:]]*$//g"`
	if [[ `ls ${processingAdi} | grep -c "OFFER-${offer}-"` -ne 1 ]];then
		echo "[ERROR]- ADI File for: ${offer} NOT Existed."
		echo "[ERROR]- OfferID : ${offer}. Reason: ADI file NOT Existed." >> ${errorLog}
		continue
	fi
	imagePushSuccess=false
	#listOfImage=`awk -v offer="${offer}" '$2==offer {print $1}' ${homeFolder}/result.txt | sed -e "s/[[:space:]]*$//g" | sort | uniq`
	listOfImage=`grep -w ${offer}$ ${homeFolder}/result.txt | awk '{print $1}' | sort | uniq`
	#echo ${listOfImage}
	for image in ${listOfImage}; do
		image=`echo ${image} | sed -e "s/[[:space:]]*$//g"`
		pushSdp ${image}
		if [[ ${pushStatus} -eq 0 ]]; then
			imagePushSuccess=true
		elif [[ ${pushStatus} -eq 2 ]]; then
			echo "[ERROR]- Image NOT Existed: ${image} for OfferId: ${offer}"
			echo "[ERROR]- OfferID : ${offer}. Reason: Image NOT Existed: ${image}." >> ${errorLog}
			imagePushSuccess=false
			break
		else	
			echo "[ERROR] Fail to push Image: ${image} for OfferId: ${offer}"
			echo "[ERROR]- OfferID : ${offer}. Reason: Image failed to push: ${image}." >> ${errorLog}
			imagePushSuccess=false
			break
		fi
	done
	if ${imagePushSuccess}; then
		adiFile=`find ${processingAdi}/ -name *.xml | grep "OFFER-${offer}-" | sed -e "s/[[:space:]]*$//g"`
		pushSdp ${adiFile}
		if [[ ${pushStatus} -ne 0 ]]; then
			echo "[ERROR-`date "+%F %H:%M:%S"`] Fail to push ADI file for OfferId: ${offer}"
			echo "[ERROR]- OfferID: ${offer}. Reason: ADI failed to push " >> ${errorLog}
		else
			
			mv ${adiFile} ${homeFolder}/${bakFolder}/
		fi
	fi
done >> ${Log_dir}/pushSDP_`date "+%F-%H%M%S"`.log
echo "======> Finish deploy all ADI file to SDP"

#Clean up the left behind Expired ADI after push SDP
bak=/home/vt_admin/expiredOffer/pushSDP/cleanup_`date "+%F-%H%M%S"`/
mkdir -p ${bak}
mv ${adiFolder} ${bak}
mkdir -p ${adiFolder}

echo "cleanup folder ${adiFolder} mv ADI to: ${bak}" >> ${Log_dir}/cleanup_`date "+%F-%H%M%S"`.log
