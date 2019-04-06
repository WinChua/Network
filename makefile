GW=$$(ip route | grep default | cut -d ' ' -f 3)
IP=$$(ifconfig | grep -o 'inet .* n' | cut -d ' ' -f 2 | grep -v '127' | tail -n1)

help:
	@echo "several network mode"
	@echo "    nat: make nat"
	@echo "    nat-test: make nat_test"
	@echo "              to ping the gateway and ip"

nat: create_ns local_up create_vir set_ns veth-a-ip veth-b-ip add_default_gw_veth_b ipforward
nat_test: test_host test_gw

ipforward:
	echo 1 > /proc/sys/net/ipv4/ip_forward

no_ipforward:
	echo 0 > /proc/sys/net/ipv4/ip_forward
create_ns:
	ip netns add nstest
delete_ns:
	ip netns dele nstest
enter_ns:
	ip netns exec nstest /bin/bash
local_up:
	ip netns exec nstest ifconfig lo up
local_down:
	ip netns exec nstest ip link set dev lo down
create_vir:
	ip link add veth-a type veth peer name veth-b
set_ns:
	ip link set veth-b netns nstest

veth-a-ip:
	# ip addr add dev veth-a 10.10.0.1/24
	# if use `ip addr add` to specify the ip for a dev, 
	# the route info will not set automatically.
	# Additionally, you should use:
	#     route add -net 10.10.0.0/24 dev veth-a
	# so, suggest to use ifconfig to assign a ip for a dev.
	ifconfig veth-a 10.10.0.1/24

veth-b-ip:
	# ip netns exec nstest ip addr add dev veth-b 10.10.0.2/24
	# ip netns exec nstest route add -net 10.10.0.0/24 dev veth-b
	ip netns exec nstest ifconfig veth-b 10.10.0.2/24

add_default_gw_veth_b:
	ip netns exec nstest route add default gw 10.10.0.1 dev veth-b
clean: delete_ns no_ipforward

test_host:
	@ip netns exec nstest ping ${IP} -c 1

test_gw:
	@ip netns exec nstest ping ${GW} -c 1
