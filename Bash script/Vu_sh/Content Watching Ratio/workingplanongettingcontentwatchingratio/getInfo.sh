#!/bin/bash

gsdmLogPath="/castis/log/gsdm_log"

if [[ $# != 2 ]]; then
        echo "Need exactly 2 parameter: ./getInfo.sh --year --month"
        exit 0
fi

year=`echo $1 | perl -ne 'print if s/^(\d{4})$/$1/'`
month=`echo $2 | perl -ne 'print if s/^(\d{2})$/$1/'`

#echo $year
#echo $month

if  [[ ${#year} != 4 ]] || [[ ${#month} != 2 ]] || [[ ${#year} -gt 2018 ]] || [[ ${#month} -gt 12 ]]; then
        echo "Wrong year or month format."
        exit 0
fi

server=`echo $HOSTNAME | rev | cut -d'-' -f1 | rev`
rm -f /home/vt_admin/tvodResult_${server}.txt
rm -f /home/vt_admin/rvodResult_${server}.txt

for file in `ls ${gsdmLogPath}/${year}-${month}/*.log`; do
        grep "HTTP POST Request received:/demandRequestId.json" ${file} | grep filename | perl -ne 'print if s/.*"filename":"(\d{14}_\d.*?)",.*/$1/' >> /home/vt_admin/tvodResult_${server}.txt
        grep "HTTP POST Request received:/demandRequestId.json" ${file} | grep filename | perl -ne 'print if s/.*"filename":"(\d+_\d\..*?)",.*/$1/' >> /home/vt_admin/rvodResult_${server}.txt
done