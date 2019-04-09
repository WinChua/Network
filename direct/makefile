netnss:
	ip netns add host2
	ip netns exec host2 hostname host2
	ip netns add host1
	ip netns exec host1 hostname host1




setuphost:
	brctl addbr br0
	ip link add v1 type veth peer name vp1
	ip link add v2 type veth peer name vp2
	brctl addif br0 v1
	brctl addif br0 v2
	ifconfig br0 up
	ifconfig v1 up
	ifconfig v2 up
	ip link set vp1 netns host1
	ip netns exec host1 ip link set dev vp1 name eth1
	ip netns exec host1 ifconfig eth1 10.10.0.1/24 up
	ip link set vp2 netns host2
	ip netns exec host2 ip link set dev vp2 name eth1
	ip netns exec host2 ifconfig eth1 10.10.0.2/24 up

delns:
	ip netns del host2
	ip netns del host1

delvs:
	ifconfig br0 down
	brctl delbr br0


init: netnss setuphost consetup docker_sim ip_forward conf_route


clean: delvs delns delcon 

consetup:
	ip netns add con1
	ip netns exec con1 hostname con1
	ip netns add con2
	ip netns exec con2 hostname con2

delcon:
	ip netns del con1
	ip netns del con2

docker_sim:
	ip netns exec host1 brctl addbr docker0
	ip netns exec host1 ifconfig docker0 172.17.1.254/24 up
	ip netns exec host2 brctl addbr docker0
	ip netns exec host2 ifconfig docker0 172.17.2.254/24 up
	ip netns exec host1 ip link add veth type veth peer name veth-0
	ip netns exec host2 ip link add veth type veth peer name veth-0
	ip netns exec host1 ip link set veth-0 netns con1
	ip netns exec host2 ip link set veth-0 netns con2
	ip netns exec con1 ip link set veth-0 name eth0
	ip netns exec con1 ifconfig eth0 172.17.1.1/24 up
	ip netns exec con2 ip link set veth-0 name eth0
	ip netns exec con2 ifconfig eth0 172.17.2.1/24 up
	ip netns exec host1 ifconfig veth up
	ip netns exec host2 ifconfig veth up
	ip netns exec host1 brctl addif docker0 veth
	ip netns exec host2 brctl addif docker0 veth

ip_forward:
	ip netns exec host1 sysctl -w net.ipv4.ip_forward=1
	ip netns exec host2 sysctl -w net.ipv4.ip_forward=1
	ip netns exec con1 sysctl -w net.ipv4.ip_forward=1
	ip netns exec con2 sysctl -w net.ipv4.ip_forward=1
	sysctl -w net.ipv4.ip_forward=1

unip_forward:
	ip netns exec host1 sysctl -w net.ipv4.ip_forward=0
	ip netns exec host2 sysctl -w net.ipv4.ip_forward=0
	ip netns exec con1 sysctl -w net.ipv4.ip_forward=0
	ip netns exec con2 sysctl -w net.ipv4.ip_forward=0
	sysctl -w net.ipv4.ip_forward=0

conf_route: con1_route con2_route host1_route host2_route
	#ip netns exec con1 route add default gw 172.17.1.1
	#ip netns exec con2 route add default gw 172.17.2.1



con1_route:
	ip netns exec con1 route add -net 10.10.0.0/24 gw 172.17.1.254
	ip netns exec con1 route add -net 172.17.2.0/24 gw 172.17.1.254
	ip netns exec con1 route add 172.17.2.254 gw 172.17.1.254

con2_route:
	ip netns exec con2 route add -net 10.10.0.0/24 gw 172.17.2.254
	ip netns exec con2 route add -net 172.17.1.0/24 gw 172.17.2.254
	ip netns exec con2 route add 172.17.1.254 gw 172.17.2.254

host1_route:
	ip netns exec host1 route add -net 172.17.2.0/24 gw 10.10.0.2
	ip netns exec host1 route add 172.17.2.254 gw 10.10.0.2

host2_route:
	ip netns exec host2 route add -net 172.17.1.0/24 gw 10.10.0.1
	ip netns exec host2 route add 172.17.1.254 gw 10.10.0.1
test:
	ip netns exec con1 ping 172.17.2.1 -c 1
	ip netns exec con2 ping 172.17.1.1 -c 1
