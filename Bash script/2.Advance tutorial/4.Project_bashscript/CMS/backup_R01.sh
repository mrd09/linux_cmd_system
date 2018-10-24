#!/bin/bash

# Directory Variable
Log_Dir="/NAS_INGEST01/cms/fake/log"
DATE=`date +%Y%m`
Repository_1="/NAS_INGEST01/cms/repository/asset/*"
Repository_2="/NAS_INGEST02/cms/repository/asset/*"
AssetInstaller_Backup="/NAS_INGEST01/cdn/ott_rvod_backup"
OTT="m3u8"

# Improve April 2018
#DB Variable
#Live
user="cmsuser"
password="castis!cms!@#"
dbIp="172.23.40.6"
dbName="cms"

mkdir -p ${Log_Dir}

function print_log {
	echo "`date +%F_%T` $1" >> $Log_Dir/`date +%F`_backup_ott.log
}

function move_ott_file_to_repository {

	print_log "::::::::::move_ott_file_to_repository start::::::::::"

	for m3u8 in `ls $AssetInstaller_Backup | grep $OTT`
	do
		# m3u8 ex) 2015_4.m3u8 2015_5.m3u8
		# Asset_ID ex) 2015
		# Asset_File ex) 2015_4 2015_5
		Asset_ID=`echo $m3u8 | cut -d'_' -f1`
		Asset_File=`echo $m3u8 | cut -d'.' -f1`
		
		Compare_var=$(mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "select fileName from contentasset where contentSubsetId=${Asset_ID} and fileName like '%.m3u8';" | cut -d'/' -f2)
		if [[ ${Compare_var} == NAS_INGEST01 ]]
		then
			if ! [ -f ${Repository_1}/${Asset_ID}/${m3u8} ]
			then
				mv ${AssetInstaller_Backup}/${Asset_File} ${Repository_1}/${Asset_ID}/
				print_log "mv ${AssetInstaller_Backup}/${Asset_File} ${Repository_1}/${Asset_ID}/"
				mv ${AssetInstaller_Backup}/${m3u8} ${Repository_1}/${Asset_ID}/
				print_log "mv ${AssetInstaller_Backup}/${m3u8} ${Repository_1}/${Asset_ID}/"
			else
				if [ `stat -c %s $Repository_1/$Asset_ID/$m3u8` -eq 0 ];then
		
					#rm -rf ${Repository_1}/$Asset_ID/$Asset_File
					#print_log "test line : rm -rf ${Repository_1}/$Asset_ID/$Asset_File"
					mv ${AssetInstaller_Backup}/${Asset_File} ${Repository_1}/${Asset_ID}/
					print_log "mv ${AssetInstaller_Backup}/${Asset_File} ${Repository_1}/${Asset_ID}/"
		
					mv ${AssetInstaller_Backup}/${m3u8} ${Repository_1}/${Asset_ID}/
					print_log "mv ${AssetInstaller_Backup}/${m3u8} ${Repository_1}/${Asset_ID}/"
				else
					print_log "Already $Asset_ID in Repository_1"
				fi
			fi
		else
			if ! [ -f ${Repository_2}/${Asset_ID}/${m3u8} ]
			then
				mv ${AssetInstaller_Backup}/${Asset_File} ${Repository_2}/${Asset_ID}/
				print_log "mv ${AssetInstaller_Backup}/${Asset_File} ${Repository_2}/${Asset_ID}/"
				mv ${AssetInstaller_Backup}/${m3u8} ${Repository_2}/${Asset_ID}/
				print_log "mv ${AssetInstaller_Backup}/${m3u8} ${Repository_2}/${Asset_ID}/"
			else
				if [ `stat -c %s $Repository_2/$Asset_ID/$m3u8` -eq 0 ];then
		
					mv ${AssetInstaller_Backup}/${Asset_File} ${Repository_2}/${Asset_ID}/
					print_log "mv ${AssetInstaller_Backup}/${Asset_File} ${Repository_2}/${Asset_ID}/"
					mv ${AssetInstaller_Backup}/${m3u8} ${Repository_2}/${Asset_ID}/
					print_log "mv ${AssetInstaller_Backup}/${m3u8} ${Repository_2}/${Asset_ID}/"
				else
					print_log "Already $Asset_ID in Repository_2"
				fi
			fi		
		fi
	done
}

print_log "========================================================================================="
move_ott_file_to_repository
