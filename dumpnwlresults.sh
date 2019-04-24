#
# helper script to dump NWL information from Basic OAM database
#
# only information from APs with serial numbers listed in dumpnwlresults_serials.txt
# will be collected
#
USER=<oam-user>
# leave empty to be prompted
PASS=
DB=oam
SNS=`cat dumpnwlresults_serials.txt | tr -d "\r"`

SNLIST=
for sn in $SNS; do
	if [ "$sn" = "" ]; then
		continue
	fi
	if [ "$SNLIST" != "" ];  then
		SNLIST="$SNLIST,'$sn'"
	else
		SNLIST="'$sn'"
	fi
done

# dump nwl_boards table so we can do id to serial lookup later
mysqldump -u$USER -p$PASS $DB nwl_boards --where="serialnum IN($SNLIST)" > nwl_boards_calldrops.sql

# now get id from serial list to dump individual AP info
OP=`mysql -u$USER -p$PASS -D$DB << EOQ
SELECT id FROM nwl_boards WHERE serialnum IN($SNLIST)
EOQ`
IDLIST=
for id in $OP; do
	if [ "$id" = "id" -o "$id" = "" ]; then
		continue
	fi
	if [ "$IDLIST" != "" ];  then
		IDLIST="$IDLIST,'$id'"
	else
		IDLIST="'$id'"
	fi
done
if [ "$IDLIST" = "" ]; then
	echo "No results found"
	exit 0
fi
for table in nwl_detected_cells nwl_autoprov_results; do
	mysqldump -u$USER -p$PASS $DB $table --where="board_id IN($IDLIST)" > ${table}_calldrops.sql
done
ls -la *_calldrops.sql
