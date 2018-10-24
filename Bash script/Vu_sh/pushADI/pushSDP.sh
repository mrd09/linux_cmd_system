#!/bin/bash

# Variables

dbIp=10.60.67.143
dbUser=cmsuser
dbPw="castis!cms!@#"
db=cms
sdpIp=172.23.1.232
sdpUser=adi
sdpPw=adi
adiFolder=/home/vt_admin/pushSDP/adiFile
homeFolder=/home/vt_admin/pushSDP/`date "+%F-%H%M%S"`
processingAdi=${homeFolder}/processing
bakFolder="ADI_BACKUP"
limit=100

mkdir -p ${homeFolder}/${bakFolder}
errorLog="${homeFolder}/error.log"
cp -r ${adiFolder} ${processingAdi}

# Collect information from cms

echo "====================================COLLECTING INFORMATION============================================="

mysql -u${dbUser} -p${dbPw} -N ${db} -h ${dbIp} -e "select contentasset.fileName , offer.offerId from offer inner join offercontentgroup on offer.offerId = offercontentgroup.offerId and offer.stageCode = "85" inner join contentgroup on contentgroup.contentGroupId = offercontentgroup.contentGroupId inner join postergroup on postergroup.contentGroupId = contentgroup.contentGroupId inner join contentasset on contentasset.contentSubsetId = postergroup.posterSubsetId;" > ${homeFolder}/result.txt

mysql -u${dbUser} -p${dbPw} -N ${db} -h ${dbIp} -e "select contentasset.fileName , offer.offerId from offer inner join offercontentgroup on offer.offerId = offercontentgroup.offerId and offer.stageCode = "85" inner join contentgroup on contentgroup.contentGroupId = offercontentgroup.contentGroupId and contentgroup.seriesId is not null inner join postergroup on contentGroup.seriesId =postergroup.seriesId inner join contentasset on contentasset.contentSubsetId = postergroup.posterSubsetId;" >> ${homeFolder}/result.txt

if [[ $? -ne 0 ]]; then
	echo "[ERROR-`date "+%F %H:%M:%S"`] Fail to get data from CMS database. Exit program."
	exit 1
else
	echo "[INFO-`date "+%F %H:%M:%S"`] Successfully get data from CMS database."
fi

# Function to push file via ftp

function pushSdp(){
	filePath=$1
	if [[ ! -f ${filePath} ]]; then
		echo "[ERROR-`date "+%F %H:%M:%S"`] File ${filePath} not found."
		return 2
	fi
	# push file
	echo -n "[INFO-`date "+%F %H:%M:%S"`] Push File: ${filePath} to ${sdpIp}..."
	curl -T ${filePath} ftp://${sdpIp} --user ${sdpUser}:${sdpPw} 2>/dev/null
	if [[ $? -eq 0 ]];then
		echo "DONE."
		return 0
	else
		echo "FAIL."
		return 1
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

		echo "[ERROR-`date "+%F %H:%M:%S"`] ADI File for: ${offer} NOT Existed."
		echo "[ERROR-`date "+%F %H:%M:%S"`] OfferID : ${offer}. Reason: ADI file NOT Existed." >> ${errorLog}
		continue
	fi
	imagePushSuccess=false
	listOfImage=`grep -w ${offer} ${homeFolder}/result.txt | awk '{print $1}' | sort | uniq`
	#echo ${listOfImage}
	for image in ${listOfImage}; do
		image=`echo ${image} | sed -e "s/[[:space:]]*$//g"`
		pushSdp ${image}
		if [[ $? -eq 0 ]]; then
			imagePushSuccess=true
		elif [[ $? -eq 1 ]]; then
			echo "[ERROR-`date "+%F %H:%M:%S"`] Fail to push Image: ${image} for OfferId: ${offer}"
			echo "[ERROR-`date "+%F %H:%M:%S"`] OfferID : ${offer}. Reason: Image failed to push: ${image}." >> ${errorLog}
			imagePushSuccess=false
			break
		elif [[ $? -eq 2 ]]; then
			echo "[ERROR-`date "+%F %H:%M:%S"`] Image NOT Existed: ${image} for OfferId: ${offer}"
			echo "[ERROR-`date "+%F %H:%M:%S"`] OfferID : ${offer}. Reason: Image NOT Existed: ${image}." >> ${errorLog}
			imagePushSuccess=false
			break
		fi
	done
	if ${imagePushSuccess}; then
		adiFile=`find ${processingAdi}/ -name *.xml | grep "OFFER-${offer}-" | sed -e "s/[[:space:]]*$//g"`
		pushSdp ${adiFile}
		if [[ $? -ne 0 ]]; then
			echo "[ERROR-`date "+%F %H:%M:%S"`] Fail to push ADI file for OfferId: ${offer}"
			echo "[ERROR-`date "+%F %H:%M:%S"`] OfferID: " >> ${errorLog}
		else
			mv ${adiFile} ${homeFolder}/${bakFolder}/
		fi
		
	fi
done
echo "======> Finish deploy all ADI file to SDP"
