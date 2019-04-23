#!/bin/bash
#
# Copyright (c) 2014 Cisco Solutions Support
#
# by:                   Chris Dukes
# title:                TCP Connection Monitor
# name:                 TCPconns.sh
# desc:                 The script monitors the number of TCP connections
#                       on port 8081 between the Stats Server and the 4710.
#                       If the number of connections exceeds a threshold,
#                       an email notification is sent.
#

# List of email addresses to send the notification
# Put a space between multiple email addresses
EMAIL_TO="<user>@<domainname>.com"

# TCP connection threshold
TCPmax=300

### Do NOT edit below this line ###

date=`date +%m/%d/%y`
time=`date +%H:%M`
repdate=`date +%x`
reptime=`date +%X`
host=`hostname`
TCPlog="/export/home/cfscisco/TCPconn_cnt.csv"
rtrn="${host}@avnosstools1.ner.cingular.net"

# Begin Check

CurrOpen=`netstat -s | grep  tcpPassiveOpens | awk -F= '{ print $3 }' | sed -e 's/^ *//' -e 's/ *$//'`
PrevOpen=`cat /export/home/cfscisco/PrevOpen.dat`
let Open15min=$CurrOpen-$PrevOpen
echo $CurrOpen > /export/home/cfscisco/PrevOpen.dat
TCPcnt=`netstat -an | grep 8081 | wc -l | sed -e 's/^ *//' -e 's/ *$//'`
ESTcnt=`netstat -an | grep 8081 | grep -c ESTABLISHED | sed -e 's/^ *//' -e 's/ *$//'`
WAITcnt=`netstat -an | grep 8081 | grep -c TIME_WAIT | sed -e 's/^ *//' -e 's/ *$//'`

echo "${date},${time},${TCPcnt},${ESTcnt},${WAITcnt},${Open15min}" >> ${TCPlog}

if [ $TCPcnt -gt $TCPmax ];
then
   echo "${repdate}-${reptime}: ${host} reports ${TCPcnt} current TCP connections for port 8081." | mailx -s "${host} ALERT - TCP Connections High" -r $rtrn $EMAIL_TO
fi

# EOF #
