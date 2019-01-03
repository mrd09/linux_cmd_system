
# /etc/network/interfaces.d/99-eth1.cfg:

```
# interface config
auto {{ ifname }}
iface {{ ifname }} inet static
    address {{ confidential_ip_addr }}
    netmask {{ ansible_default_ipv4.netmask }}
    network {{ ansible_default_ipv4.network }}
    broadcast {{ ansible_default_ipv4.broadcast }}
    pre-up ifup {{ ansible_default_ipv4.interface }}

# gateway config
    up ip route add default via {{ ansible_default_ipv4.gateway }} dev {{ ifname }} table 201
```

- IFACE OPTIONS : in which case the commands are executed in the order in which they appear in the stanza.  (You can ensure a command never fails by suffixing them with ``"|| true"``.)
```
pre-up command
              Run  command  before  bringing  the  interface up.  If this command fails then ifup
              aborts, refraining from marking  the  interface  as  configured,  prints  an  error
              message, and exits with status 0.  This behavior may change in the future.

up command

post-up command
              Run  command  after  bringing  the  interface  up.  If this command fails then ifup
              aborts, refraining from marking the interface as configured  (even  though  it  has
              really  been  configured),  prints an error message, and exits with status 0.  This
              behavior may change in the future.              
```
- INET ADDRESS FAMILY
```
This section documents the methods available in the inet address family.

   The static Method
       This method may be used to define  Ethernet  interfaces  with  statically  allocated  IPv4
       addresses.

      Options

              address address
                     Address (dotted quad/netmask) required

              netmask mask
                     Netmask (dotted quad or CIDR)

              broadcast broadcast_address
                     Broadcast address (dotted quad, + or -). Default value: "+"
                     
              gateway address
                     Default gateway (dotted quad)

```

# Policy-based routing
- **Policy-based routing (PBR)** in Linux is designed the following way: 
	+ first you **create *custom routing tables***, 
	+ then you **create *rules* to tell the kernel it should *use those tables instead of the default table* for specific traffic**.

- Some **tables are predefined**:
	+ ***local (table 255)*** 		: 	Contains control routes local and broadcast addresses.
	+ ***main (table 254)*** 		: 	Contains all non-PBR routes. If you don't specify the table when adding a route, it goes here.
	+ ***default (table 253)*** 	: 	Reserved for post processing, normally unused.
	+ ***User-defined tables*** 	: 	are created automatically when you add the first route to them.

## Create a policy route to a routing table

- Syntax: ```ip route add ${route options} table ${table id or name}```
```
Examples:
ip route add 192.0.2.0/27 via 203.0.113.1 table 10
ip route add 0.0.0.0/0 via 192.168.0.1 table ISP2
ip route add 2001:db8::/48 dev eth1 table 100
```

- To create your own symbolic names, edit ***/etc/iproute2/rt_tables*** config file.
```
"ip route ... table main" or "ip route ... table 254" would have exact same effect to commands without a table part.
```
- ***View policy routes*** : 	```ip route show table ${table id or name}```
```
Examples:
ip route show table 100
ip route show table test
```

## Create rule to use created routing table:
- General rule syntax: 	```ip rule add ${options} <lookup ${table id or name}|blackhole|prohibit|unreachable>```
  + ***"lookup"*** action : Traffic that matches the ${options} (described below) will be routed according to the table with specified name/id instead of the "main"/254 table	
  + ***"blackhole", "prohibit", and "unreachable"*** actions that work the same way to route types with same names. 
  + For **IPv6 rules, use "ip -6"**, the rest of the syntax is the same.

- In most of examples we will use "lookup" action as the most common.
- ***Create a rule to match a source network***
```ip rule add from ${source network} ${action}```
```
Examples:
ip rule add from 192.0.2.0/24 lookup 10
ip -6 rule add from 2001:db8::/32 prohibit
```
- ***Create a rule to match a destination network***
```ip rule add to ${destination network} ${action}```
```
Examples:

ip rule add to 192.0.2.0/24 blackhole

ip -6 rule add to 2001:db8::/32 lookup 100
```