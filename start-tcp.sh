#!/usr/bin/zsh

if [ $1 = "bbr" ] ; then
	sudo tc qdisc add dev ingress root fq pacing
	sudo tc qdisc show dev ingress
fi
iperf -c $MAHIMAHI_BASE -p 42425 -w 16m -t 140 -Z $1 &
sleep 140
killall iperf
killall iperf
