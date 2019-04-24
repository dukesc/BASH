#!/bin/bash

#This script checks to see if the certificate server is running or not. If it is running, then no notifications will be sent.
#If the service is not running, it will attempt to start the service, and notify the admins.

#
#Set variables
#
#Set the email addresses of the admins
ADMINS='<user>@<domainname>.com'
#
#Get the hostname of this machine
MYNAME=`hostname`

#See if Certificate Server is running.
OUTPUT=`/opt/OV/bin/OpC/opcsv -status | grep ovcs | cut -d ")" -f2-8 | sed 's/^[ \t]*//;s/[ \t]*$//'`
if [[ "$OUTPUT" == "is running" ]]; then
        #Service appears to be running, let's exit.
        exit;
else
        #Service doesn't seem to be running, let's get the whole output that claims the service wasn't started.
        ERROR=`/opt/OV/bin/OpC/opcsv -status | grep ovcs`
        #Now we'll try to start the service
        /opt/OV/bin/ovc -start ovcs
        #Now get the status again to see if the service is running.
        CURRENTSTATUS=`/opt/OV/bin/OpC/opcsv -status | grep ovcs | cut -d ")" -f2-8 | sed 's/^[ \t]*//;s/[ \t]*$//'`
        if [[ "$CURRENTSTATUS" == "is running" ]]; then
                #It seems we were able to successfully restart the service.
               BODYPART2=" it appears the service is now running."
            echo "$OUTPUT " Restarted" | /export/home/cfsuser/bin/logit.sh ovcs_chk
        else
            echo "$OUTPUT Cannot Restart!!" | /export/home/cfsuser/bin/logit.sh ovcs_chk
               BODYPART2=" it seems I was unable to successfully restart the service. An admin needs to investigate immediately!"
        fi
        #We are now ready to compile our information into an email to send to the admins.
        BODYPART1="The Certficate Server service on "$MYNAME" was not running when I last checked, as evidenced by this message:"\"$ERROR\"" I have attempted to restart the service, "
        #Mail the admins
        echo $BODYPART1 $BODYPART2 | mailx -s `hostname`"-Certificate Server Alert!" $ADMINS
fi
