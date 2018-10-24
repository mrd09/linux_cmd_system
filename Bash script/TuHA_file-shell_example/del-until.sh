#!/bin/bash
i=1
until [ $i -ge 5 ]
do 
rm -rf file$i
i=`expr $i + 1`
done

