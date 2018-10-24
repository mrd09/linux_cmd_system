#!/bin/bash

ateme1Folder=/NAS_INGEST01/cms/encoding/processing_hd/
#ateme2Folder=/CMS_TEST/NAS_INGEST01/cms/encoding/processing_hd/
hybridProcess=/NAS_INGEST01/cms/encoding/processing_hybrid
ottProcess=/NAS_INGEST01/cms/encoding/processing_ott

function checkFolder(){
	folderPath=$1
	for file in `ls ${folderPath} | grep m3u8`; do
		fileName=`echo ${file} | sed -e "s/[[:space:]]*$//g"`
		baseFileName=`echo ${file} | cut -d"." -f1 | sed -e "s/[[:space:]]*$//g"`
		assetId=`echo ${fileName} | cut -d"_" -f1 | sed -e "s/[[:space:]]*$//g"`
		fileType=`echo ${baseFileName} | cut -d"_" -f2 | cut -c 1`
		if [[ ${fileType} -eq 2 ]]; then
			touch ${hybridProcess}/${baseFileName}.mpg
			echo "[INFO-`date "+%F %H:%M:%S"`] Make ${hybridProcess}/${baseFileName}.mpg"
		else
			mkdir -p ${ottProcess}/${baseFileName}
			touch ${ottProcess}/${baseFileName}.m3u8
			echo "[INFO-`date "+%F %H:%M:%S"`] Make dir ${ottProcess}/${baseFileName}"
			echo "[INFO-`date "+%F %H:%M:%S"`] Make ${ottProcess}/${baseFileName}.m3u8"
		fi
		rm -rf ${folderPath}/${baseFileName}*
	done		
}

# Polling 2 Ateme Folder
checkFolder ${ateme1Folder}
#checkFolder ${ateme2Folder}
