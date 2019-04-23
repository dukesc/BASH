#!/bin/bash
#
# Copyright (c) 2016 Cisco Solutions Support
#
# by:                   Chris Dukes
# title:                PS Drop Checks
# name:                 PSdrpchk.sh
# desc:                 The script executes the psDropsCalc-v3.py script against
#                       the previous days debug log collection to generate the
#                       PM counters for "PS drops" and "PS drops due to cell drag".

## Config variables - do not change
date=`date +'%B %d, %Y'`
time=`date +%R`
file_ts=`date +%y%m%d`
scriptdir="/home/<user>/scripts/"
logsdir="/home/<mechid>/bundles"

# List of email addresses to send the PM counters to
# Put a space between multiple email addresses
EMAIL_TO="<user>@<domainname>.com"

## Start Main Script ##

SNJPresults=`py ${scriptdir}psDropsCalc-v3.py ${logsdir}/*SNJPCAWFCRA.${file_ts}*`
MRHHresults=`py ${scriptdir}psDropsCalc-v3.py ${logsdir}/*MRHHMOFBCRA.${file_ts}*`

echo "SNJP results"
echo ""
echo $SNJPresults
echo ""
echo "--------"
echo ""
echo "MRHH"
echo ""
echo $MRHHresults

#EOF#
