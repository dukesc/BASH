#!/bin/bash
#
# Copyright (c) 2013 Cisco AS Solutions Support
#
# by:                   Chris Dukes
# title:                RDU Busy Check
# name:                 RDUbusychk.sh
# desc:                 The script automatically brings up a VPN connection
#                       to AT&T's Production Femto network, and checks for 
#                       "busy" entries in the current BFST audit log.

date=`date +%m%d%y`
time=`date +%R`
logfile="/tmp/RDUbusy/$date_cnt.dat"
pidfile="/tmp/RDUbusy/pidfile.dat"

touch $logfile

echo -n "$time " >> $logfile

echo "Remove previous Tunnels"

ps -ef | egrep 'L8999|L8998' | grep -v grep | awk '{print "kill -9 " $2}'|sh

echo "Logging into B2B server"

ssh -q -o StrictHostKeyChecking=no -L8999:x.x.x.x:22 -g -N <user>@<hostname>.com -f

echo "Logging into Decatur NNM"

ssh -q -o StrictHostKeyChecking=no -L8998:x.x.x.x:22 -N <user>@localhost -p 8999 -f

### Begin Check ###

ssh -i /home/dukesc/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8998 "pgrep runDailyBFST.sh" > $pidfile

if [ -s $pidfile ]; then
   echo "No BFST currently running"
   exit 0
else

   ssh -i /home/dukesc/.ssh/nnm/id_rsa -o ConnectTimeout=30 -o StrictHostKeyChecking=no <user>@localhost -p 8998 "grep -c busy /data3/home/ops/BulkStatusReport/$date-*/logs/audit.log" >> $logfile

   PREV_CNT=`tail -2 $logfile | head -1 | awk '{print $2}'`
   CURR_CNT=`tail -1 $logfile | awk '{print $2}'`
   DIFF=(($CURR_CNT - $PREV_CNT))

   if [ $DIFF -gt 50 ]; then

      echo "Current BFST audit.log showing $DIFF "Busy" errors in last 5 mins" | mailx -s "ALERT - RDU Busy errors reported" -r noreply@<domainname>.com <user>@<domainname>.com

   fi
   echo "Check completed"
fi

### EOF ###
