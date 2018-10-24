#!/bin/bash

#Deploy Complete

COMPLETE_HYB_RVOD='/home/dath/NAS_DIST02/cdn/loaded/hybrid_rvod_sig'

COMPLETE_OTT_RVOD='/home/dath/NAS_INGEST01/cdn/ott_rvod_sig'

COMPLETE_HYB_AD='/home/dath/NAS_DIST02/cdn/loaded/hybrid_ad'

COMPLETE_OTT_AD='/home/dath/NAS_DIST02/cdn/loaded/ott_ad'

#Deploy Failed

FAILED_HYB_RVOD='/home/dath/NAS_DIST02/cdn/error'

FAILED_OTT_RVOD='/home/dath/NAS_INGEST01/cdn/ott_rvod_error'

FAILED_HYB_AD='/home/dath/NAS_DIST02/cdn/loaded/hybrid_ad/error'

FAILED_OTT_AD='/home/dath/NAS_DIST02/cdn/loaded/ott_ad/error'

#Continue to create signal file
FAIL=0

#Function
continue_loop(){
while [ -z $yn ]; do
	     read -p "Do you want to continue
	          If done type: y, not done: n. Your choice: " yn
		       case $yn in
		            [Yy]* ) unset NUM && unset FILENAME;;
			    [Nn]* ) exit;;
			        * ) echo "Please answer yes or no.";;
			esac
done

}

show_menu(){
  #echo "$OP_CONTINUE";
 # while [[ -z $NUM || -z $FILENAME ]]; do
  while [[ -z $NUM ]]; do
  #while [ -z $NUM ]; do
  #echo "$NUM" && echo "$FILENAME";
  unset NUM && unset FILENAME
  read -p "
  [1] Deploy Complete.HYB_RVOD 
  [2] Deploy Complete.OTT_RVOD
  [3] Deploy Complete.HYB_AD  
  [4] Deploy Complete.OTT_AD 
  [5] Deploy Failed.HYB_RVOD
  [6] Deploy Failed.OTT_RVOD  
  [7] Deploy Failed.HYB_AD  
  [8] Deploy Failed.OTT_AD
  Your selection: " NUM
  while [[ ! ${FILENAME} =~ \.sig$ ]];do
  read -p "Input the sigle file name with .sig extension: " FILENAME
  done
  case $NUM in
       1) cd "$COMPLETE_HYB_RVOD" && touch "$FILENAME" && echo "Check signal file is created: `ls -lt | grep $FILENAME`" && FAIL=0;;
       2) cd "$COMPLETE_OTT_RVOD" && touch "$FILENAME" && echo "Check signal file is created: `ls -lt | grep $FILENAME`" && FAIL=0;;
       3) cd "$COMPLETE_HYB_AD" && touch "$FILENAME" && echo "Check signal file is created: `ls -lt | grep $FILENAME`" && FAIL=0;;
       4) cd "$COMPLETE_OTT_AD" && touch "$FILENAME" && echo "Check signal file is created: `ls -lt | grep $FILENAME`" && FAIL=0;;
       5) cd "$FAILED_HYB_RVOD" && touch "$FILENAME" && echo "Check signal file is created: `ls -lt | grep $FILENAME`" && FAIL=0;;
       6) cd "$FAILED_OTT_RVOD" && touch "$FILENAME" && echo "Check signal file is created: `ls -lt | grep $FILENAME`" && FAIL=0;;
       7) cd "$FAILED_HYB_AD" && touch "$FILENAME" && echo "Check signal file is created: `ls -lt | grep $FILENAME`" && FAIL=0;;
       8) cd "$FAILED_OTT_AD" && touch "$FILENAME" && echo "Check signal file is created: `ls -lt | grep $FILENAME`" && FAIL=0;;
       *) echo "Invalid input, please re-select: " && FAIL=1;;

   esac
   done
}

#Fist time

while [[ "$FAIL" -eq 0 ]];do
  show_menu;
  #Handle FAIL=1
  while [[ "$FAIL" -eq 1 ]];do
   unset NUM && unset FILENAME && show_menu;
  done
#Infinite loop
  continue_loop && unset yn;
done
#else

echo "Please go to CMS to check status or check CMS_log if has any problem"
