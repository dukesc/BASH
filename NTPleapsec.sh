#!/bin/bash
#
# Copyright (c) 2015 Cisco TS Solutions Support
#
# by:                   Chris Dukes
# title:                NTP Leap Second
# name:                 NTPleapsec.sh
# desc:                 The script automatically stops, starts or gets the 
#                       status of the ntpd on all Meinberg NTP servers.

# Source function library.
. /export/home/localadm/scripts/bin/functions

#Begin script
act=$1

start() {
	for i in `cat /export/home/localadm/scripts/conf/NTPleapsec.conf`
	do

	    NTPip=`echo $i | awk 'BEGIN{FS=","}{print $1}'`
	    NTPhost=`echo $i | awk 'BEGIN{FS=","}{print $2}'`
	    status_out="-1"
	    echo "Starting ${NTPhost} - ${NTPip}"

	    ssh root@${NTPip} "/etc/init.d/ntpservice start > /dev/null"
	    sleep 5
            status_out=$(ssh root@${NTPip} "/etc/init.d/ntpservice status")
            echo "    ${status_out}"

	done

        echo ""
	echo "Script complete"

}

stop () {
        for i in `cat /export/home/localadm/scripts/conf/NTPleapsec.conf`
        do

            NTPip=`echo $i | awk 'BEGIN{FS=","}{print $1}'`
            NTPhost=`echo $i | awk 'BEGIN{FS=","}{print $2}'`
	    status_out="-1"
            echo "Stopping ${NTPhost} - ${NTPip}"

            ssh root@${NTPip} "/etc/init.d/ntpservice stop > /dev/null"
            sleep 5
            status_out=$(ssh root@${NTPip} "/etc/init.d/ntpservice status")
            echo "    ${status_out}"

        done

        echo ""
        echo "Script complete"

}

status () {
        for i in `cat /export/home/localadm/scripts/conf/NTPleapsec.conf`
        do

            NTPip=`echo $i | awk 'BEGIN{FS=","}{print $1}'`
            NTPhost=`echo $i | awk 'BEGIN{FS=","}{print $2}'`
	    status_out="-1"
            echo "${NTPhost} - ${NTPip}"

            status_out=$(ssh root@${NTPip} "/etc/init.d/ntpservice status")
            echo "    ${status_out}"
        
        done

	echo ""
        echo "Script complete"

}

case "$1" in
  start)
        echo "Starting NTP daemons on Meinbergs..."
        start
        ;;
  stop)
        echo "Stopping NTP daemons on Meinbergs..."
        stop
        ;;
  status)
	echo "Checking NTP status on Meinbergs..."
	status
	;;
  *)
        echo $"Usage: $0 {start|stop|status}"
        exit 2
esac
#EOF
