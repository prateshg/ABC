#!/usr/bin/zsh

if [ $1 = "abc" ] ; then
	killall python
	python server.py &
	mm-delay 50 mm-link --uplink-log=logs/$2-$1.log --uplink-queue=cellular --uplink-queue-args=\"packets=250,qdelay_ref=50,beta=75\" ~/Cellular-AQM/mahimahi/traces/$2 ~/bw48.mahi python client.py 
	killall python
fi

if [ $1 = "cubic" ] ; then
	killall iperf
	killall iperf
	iperf -s -p 42425 -w 16m &
	mm-delay 50 mm-link --uplink-log=logs/$2-$1.log --uplink-queue=droptail --uplink-queue-args=\"packets=100\" ~/Cellular-AQM/mahimahi/traces/$2 ~/bw48.mahi ./start-tcp.sh cubic
	killall iperf
	killall iperf
fi

if [ $1 = "vegas" ] ; then
	killall iperf
	killall iperf
	iperf -s -p 42425 -w 16m &
	mm-delay 50 mm-link --uplink-log=logs/$2-$1.log --uplink-queue=droptail --uplink-queue-args=\"packets=250\" ~/Cellular-AQM/mahimahi/traces/$2 ~/bw48.mahi ./start-tcp.sh vegas
	killall iperf
	killall iperf
fi

if [ $1 = "cubiccodel" ] ; then
	killall iperf
	killall iperf
	iperf -s -p 42425 -w 16m &
	mm-delay 50 mm-link --uplink-log=logs/$2-$1.log --uplink-queue=codel --uplink-queue-args=\"packets=100,target=50,interval=100\" ~/Cellular-AQM/mahimahi/traces/$2 ~/bw48.mahi ./start-tcp.sh cubic
	killall iperf
	killall iperf
fi

if [ $1 = "cubicpie" ] ; then
	killall iperf
	killall iperf
	iperf -s -p 42425 -w 16m &
	mm-delay 50 mm-link --uplink-log=logs/$2-$1.log --uplink-queue=pie --uplink-queue-args=\"packets=100,qdelay_ref=50,max_burst=100\" ~/Cellular-AQM/mahimahi/traces/$2 ~/bw48.mahi ./start-tcp.sh cubic
	killall iperf
	killall iperf
fi

if [ $1 = "bbr" ] ; then
	killall iperf
	killall iperf
	iperf -s -p 42425 -w 16m &
	mm-delay 50 mm-link --uplink-log=logs/$2-$1.log --uplink-queue=droptail --uplink-queue-args=\"packets=100\" ~/Cellular-AQM/mahimahi/traces/$2 ~/bw48.mahi ./start-tcp.sh bbr
	killall iperf
	killall iperf
fi
