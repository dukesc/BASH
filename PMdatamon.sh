#!/bin/bash
#
# Copyright (c) 2014 Cisco Solutions Support
#
# by:                   Chris Dukes
# title:                PM Data Filesize Monitor
# name:                 PMdatamon.sh
# desc:                 The script monitors the filesize of the PM data
#                       CSV archives.  If the filesize drops below a
#                       threshold, an email notification is sent.
#

# List of email addresses to send the notification
# Put a space between multiple email addresses
EMAIL_TO="<user>@<domainname>.com"

# PM Data Archive filesize threshold (MB)
FSmin=20

### Do NOT edit below this line ###

date=`date +%m%d%y`
time=`date +%H%M`
repdate=`date +%x`
reptime=`date +%X`
host=`hostname`
ARCDIR="/opt/OVPI/stat/exportBox"
rtrn="${host}@<domainname>.net"

# Begin Check

eval $(date +Y=%Y\;m=%m\;d=%d\;H=%H\;M=%M)
if   [[ "$M" < "15" ]] ; then M=00
elif [[ "$M" < "30" ]] ; then M=15
elif [[ "$M" < "45" ]] ; then M=30
else M=45
fi

TS="${Y}${m}${d}_${H}${M}"
echo "TS=${TS}"
FSnow=`du -h ${ARCDIR}/outbox.${TS}.tar | awk '{ print $1 }' | sed -e 's/M//'`
echo "FSnow=${FSnow}"
if [ $FSnow -lt $FSmin ];
then
   echo "${repdate}-${reptime}: ${host} reports ${FSnow}M PM data archive created." | mailx -s "${host} ALERT - Possible missing PM data" -r $rtrn $EMAIL_TO
fi

# EOF #
