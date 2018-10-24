#!/bin/bash

#Live
user="cmsuser"
password="castis!cms!@#"
dbIp="172.23.40.6"
dbName="cms"

#TestBed
#Live
#user="root"
#password="castis"
#dbIp="10.60.70.200"
#dbName="cms_1_8_2_tvod_live"


folder=/home/vt_admin/usageCountONME/`date "+%F-%H%M%S"`

mkdir -p ${folder}

# Core query
#mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} 

# Get the list offerId from cp ONME:

mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -e "select offerId, cpId, title from offer where cpId='ONME'" >> ${folder}/offerIdONME.txt

# Export the list of VOD file to listFileONME_total.txt
list=$(mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "select offerId from offer where cpId='ONME'")

for i in ${list};do
	mysql -u${user} -p${password} -D ${dbName} -h ${dbIp} -sN -e "select fileName from contentasset where not fileName like '%.m3u8'  and contentSubsetId IN (select movieSubsetId from contentgroup where contentGroupId IN  (select contentGroupId from offercontentgroup where offerId=${i}));" >> ${folder}/listFileONME_total.txt; done

# Export the list of VOD file exist to listFileONME_exist.txt
file=$(cat ${folder}/listFileONME_total.txt)

for i in ${file} ; do 
	if [[ -f ${i} ]]; then 
		echo `ls -lrt ${i}` >> ${folder}/.listFileONME_exist_temp.txt;
	else echo ${i} >> ${folder}/.listFileONME_NotExist.txt	
	fi;
done

# Usage ONME count
cat ${folder}/.listFileONME_exist_temp.txt | sort | uniq >> ${folder}/listFileONME_exist.txt
file2=$(cat ${folder}/listFileONME_exist.txt | cut -d ' ' -f9);
for i in ${file2} ; do 
	echo `ls -lrt ${i}` >> ${folder}/usageSpaceOnMe.txt;done

cat ${folder}/usageSpaceOnMe.txt | cut -d ' ' -f5 | awk '{sum+=$1} END {print sum/1024/1024}' > ${folder}/resultUsageONME.txt

