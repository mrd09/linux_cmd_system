#!/bin/sh -x

bin="/castis/bin/tools/CiidxGenerator_64"

asset_id=$1
src_home="/data1"

bw_0=`egrep -o BANDWIDTH=[0-9]+ ${src_home}/${asset_id}.m3u8 | cut -d= -f2 | sed -n '1p'`
bw_1=`egrep -o BANDWIDTH=[0-9]+ ${src_home}/${asset_id}.m3u8 | cut -d= -f2 | sed -n '2p'`
bw_2=`egrep -o BANDWIDTH=[0-9]+ ${src_home}/${asset_id}.m3u8 | cut -d= -f2 | sed -n '3p'`
bw_3=`egrep -o BANDWIDTH=[0-9]+ ${src_home}/${asset_id}.m3u8 | cut -d= -f2 | sed -n '4p'`
bw_4=`egrep -o BANDWIDTH=[0-9]+ ${src_home}/${asset_id}.m3u8 | cut -d= -f2 | sed -n '5p'`
bw_5=`egrep -o BANDWIDTH=[0-9]+ ${src_home}/${asset_id}.m3u8 | cut -d= -f2 | sed -n '6p'`
bw_6=`egrep -o BANDWIDTH=[0-9]+ ${src_home}/${asset_id}.m3u8 | cut -d= -f2 | sed -n '7p'`

${bin} ${src_home}/${asset_id}_0.m3u8 ${src_home}/${asset_id}_0/${asset_id}_0.m3u8 $bw_0
${bin} ${src_home}/${asset_id}_1.m3u8 ${src_home}/${asset_id}_1/${asset_id}_1.m3u8 $bw_1
${bin} ${src_home}/${asset_id}_2.m3u8 ${src_home}/${asset_id}_2/${asset_id}_2.m3u8 $bw_2
${bin} ${src_home}/${asset_id}_3.m3u8 ${src_home}/${asset_id}_3/${asset_id}_3.m3u8 $bw_3
${bin} ${src_home}/${asset_id}_4.m3u8 ${src_home}/${asset_id}_4/${asset_id}_4.m3u8 $bw_4
${bin} ${src_home}/${asset_id}_5.m3u8 ${src_home}/${asset_id}_5/${asset_id}_5.m3u8 $bw_5
${bin} ${src_home}/${asset_id}_6.m3u8 ${src_home}/${asset_id}_6/${asset_id}_6.m3u8 $bw_6

mv ${src_home}/${asset_id}/${asset_id}_400k ${src_home}/${asset_id}_0
mv ${src_home}/${asset_id}/${asset_id}_700k ${src_home}/${asset_id}_1
mv ${src_home}/${asset_id}/${asset_id}_2M ${src_home}/${asset_id}_2
mv ${src_home}/${asset_id}/${asset_id}_4M ${src_home}/${asset_id}_3
mv ${src_home}/${asset_id}/${asset_id}_5M ${src_home}/${asset_id}_4
mv ${src_home}/${asset_id}/${asset_id}_7M ${src_home}/${asset_id}_5
mv ${src_home}/${asset_id}/${asset_id}_10M ${src_home}/${asset_id}_6

cd ${src_home}/${asset_id}_0
rename 400k 0 *
rename ts mpg *.ts
sed -i "s/^${asset_id}/\/${asset_id}/" ${src_home}/${asset_id}_0/${asset_id}_0.m3u8

cd ${src_home}/${asset_id}_1
rename 700k 1 *
rename ts mpg *.ts
sed -i "s/^${asset_id}/\/${asset_id}/" ${src_home}/${asset_id}_1/${asset_id}_1.m3u8

cd ${src_home}/${asset_id}_2
rename 2M 2 *
rename ts mpg *.ts
sed -i "s/^${asset_id}/\/${asset_id}/" ${src_home}/${asset_id}_2/${asset_id}_2.m3u8

cd ${src_home}/${asset_id}_3
rename 4M 3 *
rename ts mpg *.ts
sed -i "s/^${asset_id}/\/${asset_id}/" ${src_home}/${asset_id}_3/${asset_id}_3.m3u8

cd ${src_home}/${asset_id}_4
rename 5M 4 *
rename ts mpg *.ts
sed -i "s/^${asset_id}/\/${asset_id}/" ${src_home}/${asset_id}_4/${asset_id}_4.m3u8

cd ${src_home}/${asset_id}_5
rename 7M 5 *
rename ts mpg *.ts
sed -i "s/^${asset_id}/\/${asset_id}/" ${src_home}/${asset_id}_5/${asset_id}_5.m3u8
cd ${src_home}/${asset_id}_6
rename 10M 6 *
rename ts mpg *.ts
sed -i "s/^${asset_id}/\/${asset_id}/" ${src_home}/${asset_id}_6/${asset_id}_6.m3u8

rmdir ${src_home}/${asset_id}

sed -i '/^\s*$/d' ${src_home}/${asset_id}.m3u8
sed -i "s!.*${asset_id}_400k.*!/${asset_id}_0.m3u8?AdaptiveType=HLS!" ${src_home}/${asset_id}.m3u8
sed -i "s!.*${asset_id}_700k.*!/${asset_id}_1.m3u8?AdaptiveType=HLS!" ${src_home}/${asset_id}.m3u8
sed -i "s!.*${asset_id}_2M.*!/${asset_id}_2.m3u8?AdaptiveType=HLS!" ${src_home}/${asset_id}.m3u8
sed -i "s!.*${asset_id}_4M.*!/${asset_id}_3.m3u8?AdaptiveType=HLS!" ${src_home}/${asset_id}.m3u8
sed -i "s!.*${asset_id}_5M.*!/${asset_id}_3.m3u8?AdaptiveType=HLS!" ${src_home}/${asset_id}.m3u8
sed -i "s!.*${asset_id}_7M.*!/${asset_id}_3.m3u8?AdaptiveType=HLS!" ${src_home}/${asset_id}.m3u8
sed -i "s!.*${asset_id}_10M.*!/${asset_id}_3.m3u8?AdaptiveType=HLS!" ${src_home}/${asset_id}.m3u8
