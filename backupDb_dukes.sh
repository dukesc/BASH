#!/bin/sh
#****************************************************
#         Copyright (c) 2015 Cisco Systems, Inc.     
#         All rights reserved.                       
#****************************************************

#@echo off
# Relative path from binary to root of CSRC
BIN_TO_HOME=../..

# Get the directory from the program and make absolute
EXEC_DIR=$1
PROG_DIR=`dirname $0`
BPR_HOME=`cd ${PROG_DIR} ; cd ${BIN_TO_HOME} ; pwd`

# Include the definitions for BPR
. ${BPR_HOME}/bpr_definitions.sh

validate_root()
{
    case `id` in
        uid=0*) ;;

        *)
	    echo ""
            echo "ERROR: Must be root to use this tool"
            echo ""
            exit 1
            ;;
    esac
}

checkDiskSpace()
{

    DBDIR=$BPR_DATA/rdu/db
    DBLOGDIR=$BPR_DBLOG/rdu/dblog
    historylogsize=0
    dbsize=0
    dblogsize=0

    pathname=$1
    c=`echo $pathname|cut -c1` 
    if [ c != '/' ]; then
        pathname=`cd $pathname; pwd` 
    fi


    numlogs=`ls $DBLOGDIR | grep log | wc -l` 
    if [ ! -f $DBDIR/rdu.db  -o  $numlogs -lt 1 ]; then
	echo ""
        echo "ERROR: Database file missing."
	echo ""
        exit 1
    fi

    dbsize=`du -k $DBDIR/rdu.db|awk '{ print $1 }'`
    dblogsize=`expr 10 \* 1024 \* $numlogs`

    if [ -f $DBDIR/history.log ]; then
        historylogsize=`du -k $DBDIR/history.log|awk '{ print $1 }'`
    fi
    
    total=`expr $dbsize + $dblogsize + $historylogsize`
    required=`echo "$total * 1.2" | bc`
   

    for dir in `df | awk '{ print $1 }' | sort -r`
    do
        echo $pathname | /usr/xpg4/bin/grep -q "^$dir"
   	if [ $? = 0 ]; then
    	    disk=$dir
    	    break
  	fi
    done

    available=`df -k $disk | tail -1 | awk '{ print $4 }'`

    if [ $available -lt $required ]; then
        echo ""
        echo "ERROR: Not enough disk space, backup aborted."
	echo "       Need at least" $required "kbytes of disk space"
        echo ""
        exit 1
    fi

}

validate_root


if [ $# != 0 ]; then
    if [ $1 != "-help" ]; then
       if [ -d $1 ]; then 
         checkDiskSpace $1
.
	 # don't check it the path relative, directory does not exit 
	 # and path includes "../" characters
         # the tool is smart to handle out of disk space errors, so it it ok.
       fi
       
    fi
fi

DIRNAM="rdu-backup-"`date +%Y%m%d`"-"`date +%H%M`"*"

#The following was added for testing and can be removed
#echo "$DIRNAM"
#mkdir $EXEC_DIR/rdu-backup-`date +%Y%m%d`-`date +%H%M%S`
#chmod 777 $EXEC_DIR/rdu-backup-`date +%Y%m%d`-`date +%H%M%S`
#touch $EXEC_DIR/rdu-backup-`date +%Y%m%d`-`date +%H%M%S`/filea.txt
#touch $EXEC_DIR/rdu-backup-`date +%Y%m%d`-`date +%H%M%S`/fileb.txt
#touch $EXEC_DIR/rdu-backup-`date +%Y%m%d`-`date +%H%M%S`/filec.txt

$BPR_JAVA -DBPR_HOME="$BPR_HOME" -DBPR_DATA="$BPR_DATA" -DBPR_DBLOG="$BPR_DBLOG" -classpath "$BPR_CP" com.cisco.csrc.db.util.BackupDb $1 $2 $3 $4 $5 $6 $7 $8 $9 

tar -cf - $EXEC_DIR/$DIRNAM | gzip -9 > $EXEC_DIR/rdu-backup-arc`date +%Y%m%d`"-"`date +%H%M%S`.tgz
rm -fr $EXEC_DIR/$DIRNAM
