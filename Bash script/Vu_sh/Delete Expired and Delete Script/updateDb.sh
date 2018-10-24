#!/bin/bash

## Variables
#homeFolder=/home/vt_admin/delScript
homeFolder=/home/dath/script_all/delScript
mkdir -p ${homeFolder}

#Live
#user="cmsuser"
#password="castis!cms!@#"
#dbIp="172.23.40.6"

#TestBed
user="root"
password="castis"
dbIp="10.60.70.200"
dbName="cms_test_init"

## Log
logTime=`date +"%Y-%d-%m_%H_%M"`
echo "[+] STARTING. Append to log ${logTime}.log"

while read offerId; do
        offerId=`echo ${offerId} | sed -e "s/[[:space:]]*$//g"`
	if [[ ${#offerId} -eq 0 ]]; then
        #Failed part:
	#	continue:
                continue
	fi
	mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -N -e "select offer.offerId, contentgroup.contentGroupId, contentsubset.contentSubsetId, contentasset.contentAssetId, contentasset.fileName from offer inner join offercontentgroup on offercontentgroup.offerId = offer.offerId and offer.offerId = ${offerId} and offer.stageCode in ('05', '90') inner join contentgroup on contentgroup.contentGroupId = offercontentgroup.contentGroupId inner join contentsubset on contentsubset.contentSubsetId = contentgroup.movieSubsetId inner join contentasset on contentasset.contentSubsetId = contentsubset.contentSubsetId;" > ${homeFolder}/.tempResult
	resultSet=`cat ${homeFolder}/.tempResult`
        if [[ ${#resultSet} -eq 0 ]]; then
                echo "[+] No record for offerId:${offerId}"
		continue
	fi
        contentGroupId=`cat ${homeFolder}/.tempResult | awk '{print $2}' | uniq`
        contentSubsetId=`cat ${homeFolder}/.tempResult | awk '{print $3}' | uniq`
        contentAssetId=`cat ${homeFolder}/.tempResult | awk '{print $4}' | uniq`
	filePath=`cat ${homeFolder}/.tempResult | awk '{print $5}'`
	## Remove file
	if [[ ${#filePath} -gt 0 ]]; then
		for file in ${filePath}; do
			echo -n "    [-] Remove ${file}..."
			rm -f ${file}
			if [[ -f ${filePath} ]]; then
				echo "FAILED."
			else
				echo "SUCCESS."
			fi
			isOTT=`echo ${file} | grep m3u8`
			if [[ ${#isOTT} -gt 0 ]]; then
				ottFolder=`echo ${file} | rev | cut -d"." -f2 | rev`
				echo -n "    [-] Remove folder: ${ottFolder}..."
				if [[ ${#ottFolder} -gt 0 ]]; then
					rm -rf ${ottFolder}
					if [[ -d ${ottFolder} ]]; then
						echo "FAILED."
					else
						echo "SUCCESS."
					fi
				fi
			fi

		done
	else
		continue
	fi
	## Update DB
	echo "    [-] Update DB: "
	echo -n "      - Update stageCode offerId:${offerId}..."
	mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -e "update offer set offer.stageCode = '99' where offer.offerId='${offerId}'"
	if [[ $? -eq 0 ]]; then
		echo "SUCCESS."
	else
		echo "FAIL."
	fi
	echo -n "      - Update stageCode contentGroupId:${contentGroupId}..."
	mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -e "update contentgroup set contentgroup.stageCode = '99' where contentgroup.contentGroupId='${contentGroupId}'"
	if [[ $? -eq 0 ]]; then
                echo "SUCCESS."
        else
                echo "FAIL."
        fi
        echo -n "      - Update stageCode contentSubsetId:${contentSubsetId}..."
	mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -e "update contentsubset set contentsubset.stageCode = '99' where contentsubset.contentSubsetId='${contentSubsetId}'"
	if [[ $? -eq 0 ]]; then
                echo "SUCCESS."
        else
                echo "FAIL."
        fi
        for assetId in ${contentAssetId}; do
		echo -n "      - Update stageCode contentAssetId:${assetId}..."
		mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -e "update contentasset set contentasset.stageCode = '99' where contentasset.contentAssetId='${assetId}'"
		if [[ $? -eq 0 ]]; then
			echo "SUCCESS."
		else
			echo "FAIL."
		fi
	done
done < listOffer.txt > ${logTime}.log
