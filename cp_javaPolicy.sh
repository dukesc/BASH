#!/usr/bin/sh
####################################################################
# The purpose of this script is to copy .java.policy file to
# the users home directory. This file is required to start WEM GUI.
#
# If there is an issue with the script please inform
# Chris Dukes "<user>@<domainname>.com"
####################################################################

cat /etc/passwd | while read line
do
    HOMEDIR=` echo $line | awk -F: '{print $6}' | grep home | egrep -v 'ctx|oracle|deleteme'`
    OWNER=` echo $line | awk -F: '{print $1}'`
    if [ -d "$HOMEDIR" ]
    then
        cp -p /export/home/.java.policy  $HOMEDIR/.java.policy
        chown $OWNER $HOMEDIR/.java.policy
    fi
done
