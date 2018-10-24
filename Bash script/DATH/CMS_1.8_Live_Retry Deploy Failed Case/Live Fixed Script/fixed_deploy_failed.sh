#!/bin/bash

#1. Variable

#FilePath
Log_Dir="home/vt_admin/fix_deployfailed/log"
List_Dir="home/vt_admin/fix_deployfailed/checklist"
Repository_1="/NAS_INGEST01/cms/repository/asset/*"
Repository_2="/NAS_INGEST02/cms/repository/asset/*"
AssetInstaller_Backup="/NAS_INGEST01/cdn/ott_rvod_backup"
CDN_path="/NAS_DIST02/cdn/import_mpg/hybrid_rvod /NAS_INGEST01/cdn/ott_rvod /NAS_INGEST01/cdn/ott_rvod_backup"
OTT="m3u8"

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


mkdir -p ${Log_Dir}
mkdir -p ${List_Dir}

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

#3. Script body

tempPath=$(echo `mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "select fileName from contentasset where stageCode='60' and fileName like 'm3u8';" | grep 2018`)

 for i in ${tempPath}
	echo "`date +%F_%T` ::::::::::check and fix deploy failed::::::::::"
    # m3u8 ex) 2015_4.m3u8 2015_5.m3u8
    # Asset_ID ex) 2015
    # Asset_File ex) 2015_4 2015_5
	i_dir=`dirname ${i}`
	m3u8=`ls ${i_dir} | grep ${OTT}`
	Asset_ID=`echo $m3u8 | cut -d'_' -f1`
	Asset_File=`echo $m3u8| cut -d'.' -f1`
	Compare_var=$(echo ${i} | cut -d'/' -f2)
	
	if [[ $Compare_var == NAS_INGEST01 ]]; then
	
		if ! [[ -f ${Repository_1}/${Asset_ID}/${m3u8} ]] ;then
			
				if ! [[ -f ${Repository_2}/${Asset_ID}/${m3u8} ]];then
					if [[ -z $(ls ${CDN_path} | grep ${m3u8}) ]];then
						echo "`date +%F_%T` ${i} '&' ${Repository_2}/${Asset_ID}/${m3u8} not exist"; >> $List_Dir/list_to_retry_encode.txt
						#print_log "${i} '&' ${Repository_2}/${Asset_ID}/${m3u8} not exist '=>' append SubsetID to list retry encode"
						
						echo "`date +%F_%T` [-] Update DB Deploy Complete state for missing content to retry encode: ${m3u8}"
						
						echo -n "`date +%F_%T`  - Update contentasset stageCode 85... "
						mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "UPDATE contentasset SET stageCode='85' WHERE contentSubsetId LIKE '%Asset_ID%';"
						query_check
						
						echo -n "`date +%F_%T`  - Update contentsubset stageCode 85... "
						mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "UPDATE contentsubset SET stageCode='85' WHERE contentSubsetId LIKE '%Asset_ID%';"
						query_check
						
						echo -n "`date +%F_%T`  - Update contentgroup stageCode 85... "
						mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "UPDATE contentgroup SET stageCode='85' WHERE movieSubsetId LIKE '%Asset_ID%';"
						query_check
						
						echo -n "`date +%F_%T`  - Update offer stageCode 85... "
						mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "UPDATE offer SET stageCode='85' WHERE offerId IN (SELECT offerId FROM offercontentgroup WHERE contentGroupId IN(SELECT contentGroupId FROM contentgroup WHERE movieSubsetId LIKE '%Asset_ID%'));"
						query_check
						
						echo -n "`date +%F_%T` [-] Update filePath for OTT file to: NAS_INGEST01: ${m3u8}"
						cd ${Repository_1}/${Asset_ID}
						mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "update contentasset set fileName='$PWD/$m3u8' where contentSubsetId=${Asset_ID} and fileName like '%.m3u8'"
						query_check
						
						echo "`date +%F_%T` [-] Check and chmod for STB file with SubsetID: ${Asset_ID}"
						stb=$(mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "select fileName from contentasset where contentSubsetId=${Asset_ID} and fileName like '.ts' or fileName like '.mpg';")
						stb_dir=`dirname ${stb}`
						stb_file=`basename ${stb}`
						Compare_var_2=$(echo ${stb} | cut -d'/' -f2)
						
						if [[ -f stb ]]; then
							echo -n "`date +%F_%T`  - chmod for STB file: ${stb_file} "
							chmod 777 $stb
							query_check
						
						#### Recheck this
						else
							if [[ ${Compare_var_2} == NAS_INGEST01 ]];then
								if ! [[ -f ${Repository_2}/${Asset_ID}/${stb_file} ]];then
									if [[ -z $(ls ${CDN_path} | grep ${stb_file}) ]];then
										echo "`date +%F_%T` - $stb '&' ${Repository_2}/${Asset_ID}/${stb_file} not exist"; >> ${Log_Dir}/list_to_re-register.txt
										#print_log "$stb '&' ${Repository_2}/${Asset_ID}/${stb_file} not exist '=>' append SubsetID to list re-register"
									else
										echo "`date +%F_%T` - ${stb_file} in distribute or copy"
										#print_log "${stb_file} in distribute or copy"
									fi
								else
									echo "`date +%F_%T` - Update file path for STB file to: NAS_INGEST01: $stb_file ... "
									cd ${Repository_1}/${Asset_ID}
									mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "update contentasset set fileName='$PWD/$stb_file' where contentSubsetId=${Asset_ID} and fileName like '%.ts' or fileName like '%.mpg'"
									query_check
								fi
							else 
								if ! [[ -f ${Repository_1}/${Asset_ID}/${stb_file} ]];then
									if [[ -z $(ls ${CDN_path} | grep ${stb_file}) ]];then
										echo "`date +%F_%T` - $stb '&' ${Repository_1}/${Asset_ID}/${stb_file} not exist"; >> ${Log_Dir}/list_to_re-register.txt
										#print_log "$stb '&' ${Repository_1}/${Asset_ID}/${stb_file} not exist '=>' append SubsetID to list re-register"
									else
										echo "`date +%F_%T` [-] ${stb_file} in distribute or copy"
										#print_log "${stb_file} in distribute or copy"
									fi
								else
									echo "`date +%F_%T` - Update file path for STB file to: NAS_INGEST02: $stb_file ... "
									cd ${Repository_2}/${Asset_ID}
									mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "update contentasset set fileName='$PWD/$stb_file' where contentSubsetId=${Asset_ID} and fileName like '%.ts' or fileName like '%.mpg'"
									query_check
								fi
							fi
					
						fi	
					else
						echo "`date +%F_%T` [-] ${m3u8} in distribute or copy"
					fi
				else
					#####Recheck this
					echo -n "`date +%F_%T` [-] Update filepath for: $m3u8 ..."
					cd ${Repository_2}/${Asset_ID}
					mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "update contentasset set fileName='$PWD/$m3u8' where contentSubsetId=${Asset_ID} and fileName like '%.m3u8'"
					query_check
					#print_log "Update path for: $m3u8"
				fi
		else
			echo "`date +%F_%T` [-] OTT file was found: ${m3u8}, check next file"
		fi
		###########
	else
		if ! [[ -f ${Repository_2}/${Asset_ID}/${m3u8} ]] ;then
			
				if ! [[ -f ${Repository_1}/${Asset_ID}/${m3u8} ]];then
					if [[ -z $(ls ${CDN_path} | grep ${m3u8}) ]];then
						echo "`date +%F_%T` ${i} '&' ${Repository_1}/${Asset_ID}/${m3u8} not exist"; >> $List_Dir/list_to_retry_encode.txt
						#print_log "${i} '&' ${Repository_1}/${Asset_ID}/${m3u8} not exist '=>' append SubsetID to list retry encode"
						
						echo "`date +%F_%T` [-] Update DB Deploy Complete state for missing content to retry encode: ${m3u8}"
						
						echo -n "`date +%F_%T`  - Update contentasset stageCode 85... "
						mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "UPDATE contentasset SET stageCode='85' WHERE contentSubsetId LIKE '%Asset_ID%';"
						query_check
						
						echo -n "`date +%F_%T`  - Update contentsubset stageCode 85... "
						mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "UPDATE contentsubset SET stageCode='85' WHERE contentSubsetId LIKE '%Asset_ID%';"
						query_check
						
						echo -n "`date +%F_%T`  - Update contentgroup stageCode 85... "
						mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "UPDATE contentgroup SET stageCode='85' WHERE movieSubsetId LIKE '%Asset_ID%';"
						query_check
						
						echo -n "`date +%F_%T`  - Update offer stageCode 85... "
						mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "UPDATE offer SET stageCode='85' WHERE offerId IN (SELECT offerId FROM offercontentgroup WHERE contentGroupId IN(SELECT contentGroupId FROM contentgroup WHERE movieSubsetId LIKE '%Asset_ID%'));"
						query_check
						
						echo -n "`date +%F_%T` [-] Update filePath for OTT file to: NAS_INGEST02: ${m3u8}"
						cd ${Repository_2}/${Asset_ID}
						mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "update contentasset set fileName='$PWD/$m3u8' where contentSubsetId=${Asset_ID} and fileName like '%.m3u8'"
						query_check
						
						echo "`date +%F_%T` [-] Check and chmod for STB file with SubsetID: ${Asset_ID}"
						stb=$(mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "select fileName from contentasset where contentSubsetId=${Asset_ID} and fileName like '.ts' or fileName like '.mpg';")
						stb_dir=`dirname ${stb}`
						stb_file=`basename ${stb}`
						Compare_var_3=$(echo ${stb} | cut -d'/' -f2)
						
						if [[ -f stb ]]; then
							echo -n "`date +%F_%T`  - chmod for STB file: ${stb_file} "
							chmod 777 $stb
							query_check
						
						#### Recheck this
						else

							if [[ ${Compare_var_3} == NAS_INGEST01 ]];then
								if ! [[ -f ${Repository_2}/${Asset_ID}/${stb_file} ]];then
									if [[ -z $(ls ${CDN_path} | grep ${stb_file}) ]];then
										echo "`date +%F_%T` $stb '&' ${Repository_2}/${Asset_ID}/${stb_file} not exist"; >> ${Log_Dir}/list_to_re-register.txt
										#print_log "$stb '&' ${Repository_2}/${Asset_ID}/${stb_file} not exist '=>' append SubsetID to list re-register"
									else
										echo "`date +%F_%T` ${stb_file} in distribute or copy"
										#print_log "${stb_file} in distribute or copy"
									fi
								else
									echo "`date +%F_%T` [-] Update file path for STB file to: NAS_INGEST01: $stb_file ..."
									cd ${Repository_1}/${Asset_ID}
									mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "update contentasset set fileName='$PWD/$stb_file' where contentSubsetId=${Asset_ID} and fileName like '%.ts' or fileName like '%.mpg'"
									query_check
								fi
							else 
								if ! [[ -f ${Repository_1}/${Asset_ID}/${stb_file} ]];then
									if [[ -z $(ls ${CDN_path} | grep ${stb_file}) ]];then
										echo "`date +%F_%T` $stb '&' ${Repository_1}/${Asset_ID}/${stb_file} not exist"; >> ${Log_Dir}/list_to_re-register.txt
										#print_log "$stb '&' ${Repository_1}/${Asset_ID}/${stb_file} not exist '=>' append SubsetID to list re-register"
									else
										echo "`date +%F_%T` ${stb_file} in distribute or copy"
										#print_log "${stb_file} in distribute or copy"
									fi
								else
									echo "`date +%F_%T` [-] Update file path for STB file to: NAS_INGEST02: $stb_file ..."
									cd ${Repository_2}/${Asset_ID}
									mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "update contentasset set fileName='$PWD/$stb_file' where contentSubsetId=${Asset_ID} and fileName like '%.ts' or fileName like '%.mpg'"
									query_check
								fi
							fi
					
						fi	
					else
						echo "`date +%F_%T` [-] ${m3u8} in distribute or copy"
					fi
				else
					#####Recheck this
					echo -n "`date +%F_%T` [-] Update filepath for: $m3u8 ..."
					cd ${Repository_1}/${Asset_ID}
					mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "update contentasset set fileName='$PWD/$m3u8' where contentSubsetId=${Asset_ID} and fileName like '%.m3u8'"
					query_check
					#print_log "Update path for: $m3u8"
				fi
		else
			echo "`date +%F_%T` [-] OTT file was found: ${m3u8}, check next file"
		fi
		
	fi
	echo "`date +%F_%T`========================================================================================="

 done >> $Log_Dir/`date +%F`_fix_deploy_failed.log

#print_log "========================================================================================="