#!/bin/bash
#
# Copyright (c) 2013 Cisco AS Solutions Support
#
# by:                   Chris Dukes
# title:                BFST Hourly Report
# name:                 BFSThrlyrep.sh
# desc:                 The script automatically brings up a VPN connection
#                       to AT&T's Production Femto network, and executes
#                       several log and process checks.  The results are parsed
#                       and reported via email.
#

date=`date +%m%d%y`
time=`date +%R`
ts=`date +%m%d%y-%H%M`
repdate=`date +%x`
reptime=`date +%X`

EMAIL_TO="<user>@<domainname>.com"

BFSTpid="/users/localadm/scripts/logs/BFSTsum/temp/BFSTpid.dat"
DPEregout="/users/localadm/scripts/logs/BFSTsum/temp/DPEreg.out"
DPEregcnt="/users/localadm/scripts/logs/BFSTsum/temp/DPEregcnt.dat"
RDUtocnt="/users/localadm/scripts/logs/BFSTsum/temp/RDUtocnt.dat"
BATwaitcnt="/users/localadm/scripts/logs/BFSTsum/temp/BATwaitcnt.dat"
BATdrpcnt="/users/localadm/scripts/logs/BFSTsum/temp/BATdrpcnt.dat"
PRSTATout="/users/localadm/scripts/logs/BFSTsum/temp/prstat.out"
RDUbusycnt2="/users/localadm/scripts/logs/BFSTsum/temp/RDUbusycnt.dat"
BFSThungchk="/users/localadm/scripts/logs/BFSTsum/temp/BFSThungchk.dat"
BFSTrate="/users/localadm/scripts/logs/BFSTsum/temp/BFSTrate.out"
EPOCH_TS="/users/localadm/scripts/logs/BFSTsum/temp/EPOCH_TS.dat"
DPErestart="/users/localadm/scripts/logs/BFSTsum/temp/DPErestarts.out"

echo "Remove previous Tunnels"

ps -ef | egrep 'L8995|L8994|L8993' | grep -v grep | awk '{print "kill -9 " $2}'|sh

echo "Logging into B2B server"

ssh -q -o StrictHostKeyChecking=no -L8995:x.x.x.x:22 -g -N <user>@<hostname>.com -f

echo "Logging into Decatur NNM"

ssh -q -o StrictHostKeyChecking=no -L8994:x.x.x.x:22 -N <user>@localhost -p 8995 -f

### Begin Check ###

ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8994 "pgrep runDailyBFST.sh" > $BFSTpid

if [ -s $BFSTpid ]; then

   ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8994 "grep registering /data2/var/CSCObac/rdu/logs/audit.log" > $DPEregout

   ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8994 "grep -c -i timeout /data2/var/CSCObac/rdu/logs/rdu*.log | awk 'BEGIN {FS=\":\"}{ sum+=$2 } END { print sum }'" > $RDUtocnt

   ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8994 "grep -c 'Client batches waiting to execute' /data2/var/CSCObac/rdu/logs/rdu*.log | awk 'BEGIN {FS=\":\"}{ sum+=$2 } END { print sum }'" > $BATwaitcnt

   ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8994 "grep -c 'Dropping batch ID' /data2/var/CSCObac/fpg/logs/audit.log" > $BATdrpcnt

   ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8994 "grep -c busy /data2/var/CSCObac/fpg/logs/perf.log" > $RDUbusycnt2

   ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8994 "prstat -s cpu -n 5 -Z 1 1" > $PRSTATout

   ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8994 "python -c 'import os; print (os.path.getmtime(\"/data3/home/ops/BulkStatusReport/${date}-*/GetDeviceData/logs/debug.log\"))'" > $BFSThungchk

   ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8994 "date +%s" > $EPOCH_TS

   ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8994 "tail -1 /data3/home/ops/BulkStatusReport/${date}-*/GetDeviceData/logs/audit.log" > $BFSTrate

   if [ -s $DPEregout ]; then

      for i in `cat $DPEregout | awk '{print $11}'`
      do
         ssh -q -o ConnectTimeout=30 -o StrictHostKeyChecking=no -L8993:${i}:22 -N <user>@localhost -p 8995 -f
         echo -n "${i} - " >> $DPErestarts
         ssh -i /users/localadm/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8993 "ps -eo etime,comm | grep dpe | awk '{print $1}'" >> $DPErestarts
      done

   fi

else

   echo "BFST is not currently running"
   ps -ef | egrep 'L8995|L8994|L8993' | grep -v grep | awk '{print "kill -9 " $2}'|sh
   exit 0

fi

### Checks Completed ###

declare -i RDUtocnt2=`cat $RDUtocnt`
declare -i BATwaitcnt2=`cat $BATwaitcnt`
declare -i BATdrpcnt2=`cat $BATdrpcnt`
declare -i RDUbusycnt3=`cat $RDUbusycnt2`
declare -i BFSThungchk2=`cat $BFSThungchk`
declare -i EPOCH_TS2=`cat $EPOCH_TS`
declare -i DIFF2=(( $EPOCH_TS - $BFSThungchk ))
declare -i MINS2=(( $DIFF2 / 60 ))

### Build Report ###

BFSThrlyrep="/users/localadm/scripts/logs/BFSTsum/reports/BFSTrep${ts}.txt"

echo "BFST Hourly Report $repdate - $reptime" >> $BFSThrlyrep
echo "######################################" >> $BFSThrlyrep
echo "" >> $BFSThrlyrep
cat $BFSTrate >> $BFSThrlyrep
echo "" >> $BFSThrlyrep
cat $PRSTATout >> $BFSThrlyrep
echo "" >> $BFSThrlyrep

if [ $DIFF2 < 300 ]; then
   echo "BFST debug.log is active\t-\tPASSED" >> $BFSThrlyrep
else
   echo "BFST debug.log is active\t-\tFAILED" >> $BFSThrlyrep
   echo "\t**No entry in BFST debug.log for $MINS2 minutes"
   echo "" >> $BFSThrlyrep
fi

if [ $RDUtocnt2 == 0 ]; then
   echo "No timeouts in RDU logs/t-\tPASSED" >> $BFSThrlyrep
else
   echo "No timeouts in RDU logs/t-\tFAILED" >> $BFSThrlyrep
   echo "\t**$RDUtocnt2 timeouts in RDU logs" >> $BFSThrlyrep
fi

if [ $BATwaitcnt2 == 0 ]; then
   echo "No Client Batches waiting to execute\t-\tPASSED" >> $BFSThrlyrep
else
   echo "No Client Batches waiting to execute\t-\tFAILED" >> $BFSThrlyrep
   echo "\t**$BATwaitcnt2 Client Batch errors reported" >> $BFSThrlyrep
fi

if [ $BATdrpcnt2 == 0 ]; then
   echo "No \"Dropping batch ID\" errors reported\t-\tPASSED" >> $BFSThrlyrep
else
   echo "No \"Dropping batch ID\" errors reported\t-\tFAILED" >> $BFSThrlyrep
   echo "\t**$BATdrpcnt \"Dropping batch ID\" errors reported" >> $BFSThrlyrep
fi

if [ $RDUbusycnt3 == 0 ]; then
   echo "No \"RDU busy\" errors reported\t-\tPASSED" >> $BFSThrlyrep
else
   echo "No \"RDU busy\" errors reported\t-\tFAILED" >> $BFSThrlyrep
   echo "\t**$RDUbusycnt3 \"RDU busy\" errors reported" >> $BFSThrlyrep
fi

echo "" >> $BFSThrlyrep
echo "" >> $BFSThrlyrep
echo "DPE Restarts/Registrations" >> $BFSThrlyrep
echo "--------------------------" >> $BFSThrlyrep
echo "" >> $BFSThrlyrep

if [ -s $DPEregout ]; then
   echo "No DPE registrations reported\t-\tFAILED" >> $BFSThrlyrep
   echo "" >> $BFSThrlyrep
   cat $DPEregout >> $BFSThrlyrep
   echo "" >> $BFSThrlyrep
   echo "Uptime of DPE process on reported DPEs" >> $BFSThrlyrep
   echo "--------------------------------------" >> $BFSThrlyrep
   cat $DPErestarts >> $BFSThrlyrep
else
   echo "No DPE registrations reported\t-\tPASSED" >> $BFSThrlyrep
fi

mailx -r noreply@cisco.com -s "BFST Status now - $repdate" $EMAIL_TO < $BFSThrlyrep

echo "BFST Hourly Check complete"

ps -ef | egrep 'L8995|L8994|L8993' | grep -v grep | awk '{print "kill -9 " $2}'|sh

exit 0

###EOF###
