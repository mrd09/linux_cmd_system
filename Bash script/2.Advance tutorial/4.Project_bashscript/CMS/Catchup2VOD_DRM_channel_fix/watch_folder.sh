#!/bin/bash

## Path
workingFolder="/home/vt_admin/validate_xml"
configName="list_encrypted_channel"
mkdir -p ${workingFolder}

## Global variable
sdpIp="172.23.1.232"
sdpUser="adi"
sdpPw="adi"
isEncrypted=0
adiFolder="/home/adi"
posterList=""
thumbnailList=""
sentSuccess=1
editSuccess=1

# Limit
pushBatch=20
sdpLimit=100

function validateXml() {
	filePath=$1
	isEncrypted=0
	for channel in `cat ${workingFolder}/${configName}`; do
		echo ${channel}
		lineNumber=`egrep -n "[0-9]{14}_${channel}_[0-9]+\.m3u8" ${filePath} | cut -d":" -f1`
		if [[ ${#lineNumber} -gt 0 ]]; then
			isEncrypted=1
			break
		fi
	done
}

function getImageList() {
	filePath=$1
	posterList=""
	thumbnailList=""
	for poster in `cat ${filePath} | grep -n PosterType | cut -d":" -f1`; do
		posterList=${posterList}"`sed "$((poster+1))q;d" ${filePath} | perl -pe "s/<content:SourceUrl>(.*?)<\/content:SourceUrl>/\1/" | sed -e "s/^[[:space:]]*//" | sed -e "s/[[:space:]]*$//"` "
	done 
	for thumbnail in `cat ${filePath} | grep -n ThumbnailType | cut -d":" -f1`; do
                thumbnailList=${thumbnailList}"`sed "$((thumbnail+1))q;d" ${filePath} | perl -pe "s/<content:SourceUrl>(.*?)<\/content:SourceUrl>/\1/" | sed -e "s/^[[:space:]]*//" | sed -e "s/[[:space:]]*$//"` "
        done
	posterList=`echo ${posterList} | sed -e "s/[[:space:]]*$//"`
	thumbnailList=`echo ${thumbnailList} | sed -e "s/[[:space:]]*$//"`
}

function pushFileList() {
	listFile=$1
	sentSuccess=1
	old_IFS=$IFS
	IFS=$' '
	for file in ${listFile}; do
		if [[ ! -f ${adiFolder}/${file} ]]; then
			echo "[ERROR-`date "+%F %H:%M:%S"`] File ${file} not found." >&2
			sentSuccess=0
			break
		fi
		echo -n "[INFO-`date "+%F %H:%M:%S"`] Push File: ${file} to ${sdpIp}..." >&2
		curl -T ${adiFolder}/${file} ftp://${sdpIp} --user ${sdpUser}:${sdpPw} 2>/dev/null
		if [[ $? -eq 0 ]];then
			echo "DONE." >&2
		else
			sentSuccess=0
			echo "FAIL." >&2
			break
		fi
	done
	IFS=${old_IFS}
}


function deleteFileList() {
	fileList=$1
        old_IFS=$IFS
        IFS=$' '
	for file in ${fileList}; do
		rm -f ${adiFolder}/${file}
		echo "[INFO-`date "+%F %H:%M:%S"`] Delete File: ${adiFolder}/${file} ."
	done
        IFS=${old_IFS}
}

function editAdi() {
	filePath=$1
	editSuccess=1
	alreadyHaveEncrypted=`grep EncryptionInfo ${filePath}`
	if [[ ${#alreadyHaveEncrypted} -gt 0 ]]; then
		echo "[INFO-`date "+%F %H:%M:%S"`] Already have Encryption Info. No need to edit: ${filePath}" >&2
	else 
		lineNumber=`egrep -n "[0-9]{14}_5_[0-9]+\.m3u8" ${filePath} | cut -d":" -f1`
		echo -n "[INFO-`date "+%F %H:%M:%S"`] Edit ADI File: ${filePath} " >&2
		sed -i "$((lineNumber+5))i\\\t<content:EncryptionInfo>\n\t\t<content:ReceiverType>verimatrix<\/content:ReceiverType>\n\t\t<content:Encryption>true<\/content:Encryption>\n\t<\/content:EncryptionInfo>" ${filePath}
		if [[ $? -eq 0 ]];then
			 echo "DONE." >&2
		else
			echo "FAIL." >&2
			editSuccess=0
		fi
	fi	
}


#=============== EDIT AND PUSH FILE ================
# Check SDP
if [[ `curl ftp://${sdpIp} --user ${sdpUser}:${sdpPw} 2>/dev/null | grep -c OFFER` -gt ${sdpLimit} ]]; then
	echo "[INFO-`date "+%F %H:%M:%S"`] OFFER files in SDP folder exceed ${sdpLimit}. Wating for SDP process."
	exit
fi

for adi_file in `ls ${adiFolder} | grep OFFER | tail -${pushBatch}`; do
	echo ${adi_file}
	validateXml ${adiFolder}/${adi_file}
	if [[ ${isEncrypted} -eq 1 ]]; then
		editAdi ${adiFolder}/${adi_file}
	fi
	if [[ ${editSuccess} -eq 1 ]]; then
		getImageList ${adiFolder}/${adi_file}
		pushFileList ${posterList}
		if [[ ${sentSuccess} -eq 0 ]]; then
			continue
		fi 
		pushFileList ${thumbnailList}
		if [[ ${sentSuccess} -eq 0 ]]; then
			continue
		fi
		echo ${adi_file}
		pushFileList ${adi_file}
		if [[ ${sentSuccess} -eq 0 ]]; then
			continue
		fi
		deleteFileList ${posterList}
		deleteFileList ${thumbnailList}
		deleteFileList ${adi_file}
	fi
done	
