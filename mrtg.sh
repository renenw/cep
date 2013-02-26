# snmp bandwidth
ORIGINAL_IFS=$IFS
IFS=$'\n'
for line in $(head /var/www/mrtg/192.168.0.1_9.log -n1); do
    echo "bandwidth $line" | nc 192.168.0.252 54545 -w1 -u
done
IFS=$ORIGINAL_IFS


