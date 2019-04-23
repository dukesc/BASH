#!/bin/bash
#
# Copyright (c) 2014 Cisco Solutions Support
#
# by:                   Chris Dukes
# title:                UCS Inventory Parser
# name:                 UCSinvParser.sh
# desc:                 The script parses the server-inventory, chassis-inventory,
#                       and fabric-interconnect outputs of the UCS IOS into a
#                       a comma seperated value (CSV) file of Product IDs, PIDs,
#                       VIDs, and Serial Numbers.
#
error=0
usage() {
    echo "usage: UCSinvParser.sh [output file]"
    exit;
}

if [ "$1" = "" ];then
    echo "usage: UCSinvParser.sh [output file]"
    exit
fi

if [[  $1 == *csv ]];then
   outfile=$1
else
   outfile=${1}.csv
fi

touch $outfile
echo "Product Name,PID,VID,Serial Number,Vendor" >> $outfile

echo -n "Enter filename of 'show server inventory' output: "
read servinv
echo -n "Enter filename of 'show chassis inventory expand' output: "
read chassinv
echo -n "Enter filename of 'show fabric-interconnect inventory expand' output: "
read fabint

servinvnum=`cat $servinv | awk '/Equipped Product Name/{ print NR }'`

for i in $servinvnum
do
   prodnam=`cat $servinv | sed -n ${i}p | awk -F: '{ print $NF }'`
   j=`expr $i + 1`
   nexvar=`cat $servinv | sed -n ${j}p`
   if [ "$nexvar" = "" ];then
      j=`expr $i + 2`
      pid=`cat $servinv | sed -n ${j}p | awk -F: '{ print $NF }'`
   else
      pid=`cat $servinv | sed -n ${j}p | awk -F: '{ print $NF }'`
   fi
   k=`expr $j + 1`
   nexvar=`cat $servinv | sed -n ${k}p`
   if [ "$nexvar" = "" ];then
      k=`expr $j + 2`
      vid=`cat $servinv | sed -n ${k}p | awk -F: '{ print $NF }'`
   else
      vid=`cat $servinv | sed -n ${k}p | awk -F: '{ print $NF }'`
   fi
   l=`expr $k + 1`
    nexvar=`cat $servinv | sed -n ${l}p`
   if [ "$nexvar" = "" ];then
      l=`expr $k + 2`
      sernum=`cat $servinv | sed -n ${l}p | awk -F: '{ print $NF }'`
   else
      sernum=`cat $servinv | sed -n ${l}p | awk -F: '{ print $NF }'`
   fi
   prodnam2=`echo $prodnam | sed -e 's/^ *//' -e 's/ *$//'`
   pid2=`echo $pid | sed -e 's/^ *//' -e 's/ *$//'`
   vid2=`echo $vid | sed -e 's/^ *//' -e 's/ *$//'`
   sernum2=`echo $sernum | sed -e 's/^ *//' -e 's/ *$//'`
   if ! grep -Fxq "$sernum2" $outfile;then
      echo "${prodnam2},${pid2},${vid2},${sernum2}" >> $outfile
   fi
   unset prodnam
   unset pid
   unset vid
   unset sernum
done

cpuinvnum=`cat $servinv | awk '/Stepping/{ print NR }'`

for i in $cpuinvnum
do
   j=`expr $i + 1`
   nexvar=`cat $servinv | sed -n ${j}p`
   if [ "$nexvar" = "" ];then
      j=`expr $i + 2`
      prodnam=`cat $servinv | sed -n ${j}p | awk -F: '{ print $NF }'`
   else
      prodnam=`cat $servinv | sed -n ${j}p | awk -F: '{ print $NF }'`
   fi
   k=`expr $j + 1`
   nexvar=`cat $servinv | sed -n ${k}p`
   if [ "$nexvar" = "" ];then
      k=`expr $j + 2`
      pid=`cat $servinv | sed -n ${k}p | awk -F: '{ print $NF }'`
   else
      pid=`cat $servinv | sed -n ${k}p | awk -F: '{ print $NF }'`
   fi
   l=`expr $k + 1`
    nexvar=`cat $servinv | sed -n ${l}p`
   if [ "$nexvar" = "" ];then
      l=`expr $k + 2`
      vid=`cat $servinv | sed -n ${l}p | awk -F: '{ print $NF }'`
   else
      vid=`cat $servinv | sed -n ${l}p | awk -F: '{ print $NF }'`
   fi
   prodnam2=`echo $prodnam | sed -e 's/^ *//' -e 's/ *$//'`
   pid2=`echo $pid | sed -e 's/^ *//' -e 's/ *$//'`
   vid2=`echo $vid | sed -e 's/^ *//' -e 's/ *$//'`
   sernum2=""
   echo "${prodnam2},${pid2},${vid2},${sernum2}" >> $outfile
   unset prodnam
   unset pid
   unset vid
done

hddinvnum=`cat $servinv | awk '/HDD\/hot/{ print NR }'`

for i in $hddinvnum
do
   prodnam=`cat $servinv | sed -n ${i}p | awk -F: '{ print $NF }'`
   j=`expr $i + 1`
   nexvar=`cat $servinv | sed -n ${j}p`
   if [ "$nexvar" = "" ];then
      j=`expr $i + 2`
      pid=`cat $servinv | sed -n ${j}p | awk -F: '{ print $NF }'`
   else
      pid=`cat $servinv | sed -n ${j}p | awk -F: '{ print $NF }'`
   fi
   k=`expr $j + 1`
   nexvar=`cat $servinv | sed -n ${k}p`
   if [ "$nexvar" = "" ];then
      k=`expr $j + 2`
      vid=`cat $servinv | sed -n ${k}p | awk -F: '{ print $NF }'`
   else
      vid=`cat $servinv | sed -n ${k}p | awk -F: '{ print $NF }'`
   fi
   l=`expr $k + 1`
   nexvar=`cat $servinv | sed -n ${l}p`
   if [ "$nexvar" = "" ];then
      l=`expr $k + 2`
      vend=`cat $servinv | sed -n ${l}p | awk -F: '{ print $NF }'`
   else
      vend=`cat $servinv | sed -n ${l}p | awk -F: '{ print $NF }'`
   fi
   m=`expr $l + 2`
   nexvar=`cat $servinv | sed -n ${m}p`
   if [[ $nexvar = *erial* ]];then
      sernum=`cat $servinv | sed -n ${m}p | awk -F: '{ print $NF }'`
   else
      m=`expr $l + 3`
      sernum=`cat $servinv | sed -n ${m}p | awk -F: '{ print $NF }'`
   fi
   prodnam2=`echo $prodnam | sed -e 's/^ *//' -e 's/ *$//'`
   pid2=`echo $pid | sed -e 's/^ *//' -e 's/ *$//'`
   vid2=`echo $vid | sed -e 's/^ *//' -e 's/ *$//'`
   vend2=`echo $vend | sed -e 's/^ *//' -e 's/ *$//'`
   sernum2=`echo $sernum | sed -e 's/^ *//' -e 's/ *$//'`
   if ! grep -Fxq "$sernum2" $outfile;then
      echo "${prodnam2},${pid2},${vid2},${sernum2},${vend2}" >> $outfile
   fi
   unset prodnam
   unset pid
   unset vid
   unset sernum
   unset vend
done

adpinvnum=`cat $servinv | awk '/Adapter /{ print NR }'`

for i in $adpinvnum
do
   j=`expr $i + 2`
   nexvar=`cat $servinv | sed -n ${j}p`
   if [[ $nexvar == *---* ]];then
      j=`expr $i + 3`
      nexvar=`cat $servinv | sed -n ${j}p`
      if [ "$nexvar" = "" ];then
         j=`expr $i + 4`
         pid=`cat $servinv | sed -n ${j}p | awk '{ print $2 }'`
         sernum=`cat $servinv | sed -n ${j}p | awk '{ print $6 }'`
         if [ $sernum = "" ];then
            j=`expr $i + 5`
            sernum=`cat $servinv | sed -n ${j}p | awk '{ print $4 }'`
         fi
      else
         pid=`cat $servinv | sed -n ${j}p | awk '{ print $2 }'`
         sernum=`cat $servinv | sed -n ${j}p | awk '{ print $6 }'`
         if [ $sernum = "" ];then
            j=`expr $i + 4`
            sernum=`cat $servinv | sed -n ${j}p | awk '{ print $4 }'`
         fi
      fi
   else
      nexvar=`cat $servinv | sed -n ${j}p`
      if [ "$nexvar" = "" ];then
         j=`expr $i + 3`
         pid=`cat $servinv | sed -n ${j}p | awk '{ print $2 }'`
         sernum=`cat $servinv | sed -n ${j}p | awk '{ print $6 }'`
         if [ $sernum = "" ];then
            j=`expr $i + 4`
            nexvar=`cat $servinv | sed -n ${j}p`
            if [ "$nexvar" = "" ];then
               j=`expr $i + 5`
               sernum=`cat $servinv | sed -n ${j}p | awk '{ print $4 }'`
            else
               sernum=`cat $servinv | sed -n ${j}p | awk '{ print $4 }'`
            fi
         fi
      else
         pid=`cat $servinv | sed -n ${j}p | awk '{ print $2 }'`
         sernum=`cat $servinv | sed -n ${j}p | awk '{ print $6 }'`
         if [ "$sernum" = "" ];then
            j=`expr $i + 3`
            nexvar=`cat $servinv | sed -n ${j}p`
            if [ "$nexvar" = "" ];then
               j=`expr $i + 4`
               sernum=`cat $servinv | sed -n ${j}p | awk '{ print $4 }'`
            else
               sernum=`cat $servinv | sed -n ${j}p | awk '{ print $4 }'`
            fi
         fi
      fi
   fi
   prodnam2="Adapter"
   pid2=`echo $pid | sed -e 's/^ *//' -e 's/ *$//'`
   vid2=""
   sernum2=`echo $sernum | sed -e 's/^ *//' -e 's/ *$//'`
   if ! grep -Fxq "$sernum2" $outfile;then
      echo "${prodnam2},${pid2},${vid2},${sernum2}" >> $outfile
   fi
   unset pid
   unset sernum
done
