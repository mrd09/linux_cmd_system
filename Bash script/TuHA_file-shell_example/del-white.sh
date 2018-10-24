#!/bin/bash
i=1
while [ $i -le 10 ]
do 
rm -rf file$i.txt
i=`expr $i + 1`
done

