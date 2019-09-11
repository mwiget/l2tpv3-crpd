# l2tpv3-crpd

Early steps in running two cRPD containers over a l2tpv3 tunnel provided by snabb. 
Requires modified l2vpn branch forked from https://github.com/alexandergall/snabbswitch/tree/l2vpn:
https://github.com/mwiget/snabb/tree/l2tpv3-rawsocket


```
crpd1 ------ snabb1 ---- ipv6 ----- snabb2 ---- crpd2
```

To bring up the topo, use

```
$ make up
docker-compose kill
sudo rm -rf /var/run/snabb
docker-compose up -d
Creating network "l2tpv3-crpd_net1-site1" with the default driver
Creating network "l2tpv3-crpd_net2-site2" with the default driver
Creating network "l2tpv3-crpd_net0-public" with the default driver
Creating crpd2  ... done
Creating snabb1 ... done
Creating crpd1  ... done
Creating snabb2 ... done
docker exec crpd1 ifconfig eth0 192.168.168.1/24
docker exec crpd2 ifconfig eth0 192.168.168.2/24
```

Then from another terminal window, watch the log files of either snabb instance:

```
$ docker logs -f snabb1
/u/snabb1.conf.txt: loading compiled configuration from /u/snabb1.conf.txt.o
/u/snabb1.conf.txt: compiled configuration is up to date.
Setting up interface TenGigE0/0
2019-09-10 05:39:43: INFO: Starting worker control_plane.
2019-09-10 05:39:43: INFO: Starting worker data_plane.
2019-09-10 05:39:43: INFO: Worker control_plane has started (PID 7).
2019-09-10 05:39:43: INFO: Worker data_plane has started (PID 8).
RawSocket:new ifname=eth0
alias: symlink /var/run/snabb/7/group/interlink/ilink_from_cc_snabb1_myvpn_pw_B.interlink to /var/run/snabb/7/interlink/transmitter/ilink_from_cc_snabb1_myvpn_pw_B.interlink
marcel filename=/sys/class/net/eth0/address
marcel macaddr=02:42:0a:14:00:03=
[mounting /var/run/snabb/hugetlbfs]
hugetlb mmap failed (Cannot allocate memory), falling back.
RawSocket:new ifname=eth1
marcel filename=/sys/class/net/eth1/address
marcel macaddr=02:42:c0:a8:65:03=
alias: symlink /var/run/snabb/8/group/interlink/ilink_from_cc_snabb1_myvpn_pw_B.interlink to /var/run/snabb/8/interlink/receiver/ilink_from_cc_snabb1_myvpn_pw_B.interlink
alias: done. Ignoring errors
alias: symlink /var/run/snabb/8/group/interlink/ilink_to_cc_snabb1_myvpn_pw_B.interlink to /var/run/snabb/8/interlink/transmitter/ilink_to_cc_snabb1_myvpn_pw_B.interlink
alias: done. Ignoring errors
  Description: AC
  L2 configuration
    MTU: 9206
    Trunking mode: disabled
Setting up interface TenGigE0/1
  Description: uplink
  L2 configuration
    MTU: 9206
    Trunking mode: disabled
  Address family configuration
    IPv6
      Address: 2001:db8:0:c101::101/64
      Next-Hop: 2001:db8:0:c101::102
Creating VPLS instance snabb1_myvpn (Endpoint A of a point-to-point L2 VPN)
  MTU: 9206
  Uplink is on TenGigE0/1
  Creating pseudowires
    pw_B
      AFI: ipv6
      Local address: 2001:db8:0:1::1
      Remote address: 2001:db8:0:1::2
      VC ID: 0
      Encapsulation: l2tpv3
      Control-channel: enabled
      IPsec: disabled
  Creating attachment circuits
    ac_A
      Interface: TenGigE0/0
Warning: No assignable CPUs declared; leaving data-plane process without assigned CPU.
Warning: No assignable CPUs declared; leaving data-plane process without assigned CPU.
No CPUs available; not binding to any NUMA node.
Sep 10 2019 05:39:48 iftable_mib: Operational status not available for interface TenGigE0/1
Sep 10 2019 05:39:48 iftable_mib: Operational status not available for interface TenGigE0/0
Sep 10 2019 05:39:48 nd_light: Resolved next-hop 2001:db8:0:c101::102 to 02:42:0a:14:00:02
alias: done. Ignoring errors
alias: symlink /var/run/snabb/7/group/interlink/ilink_to_cc_snabb1_myvpn_pw_B.interlink to /var/run/snabb/7/interlink/receiver/ilink_to_cc_snabb1_myvpn_pw_B.interlink
alias: done. Ignoring errors
Sep 10 2019 05:39:49 Pseudowire snabb1_myvpn_pw_B: Peer: 2001:db8:0:1::2: Starting remote heartbeat timer at 2 seconds
Sep 10 2019 05:39:49 Pseudowire snabb1_myvpn_pw_B: Peer: 2001:db8:0:1::2: Remote MTU change 0 => 9206
Sep 10 2019 05:39:49 Pseudowire snabb1_myvpn_pw_B: Peer: 2001:db8:0:1::2: Remote interface change '' => 'AC'
Sep 10 2019 05:39:49 Pseudowire snabb1_myvpn_pw_B: Peer: 2001:db8:0:1::2: Oper Status down => up
```

And finally the "ultimate" ping test from one cRPD to the other one:

```
$ docker exec -ti crpd1 ping 192.168.168.2
PING 192.168.168.2 (192.168.168.2) 56(84) bytes of data.
64 bytes from 192.168.168.2: icmp_seq=1 ttl=64 time=1.26 ms
64 bytes from 192.168.168.2: icmp_seq=2 ttl=64 time=10.8 ms
^C
--- 192.168.168.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 1.268/6.047/10.826/4.779 ms
```

Check BGP session between crpd1 and crpd2:

```
$ docker exec -ti crpd1 cli show bgp summary
Threading mode: BGP I/O
Groups: 1 Peers: 1 Down peers: 0
Table          Tot Paths  Act Paths Suppressed    History Damp State    Pending
inet.0
                       1          0          0          0          0          0
Peer                     AS      InPkt     OutPkt    OutQ   Flaps Last Up/Dwn State|#Active/Received/Accepted/Damped...
192.168.168.2         65000          8          8       0       0        2:25 Establ
  inet.0: 0/1/1/0
```

