ACID=`echo "1000 + $1"|bc|sed -e "s/^1//"`
ACIP1=`echo "194 + (2 * $1)"|bc`
ACIP2=`echo "195 + (2 * $1)"|bc`

echo "$ACID, $ACIP1, $ACIP2"

/bin/sh << EOF &
while [ 1 = 1 ]
do
   sleep 1
   /usr/sbin/tshark -q -i bond1 -n -b duration:3600 \
        -w /wireshark_logs/AC_$ACID/ALL.cap \
        -f "(host x.x.x.$ACIP1 or host x.x.x.$ACIP2) and (tcp port 3052 or icmp) and not host x.x.x.x and not host x.x.x.x" 
done
EOF
#
