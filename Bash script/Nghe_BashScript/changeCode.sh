#!/bin/bash
data_dir="/data1"
add_codec="mp4a.40.2"


for file in $( ls ${data_dir} | grep _4.m3u8 | grep -V mp4a.40.2 )
	do
		echo $file
		sed -i "s/"CODECS\=\"avc1.42E01F\""/"CODECS\=\"avc1.42E01F\,${add_codec}\""/g" ${data_dir}/$file
	done
