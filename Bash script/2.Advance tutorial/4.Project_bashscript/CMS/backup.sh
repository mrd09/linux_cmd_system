#!/bin/bash -x

Log_Dir="/NAS_INGEST01/cms/fake/log"
DATE=`date +%Y%m`
Repository="/NAS_INGEST01/cms/repository/asset/*"
AssetInstaller_Backup="/NAS_INGEST01/cdn/ott_rvod_backup"
OTT="m3u8"

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

		if ! [ -f ${Repository}/${Asset_ID}/${m3u8} ]
		then
			mv ${AssetInstaller_Backup}/${Asset_File} ${Repository}/${Asset_ID}/
			print_log "mv ${AssetInstaller_Backup}/${Asset_File} ${Repository}/${Asset_ID}/"
			mv ${AssetInstaller_Backup}/${m3u8} ${Repository}/${Asset_ID}/
			print_log "mv ${AssetInstaller_Backup}/${m3u8} ${Repository}/${Asset_ID}/"
		else
			if [ `stat -c %s $Repository/$Asset_ID/$m3u8` -eq 0 ];then

				#rm -rf ${Repository}/$Asset_ID/$Asset_File
				print_log "test line : rm -rf ${Repository}/$Asset_ID/$Asset_File"
				mv ${AssetInstaller_Backup}/${Asset_File} ${Repository}/${Asset_ID}/
				print_log "mv ${AssetInstaller_Backup}/${Asset_File} ${Repository}/${Asset_ID}/"

				mv ${AssetInstaller_Backup}/${m3u8} ${Repository}/${Asset_ID}/
				print_log "mv ${AssetInstaller_Backup}/${m3u8} ${Repository}/${Asset_ID}/"
			else
				print_log "Already $Asset_ID in Repository"
			fi
		fi
	done
}

print_log "========================================================================================="
move_ott_file_to_repository
