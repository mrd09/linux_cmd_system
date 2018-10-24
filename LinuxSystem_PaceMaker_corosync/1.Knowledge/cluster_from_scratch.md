# 1.1. Scope
- Computer clusters can be used to provide highly available services or resources. 
	- The redundancy of multiple machines is used to guard against failures of many types.
- This document will walk through the installation and setup of simple clusters using the Fedora
distribution, version 14.

- The clusters described here will use **Pacemaker and Corosync to provide resource management and
messaging**. Required packages and modifications to their configuration files are described along with
the use of the Pacemaker command line tool for generating the XML used for cluster control.

- Pacemaker is a **central component and provides the resource management required** in these systems.
This management includes **detecting and recovering from the failure of various nodes, resources and
services under its control**.

```
The purpose of this document is to provide a start-to-finish guide to building an example active/passive
cluster with Pacemaker and show how it can be converted to an active/active one.
The example cluster will use:
	1. Fedora 13 as the host operating system
	2. Corosync to provide messaging and membership services,
	3. Pacemaker to perform resource management,
	4. DRBD (Distributed Replicated Block Device) as a cost-effective alternative to shared storage,
	5. GFS2 as the cluster filesystem (in active/active mode)
	6. The crm shell for displaying the configuration and making changes
Given the graphical nature of the Fedora install process, a number of screenshots are included.
However the guide is primarily composed of commands, the reasons for executing them and their
expected outputs.
```
```
In this document we will focus on the setup of a highly available Apache web server with an Active/
Passive cluster using DRBD and Ext4 to store data. Then, we will upgrade this cluster to Active/Active
using GFS2.
```

# 1.2. What is Pacemaker
- Pacemaker is a **cluster resource manager**. It achieves maximum availability for your cluster services (aka. resources):
	- by *detecting and recovering from node and resource-level failures* 
	- by making use of the *messaging and membership capabilities provided by your preferred cluster infrastructure (either **Corosync** or Heartbeat)*.

- **Pacemaker’s key features include**:
```
	• Detection and recovery of node and service-level failures
	• Storage agnostic, no requirement for shared storage
	• Resource agnostic, anything that can be scripted can be clustered
	• Supports STONITH for ensuring data integrity
	• Supports large and small clusters
	• Supports both quorate and resource driven clusters
	• Supports practically any redundancy configuration
	• Automatically replicated configuration that can be updated from any node
	• Ability to specify cluster-wide service ordering, colocation and anti-colocation
	• Support for advanced service types
	• Clones: for services which need to be active on multiple nodes
	• Multi-state: for services with multiple modes (eg. master/slave, primary/secondary)
	• Unified, scriptable, cluster shell
```

# 1.3. Pacemaker Architecture:
- At the highest level, the cluster is made up of three pieces:
```
Cluster Resource Management
|							|
|				Local Resource Manangement
|							|
|				Resource Agents
|
Messaging and Membership
```
```
	• Non-cluster aware components (illustrated in green). These pieces include the resources
	themselves, scripts that start, stop and monitor them, and also a local daemon that masks the
	differences between the different standards these scripts implement.
		=> Local Resource Management
		=> Resource Agents
	
	• Resource management Pacemaker provides the brain (illustrated in blue) that processes and reacts
	to events regarding the cluster. These events include nodes joining or leaving the cluster; resource
	events caused by failures, maintenance, scheduled activities; and other administrative actions.
	Pacemaker will compute the ideal state of the cluster and plot a path to achieve it after any of these
	events. This may include moving resources, stopping nodes and even forcing them offline with
	remote power switches.
		=> Pacemaker: Cluster Resource Management
	
	• Low level infrastructure Corosync provides reliable messaging, membership and quorum information
	about the cluster (illustrated in red).
		=> Messaging and Membership
```

- When combined with Corosync, Pacemaker also supports popular open source cluster filesystems. 
Due to recent standardization within the cluster filesystem community, they make use of a common
**distributed lock manager** which *makes use of Corosync for its messaging capabilities and Pacemaker
for its membership (which nodes are up/down) and fencing services*.

***Pacemaker stack:*** [Pace stack](https://wiki.clusterlabs.org/w/images/b/b5/Stack-ais.png)
```
								cLVM2	GFS2	OCFS2
							Distribute lock manager
			Pacemaker
			/	|	\
Resouce Agents	|	Corosync
			\	|	
			Cluster Glue
```			
## 1.3.1. Internal Components:
- Pacemaker itself is composed of **four key components** (illustrated below in the same color scheme as
the previous diagram):
	• CIB (aka. Cluster Information Base)
	• CRMd (aka. Cluster Resource Management daemon)
	• PEngine (aka. PE or Policy Engine)
	• STONITHd

- **Pacemaker Internals**: [Pace Internal](https://wiki.clusterlabs.org/w/images/thumb/9/9f/Stack.png/900px-Stack.png)

```
lrmd	_		PEngine 
|			\		|
STONITHd ___ \ ____CRMd _____ CIB	
|					|	   _/
Cluster abstraction layer
|					|
ccm			OR 		corosync
|
heartbeat

- linux HA project: lrmd, ccm, heartbeat
- Pacemaker project: the others
```

- The **CIB uses XML to represent both the cluster’s configuration and current state of all resources** in the cluster
	- The contents of the **CIB are automatically kept in sync across the entire cluster and are used by the PEngine** to *compute the ideal state of the cluster and how it should be achieved*.

- This **list of instructions** is then fed to the ***DC (Designated Co-ordinator). ***
	-**Pacemaker centralizes all cluster decision making by electing one of the CRMd instances to act as a master**. Should the elected CRMd process, or the node it is on, fail… a new one is quickly established.

- **The DC** carries out the **PEngine’s instructions** in the required order by *passing them to either the LRMd (Local Resource Management daemon) or CRMd peers on other nodes via the cluster messaging infrastructure (which in turn passes them on to their LRMd process)*

- **The peer nodes** all **report the results of their operations back to the DC** 
	- and **based on the expected and actual results**, will either *execute any actions that needed to wait for the previous one to complete, or abort processing* and **ask the PEngine** to *recalculate the ideal cluster state based on the unexpected results.*

- In some cases, it may be **necessary to power off nodes in order to protect shared data or complete resource recovery**. For this **Pacemaker comes with STONITHd**. 
	- **Just because a node is unresponsive, this doesn’t mean it isn’t accessing your data**. The only way to
be 100% sure that your data is safe, is to use STONITH so we can be certain that the node is truly
offline, before allowing the data to be accessed from another node.
	- STONITH is an acronym for ShootThe-Other-Node-In-The-Head and is **usually implemented with a remote power switch**. 
	- **In Pacemaker, STONITH devices are modeled as resources (and configured in the CIB)** to *enable them to be easily monitored for failure, however STONITHd takes care of understanding the STONITH topology such that its clients simply **request a node be fenced(hàng rào) and it does the rest***

# 1.4. Type of Pacemaker Cluster:
- Pacemaker makes no assumptions about your environment, this allows it to support practically any redundancy configuration3 including **Active/Active, Active/Passive, N+1, N+M, N-to-1 and N-to-N.**

- In this document we will focus on the setup of a highly available Apache web server with an ***Active/
Passive cluster using DRBD and Ext4 to store data***. Then, we will **upgrade this cluster to Active/Active
using GFS2**.

- Active/Passive model:[Active/Passive](https://wiki.clusterlabs.org/w/images/1/1f/Pacemaker-active-passive.png)
```
			URL			URL  |
			web 			 |
Service					DB --| Synch --> DB
			File 			 |
			Storage -- Synch-| --> Storage	
			
Cluster					Pacemaker
Software				Corosync

Hardware		Host1		 | 		Host2
```

- Active/ Active: [N to N](https://wiki.clusterlabs.org/w/images/thumb/a/a9/Pacemaker-n-to-n.png/525px-Pacemaker-n-to-n.png)

# 2. Installation:
## 2.1. OS Installation
- Partition: takenote that need a separate partition for DRBD(Distribute Replicated Block Device): vg_pcmk1
- NTP: It is highly recommended to enable NTP on your cluster nodes. Doing so ensures all nodes agree on the current time and makes reading log files significantly easier. Fedora Installation - Date and Time, Fedora Installation: Enable NTP to keep the times on all your nodes consistent
```
yum install -y ntp
```
- Network configuration: Do not accept the default network settings. Cluster machines should never obtain an ip address via DHCP. Here I will use the internal addresses for the clusterlab.org network
	- IP: 192.168.9.41/24, GW: 192.168.9.1, Primary DNS: 192.168.9.1

- For simplify the testing shutdown the selinux and iptables

## 2.2. CLuster software installation:
- Install corosync, pacemaker:
```
# yum -y install corosync-1.4.9 pacemaker-1.1.18 crmsh
Installed:
  pacemaker.x86_64 0:1.1.18-3.el6                                                                                                                                          

Dependency Installed:
  ConsoleKit.x86_64 0:0.4.1-6.el6              ConsoleKit-libs.x86_64 0:0.4.1-6.el6      clusterlib.x86_64 0:3.0.12.1-84.el6   cman.x86_64 0:3.0.12.1-84.el6             
  corosync.x86_64 0:1.4.7-6.el6                corosynclib.x86_64 0:1.4.7-6.el6          cryptsetup-luks.x86_64 0:1.2.0-11.el6 cryptsetup-luks-libs.x86_64 0:1.2.0-11.el6
  cvs.x86_64 0:1.11.23-16.el6                  cyrus-sasl-md5.x86_64 0:2.1.23-15.el6_6.2 dbus.x86_64 1:1.2.24-9.el6            dmidecode.x86_64 1:2.12-7.el6             
  eggdbus.x86_64 0:0.6-3.el6                   fence-agents.x86_64 0:4.0.15-13.el6_9.2   fence-virt.x86_64 0:0.2.3-24.el6      gettext.x86_64 0:0.17-18.el6              
  gnutls-utils.x86_64 0:2.12.23-22.el6         hal.x86_64 0:0.5.14-14.el6                hal-info.noarch 0:20090716-5.el6      hal-libs.x86_64 0:0.5.14-14.el6           
  hdparm.x86_64 0:9.43-4.el6                   ipmitool.x86_64 0:1.8.15-2.el6            libibverbs.x86_64 0:1.1.8-4.el6       libnl.x86_64 0:1.1.4-2.el6                
  libqb.x86_64 0:0.17.1-2.el6                  librdmacm.x86_64 0:1.0.21-0.el6           libvirt-client.x86_64 0:0.10.2-64.el6 libxslt.x86_64 0:1.1.26-2.el6_3.1         
  lm_sensors-libs.x86_64 0:3.1.1-17.el6        modcluster.x86_64 0:0.16.2-35.el6         net-snmp-libs.x86_64 1:5.5-60.el6     net-snmp-utils.x86_64 1:5.5-60.el6        
  oddjob.x86_64 0:0.30-6.el6                   openais.x86_64 0:1.1.1-7.el6              openaislib.x86_64 0:1.1.1-7.el6       pacemaker-cli.x86_64 0:1.1.18-3.el6       
  pacemaker-cluster-libs.x86_64 0:1.1.18-3.el6 pacemaker-libs.x86_64 0:1.1.18-3.el6      parted.x86_64 0:2.1-29.el6            pciutils.x86_64 0:3.1.10-4.el6            
  perl-Net-Telnet.noarch 0:3.03-11.el6         perl-TimeDate.noarch 1:1.16-13.el6        pexpect.noarch 0:2.3-6.el6            pm-utils.x86_64 0:1.2.5-11.el6            
  polkit.x86_64 0:0.96-11.el6                  pyOpenSSL.x86_64 0:0.13.1-2.el6           python-suds.noarch 0:0.4.1-3.el6      quota.x86_64 1:3.17-23.el6                
  rdma.noarch 0:6.9_4.1-3.el6                  resource-agents.x86_64 0:3.9.5-46.el6     ricci.x86_64 0:0.16.2-87.el6          sg3_utils.x86_64 0:1.28-13.el6            
  sg3_utils-libs.x86_64 0:1.28-13.el6          tcp_wrappers.x86_64 0:7.6-58.el6          yajl.x86_64 0:1.0.7-3.el6            

Dependency Updated:
  dbus-libs.x86_64 1:1.2.24-9.el6                                                      gnutls.x86_64 0:2.12.23-22.el6  
```

## 2.3. Repeate the installation in other node

## 2.4. Setup for network, hosts, ssh
- Modify /etc/hosts:
```
[vt_admin@CMS-OPER-01 ~]$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

172.23.0.241 CMS-OPER-01   
172.23.0.242 CMS-OPER-02
```

- SSH set up:
```
SSH is a convenient and secure way to copy files and perform commands remotely. For the purposes
of this guide, we will create a key without a password (using the -N “” option) so that we can perform
remote actions without being prompted.
```

> Unprotected SSH keys, those without a password, are not recommended for servers exposed to
the outside world.
```
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i '/ForceCommand cvs server/a\AllowUsers root' /etc/ssh/sshd_config
service sshd restart
sysctl -w net.ipv6.conf.all.autoconf=0
ssh-keygen -t dsa -f ~/.ssh/id_dsa -N ""
cp ~/.ssh/id_dsa.pub ~/.ssh/authorized_keys
cd /root
scp -r .ssh cms2: or scp -r .ssh 192.168.0.156

```
- SSH verify:
```
# ssh pcmk-2 -- uname -npcmk-2
```

## 2.5. Corosync config

- corosync config:
# cp /etc/corosync/corosync.conf.example /etc/corosync/corosync.conf
# vim /etc/corosync/corosync.conf
```
totem {
	...
	interface {
		ringnumber: 0
		bindnetaddr: 172.23.0.240  ##This is the subnet, the real IP of 2 node could be: 172.23.0.241, 172.23.0.242
		mcastaddr: 239.255.1.11
		mcastport: 4000
		ttl: 1
	}
}
...
amf {
	mode: disabled
}
quorum {
provider: corosync_votequorum
expected_votes: 2
}
```
- Finally, tell Corosync to load the Pacemaker plugin.
```
# cat <<-END >>/etc/corosync/service.d/pcmk
service {
 # Load the Pacemaker Cluster Resource Manager
 name: pacemaker
 ver: 1
}
END
```
```
When run in version 1 mode, the plugin does not start the Pacemaker daemons. Instead it just
sets up the quorum and messaging interfaces needed by the rest of the stack. Starting the
dameons occurs when the Pacemaker init script is invoked. This resolves two long standing
issues:
a. Forking inside a multi-threaded process like Corosync causes all sorts of pain. This has been
problematic for Pacemaker as it needs a number of daemons to be spawned.
b. Corosync was never designed for staggered shutdown - something previously needed in
order to prevent the cluster from leaving before Pacemaker could stop all active resources.
```

## 2.6. Propagate the Configuration
Now we need to copy the changes so far to the other node:
# for f in /etc/corosync/corosync.conf /etc/corosync/service.d/pcmk /etc/hosts; do scp $f
 pcmk-2:$f ; done
corosync.conf 100% 1528 1.5KB/s 00:00
hosts 100% 281 0.3KB/s 00:00

# 3. Verify cluster installation:
## 3.1 Verify corosync installation:
- Start Corosync on the **first node**
```
# /etc/init.d/corosync start
Starting Corosync Cluster Engine ( corosync) :  [ OK ]
```

- Check the log in /var/log/message:
```
[root@CASTIS-DEV-1 ~]# grep -e "corosync.*network interface" -e "Corosync Cluster Engine" -e "Successfully read main configuration file" /var/log/messages
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [MAIN  ] Corosync Cluster Engine ('1.4.7'): started and ready to provide service.
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [MAIN  ] Successfully read main configuration file '/etc/corosync/corosync.conf'.
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [TOTEM ] The network interface [192.168.0.126] is now up.
```

```
[root@CASTIS-DEV-1 ~]# grep TOTEM /var/log/messages
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [TOTEM ] Initializing transport (UDP/IP Multicast).
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [TOTEM ] Initializing transmit/receive security: libtomcrypt SOBER128/SHA1HMAC (mode 0).
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [TOTEM ] The network interface [192.168.0.126] is now up.
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [TOTEM ] A processor joined or left the membership and a new membership was formed.
```
- With one node functional, it’s now safe to start Corosync on the **second node** as well.
```
# ssh pcmk-2 -- /etc/init.d/corosync start
Starting Corosync Cluster Engine ( corosync) :  [ OK ]
```
- Check the cluster formed correctly
```
[root@CASTIS-DEV-1 ~]# ssh cms2 -- grep TOTEM /var/log/messages
Aug 10 15:22:01 localhost corosync[28282]:   [TOTEM ] Initializing transport (UDP/IP Multicast).
Aug 10 15:22:01 localhost corosync[28282]:   [TOTEM ] Initializing transmit/receive security: libtomcrypt SOBER128/SHA1HMAC (mode 0).
Aug 10 15:22:01 localhost corosync[28282]:   [TOTEM ] The network interface [192.168.0.156] is now up.
Aug 10 15:22:01 localhost corosync[28282]:   [TOTEM ] A processor joined or left the membership and a new membership was formed.
Aug 10 15:22:01 localhost corosync[28282]:   [TOTEM ] A processor joined or left the membership and a new membership was formed.
```

## 3.2. Verify Pacemaker Installation
- Now that we have confirmed that Corosync is functional we can check the rest of the stack
```
[root@CASTIS-DEV-1 ~]# grep pcmk_startup /var/log/messages
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [pcmk  ] info: pcmk_startup: CRM: Initialized
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [pcmk  ] Logging: Initialized pcmk_startup
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [pcmk  ] info: pcmk_startup: Maximum core file size is: 18446744073709551615
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [pcmk  ] info: pcmk_startup: Service: 9
Aug  8 15:58:56 CASTIS-DEV-1 corosync[4358]:   [pcmk  ] info: pcmk_startup: Local hostname: CASTIS-DEV-1
Aug  8 16:05:30 CASTIS-DEV-1 corosync[6649]:   [pcmk  ] info: pcmk_startup: CRM: Initialized
```

- Now try starting Pacemaker and check the necessary processes have been started
```
# /etc/init.d/pacemaker start
Starting Pacemaker Cluster Manager:  [ OK ]

```
- Next, check for any ERRORs during startup - there shouldn’t be any.
```
# grep ERROR: /var/log/messages | grep -v unpack_resources
```

## 3.3. Repeat on the other node and display the cluster’s status.
```
# ssh pcmk-2 -- /etc/init.d/pacemaker start
Starting Pacemaker Cluster Manager:  [ OK ]
# crm_mon
============
Last updated: Thu Aug 27 16:54:55 2009Stack: openais
Current DC: pcmk-1 - partition with quorum
Version: 1.1.5-bdd89e69ba545404d02445be1f3d72e6a203ba2f
2 Nodes configured, 2 expected votes
0 Resources configured.
============
Online:  [ pcmk-1 pcmk-2 ]
```

# 4. Creating an Active/Passive Cluster
## 4.1. Exploring the Existing Configuration
- ***When Pacemaker starts up, it automatically records the number and details of the nodes in the cluster
as well as which stack is being used and the version of Pacemaker being used***.
	- This is what the base configuration should look like:
```
# crm configure show
node pcmk-1
node pcmk-2
property $id="cib-bootstrap-options" \
 dc-version="1.1.5-bdd89e69ba545404d02445be1f3d72e6a203ba2f" \
 cluster-infrastructure="openais" \
 expected-quorum-votes="2"
 ```
 or
 ```
 property $id="cib-bootstrap-options" \
	dc-version="1.1.10-14.el6_5.1-368c726" \
	cluster-infrastructure="classic openais (with plugin)" \
	expected-quorum-votes="2" \
	stonith-enabled="false" \
	no-quorum-policy="ignore" \
	last-lrm-refresh="1482947223"
 ```

 - For those that are not of afraid of XML, you can see the **raw configuration by appending "xml" to the
previous command**.

### 4.1.1 Disable STONITH
- Before we make any changes, its a good idea to check the validity of the configuration
```
# crm_verify -L
crm_verify[2195]: 2009/08/27_16:57:12 ERROR: unpack_resources: Resource start-up disabled
 since no STONITH resources have been defined
crm_verify[2195]: 2009/08/27_16:57:12 ERROR: unpack_resources: Either configure some or
 disable STONITH with the stonith-enabled option
crm_verify[2195]: 2009/08/27_16:57:12 ERROR: unpack_resources: NOTE: Clusters with shared
 data need STONITH to ensure data integrity
Errors found during check: config not valid -V may provide more details
```
- As you can see, the tool has found some errors.
***About the STONITH***

	- STONITH is an acronym for Shoot-The-Other-Node-In-The-Head and it protects your data from being corrupted by rogue nodes or concurrent access.

	- Just because a node is unresponsive, this doesn’t mean it isn’t accessing your data. The only way to be 100% sure that your data is safe, is to use STONITH so we can be certain that the node is truly offline, before allowing the data to be accessed from another node.



It is important to note that the use of STONITH is highly encouraged, turning it off tells the cluster to simply
**pretend that failed nodes are safely powered off**. Some vendors will even refuse to support clusters
that have it disabled.
- To disable STONITH, we set the stonith-enabled cluster option to false.
	- config node 1:
```
# crm configure property stonith-enabled=false
# crm_verify -L
```
=> With the new cluster option set, the configuration is now valid
***The use of stonith-enabled=false is completely inappropriate for a production cluster. ***

# 5. Adding a resource:
## 5.1. The first thing we should do is configure an IP address resource:
## 5.3.4. Config

The first thing we should do is configure an IP address. Regardless of where the cluster service(s)
are running, we need a consistent address to contact them on. Here I will choose and add
192.168.122.101 as the floating address, give it the imaginative name ClusterIP and tell the cluster to
check that its running every 30 seconds.
=> We will need the VIP 

The other important piece of information here is ***ocf:heartbeat:IPaddr2***.
> This tells Pacemaker three things about the resource you want to add. The first field, ocf, is the standard to which the resource script conforms to and where to find it. The second field is specific to OCF resources and tells the cluster which namespace to find the resource script in, in this case heartbeat. The last field indicates the name of the resource script.
```
LSB (Linux Standard Based) - Provided by Linux distribution. ex: '/etc/init.d/service' script.
OCF (Open Cluster Framework) - Set of tools for cluster computing. The project is part of the Linux Foundation.
```
- config node 1:
```
[root@CASTIS-DEV-1 ~]# crm configure primitive tomcat_ip ocf:heartbeat:IPaddr2 params ip="192.168.0.177" nic="eth0:1" cidr_netmask="24" op monitor interval="30s"
[root@CASTIS-DEV-1 ~]# 
[root@CASTIS-DEV-1 ~]# crm_mon
Attempting connection to the cluster...
Stack: classic openais (with plugin)
Current DC: CASTIS-DEV-1 (version 1.1.18-3.el6-bfe4e80420) - partition with quorum
Last updated: Fri Aug 10 15:41:31 2018
Last change: Fri Aug 10 15:41:27 2018 by root via cibadmin on CASTIS-DEV-1

2 nodes configured (2 expected votes)
1 resource configured

Online: [ CASTIS-DEV-1 localhost ]

Active resources:

tomcat_ip	(ocf::heartbeat:IPaddr2):	Started CASTIS-DEV-1
-----------------
[root@CASTIS-DEV-1 ~]# ifconfig 
eth0      Link encap:Ethernet  HWaddr 28:D2:44:94:3B:1D  
          inet addr:192.168.0.126  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::2ad2:44ff:fe94:3b1d/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5283853 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2868179 errors:1 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1790252146 (1.6 GiB)  TX bytes:596256576 (568.6 MiB)

eth0:1    Link encap:Ethernet  HWaddr 28:D2:44:94:3B:1D  
          inet addr:192.168.0.177  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

```

To obtain a **list of the available resource classes**, run
```
# crm ra classesheartbeat
lsb ocf / heartbeat pacemakerstonith
```
- To then find all the **OCF resource agents** provided by Pacemaker and Heartbeat, run
```
# crm ra list ocf pacemaker
ClusterMon Dummy Stateful SysInfo SystemHealth controld
ping pingd
# crm ra list ocf heartbeat
AoEtarget AudibleAlarm ClusterMon Delay
Dummy EvmsSCC Evmsd Filesystem
ICP IPaddr IPaddr2 IPsrcaddr
LVM LinuxSCSI MailTo ManageRAID
ManageVE Pure-FTPd Raid1 Route
SAPDatabase SAPInstance SendArp ServeRAID
SphinxSearchDaemon Squid Stateful SysInfo
VIPArip VirtualDomain WAS WAS6
WinPopup Xen Xinetd anything
apache db2 drbd eDir88
iSCSILogicalUnit iSCSITarget ids iscsi
ldirectord mysql mysql-proxy nfsserver
oracle oralsnr pgsql pingd
portblock rsyncd scsi2reservation sfex
tomcat vmware
#
```

- cmd to check:
```
crm_mon
============
Last updated: Fri Aug 28 15:23:48 2009
Stack: openais
Current DC: pcmk-1 - partition with quorum
Version: 1.1.5-bdd89e69ba545404d02445be1f3d72e6a203ba2f
2 Nodes configured, 2 expected votes
1 Resources configured.
============
Online:  [ pcmk-1 pcmk-2 ]
ClusterIP ( ocf::heartbeat:IPaddr) : Started pcmk-1
```
**Note that resource ClusterIP: is display**

### 5.3. Perform a Failover
- Being a high-availability cluster, we should test failover of our new resource before moving on.
First, find the node on which the IP address is running.
```
# crm resource status ClusterIP
resource ClusterIP is running on: pcmk-1
```
- Shut down Pacemaker and Corosync on that machine.
```
# ssh pcmk-1 -- /etc/init.d/pacemaker stop
Signaling Pacemaker Cluster Manager to terminate:  [ OK ]
Waiting for cluster services to unload:.  [ OK ]
# ssh pcmk-1 -- /etc/init.d/corosync stop
Stopping Corosync Cluster Engine ( corosync) :  [ OK ]
Waiting for services to unload:  [ OK ]
```
- Once Corosync is no longer running, go to the other node and check the cluster status with crm_mon.
	- because of shut down cluster service in Node 1 then can only show crm_mon in node 2:
```
# crm_mon
============
Last updated: Fri Aug 28 15:27:35 2009
Stack: classic openais (with plugin)
Current DC: localhost (version 1.1.18-3.el6-bfe4e80420) - partition WITHOUT quorum
Last updated: Fri Aug 10 15:50:21 2018
Last change: Fri Aug 10 15:41:27 2018 by root via cibadmin on CASTIS-DEV-1

2 nodes configured (2 expected votes)
1 resource configured

Online: [ localhost ]
OFFLINE: [ CASTIS-DEV-1 ]

No active resources

```
**There are three things to notice about the cluster’s current state. The first is that, as expected, pcmk-1
is now offline. However we can also see that ClusterIP(the IP resouces) isn’t running anywhere!**

## 5.3.1. Quorum and Two-Node Clusters
**the reason for above situation is that the cluster no longer has quorum**, as can be seen by the text "partition WITHOUT quorum" (emphasised green) in the output above. In order to reduce the possibility of data corruption,
Pacemaker’s default behavior is to stop all resources if the cluster does not have quorum.
A cluster is said to have quorum when more than half the known or expected nodes are online, or for
the mathematically inclined, whenever the following equation is true:

> total_nodes < 2 * active_nodes

***If run Active /Passive => can not have the quorum running because: total  = 2 < 2 * active =1 => 2 < 2 =>> wrong***
> **Therefore a two-node cluster only has quorum when both nodes are running**

- config in Node 2:
```
# crm configure property no-quorum-policy=ignore
# crm configure show
node pcmk-1
node pcmk-2
primitive ClusterIP ocf:heartbeat:IPaddr2 \
 params ip="192.168.122.101" cidr_netmask="32" \
 op monitor interval="30s"
property $id="cib-bootstrap-options" \
...
 stonith-enabled="false" \
...
 ```
- After a few moments, the cluster will start the IP address on the remaining node. Note that the cluster
still does not have quorum.
```
# crm_mon
============
Stack: classic openais (with plugin)
Current DC: localhost (version 1.1.18-3.el6-bfe4e80420) - partition WITHOUT quorum
Last updated: Fri Aug 10 15:55:50 2018
Last change: Fri Aug 10 15:55:48 2018 by root via cibadmin on localhost

2 nodes configured (2 expected votes)
1 resource configured

Online: [ localhost ]
OFFLINE: [ CASTIS-DEV-1 ]

Active resources:

tomcat_ip	(ocf::heartbeat:IPaddr2):	Started localhost
```
- show the ifconfig: the VIP is exist in Node 2:
```
[root@localhost ~]# ifconfig 
eth0      Link encap:Ethernet  HWaddr 28:D2:44:95:AD:F4  
          inet addr:192.168.0.156  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::2ad2:44ff:fe95:adf4/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5764482 errors:0 dropped:0 overruns:0 frame:0
          TX packets:40510032 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:2664997494 (2.4 GiB)  TX bytes:44796565529 (41.7 GiB)

eth0:1    Link encap:Ethernet  HWaddr 28:D2:44:95:AD:F4  
          inet addr:192.168.0.177  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
```

- Now simulate node recovery by restarting the cluster stack on pcmk-1 and check the cluster’s status.
```
# /etc/init.d/corosync start
Starting Corosync Cluster Engine ( corosync) :  [ OK ]
# /etc/init.d/pacemaker start
Starting Pacemaker Cluster Manager:  [ OK ]# crm_mon
============
```
- Show crm_mon in Node 2:
```
Last updated: Fri Aug 28 15:32:13 2009
Stack: classic openais (with plugin)
Current DC: localhost (version 1.1.18-3.el6-bfe4e80420) - partition with quorum
Last updated: Fri Aug 10 15:57:14 2018
Last change: Fri Aug 10 15:55:48 2018 by root via cibadmin on localhost

2 nodes configured (2 expected votes)
1 resource configured

Online: [ CASTIS-DEV-1 localhost ]

Active resources:

tomcat_ip	(ocf::heartbeat:IPaddr2):	Started localhost
```
***Here we see something that some may consider surprising, the IP is back running at its original
location!***

=>> If have quorum 2 node will be online now => data will not integrity anymore

## 5.3.2. Prevent Resources from Moving after Recovery
In some circumstances, it is highly desirable to prevent healthy resources from being moved around
the cluster. Moving resources almost always requires a period of downtime. For complex services like
Oracle databases, this period can be quite long.
To address this, Pacemaker has the concept of resource stickiness which controls how much a
service prefers to stay running where it is. You may like to think of it as the "cost" of any downtime. By
default, Pacemaker assumes there is zero cost associated with moving resources and will do so to achieve "optimal" 4 resource placement. We can specify a different stickiness for every resource, but it is often sufficient to change the default.
```
# crm configure rsc_defaults resource-stickiness=100
# crm configure show
node pcmk-1
node pcmk-2
primitive ClusterIP ocf:heartbeat:IPaddr2 \
 params ip="192.168.122.101" cidr_netmask="32" \
 op monitor interval="30s"
property $id="cib-bootstrap-options" \
 ...
 no-quorum-policy="ignore"r
```


## 5.3. Perform a Failover
Being a high-availability cluster, we should test failover of our new resource before moving on.
First, find the node on which the IP address is running.
```
# crm resource status ClusterIP
resource ClusterIP is running on: pcmk-1
```
- Shut down Pacemaker and Corosync on that machine.
```
# ssh pcmk-1 -- /etc/init.d/pacemaker stop
Signaling Pacemaker Cluster Manager to terminate:  [ OK ]
Waiting for cluster services to unload:.  [ OK ]
# ssh pcmk-1 -- /etc/init.d/corosync stop
Stopping Corosync Cluster Engine ( corosync) :  [ OK ]
Waiting for services to unload:  [ OK ]
#
```
- Once Corosync is no longer running, go to the other node and check the cluster status with crm_mon.
```
# crm_mon
============
Last updated: Fri Aug 28 15:27:35 2009
Stack: openais
Current DC: pcmk-2 - partition WITHOUT quorum
Version: 1.1.5-bdd89e69ba545404d02445be1f3d72e6a203ba2f
2 Nodes configured, 2 expected votes
1 Resources configured.
============
Online:  [ pcmk-2 ]OFFLINE: [ pcmk-1 ]
```

