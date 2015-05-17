#!/bin/bash

#target="ftp://ftp-test.telkomadsl.co.za/500K-test.file"
#size=512000
target="ftp://ftp-test.telkomadsl.co.za/2Meg-test.file"
size=2048000

TIMEFORMAT='%6R'

# Make sure things are clear
rm -f /tmp/download_test.t1
rm -f /tmp/download_test.t2
rm -f /tmp/download_test.t3
rm -f /tmp/download_test.t4

# Get the file repeatedly
t1=$( { time curl -s "$target" -o /home/renen/cep/scripts/download_tests/download_test.t1 > /tmp/download_test.t1; } 2>&1 )
t2=$( { time curl -s "$target" -o /home/renen/cep/scripts/download_tests/download_test.t2 > /tmp/download_test.t2; } 2>&1 )
t3=$( { time curl -s "$target" -o /home/renen/cep/scripts/download_tests/download_test.t3 > /tmp/download_test.t3; } 2>&1 )
t4=$( { time curl -s "$target" -o /home/renen/cep/scripts/download_tests/download_test.t4 > /tmp/download_test.t4; } 2>&1 )

# Confirm file sizes
s1=$(stat -c%s "/tmp/download_test.t1")
s2=$(stat -c%s "/tmp/download_test.t2")
s3=$(stat -c%s "/tmp/download_test.t3")
s4=$(stat -c%s "/tmp/download_test.t4")

# Make sure we got down a file
if [ "$s1" -ne "$size" ] ; then
	error="Sizes differ"
fi
if [ "$s2" -ne "$size" ] ; then
	error="Sizes differ"
fi
if [ "$s3" -ne "$size" ] ; then
	error="Sizes differ"
fi
if [ "$s4" -ne "$size" ] ; then
	error="Sizes differ"
fi

# log the result
if [ -z "$error" ] ; then
	echo "bandwidth_throughput $size $t1 $t2 $t3 $t4" | nc 192.168.0.252 54545 -w1 -u
fi

