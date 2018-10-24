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

# 1.4. Type of Pacemaker Cluster:
- Pacemaker makes no assumptions about your environment, this allows it to support practically any redundancy configuration3 including **Active/Active, Active/Passive, N+1, N+M, N-to-1 and N-to-N.**

# 1.5. Corosync Active-Standby config:

## Topology
- Reference URL:
	[Corosyn](https://www.alteeve.com/w/Corosync)
	[Quorum](https://www.alteeve.com/w/Quorum)

- Definition:
	LSB (Linux Standard Based) - Provided by Linux distribution. ex: '/etc/init.d/service' script.
	OCF (Open Cluster Framework) - Set of tools for cluster computing. The project is part of the Linux Foundation.
	• CIB (aka. Cluster Information Base)
	• CRMd (aka. Cluster Resource Management daemon)
	• PEngine (aka. PE or Policy Engine)
	• STONITHd
	amf: Availability Management Framework

```
Host(Hardware Layer) 					Host_1 	Host_2
											 VIP

Cluster software
	Communication(Messaging
		+ Membership Layer)				Corosync
										1. Corosync uses the totem protocol for "heartbeat" like monitoring of the other node's health. 
											=>  A token is passed around to each node
											=>  The node does some work (like acknowledge old messages, send new ones) and then it passes the token on to the next node. 
											=> 	This goes around and around all the time.
											=> 	Should a node not pass it's token on after a short time-out period, the token is declared lost, an error count goes up and a new token is sent
											=> 	If too many tokens are lost in a row, the node is declared lost/dead.
											=> 	Once the node is declared lost, the remaining nodes reform a new cluster. 
											=>  If enough nodes in cluster are left to form quorum, then the new cluster will continue to provide services.
											=>	In two-node clusters, quorum is disabled so "each node can work on it's own."
											** In clustering terms, quorum is synonymous with "majority" - base on "vote" so that why 2 node can not use quorum
										"Corosync itself only cares about cluster membership, message passing and quorum
										What happens after the cluster reforms is up to the cluster resource manager."

	Cluster Resource Manangement 		Pacemaker
										1. When pacemaker is told that membership has changed because a node died, it looks to see what services might have been lost. Once it knows what was lost, it looks at the rules it's been given and decides what to do.
											=>	Generally, the first thing it does is "stonith" (aka "fence") the lost node. This is a process where the lost node is powered off, called power fencing, or cut off from the network/storage, called fabric fencing. 
											=> 	If this is skipped, the node could recover later and try to provide cluster services, not having realized that it was removed from the cluster. This could cause problems from confusing switches to corrupting data. 	
											=>	In two-node clusters, there is also a chance of a "split-brain". Because quorum has to be disabled, it is possible for both nodes to think the other node is dead and both try to provide the same cluster services. By using stonith, after the nodes break from one another, which could happen with a network failure for example, neither node will offer services until one of them has stonith'ed the other. The faster node will win and the slower node will shut down (or be isolated). The survivor can then run services safely without risking a split-brain.
											=>	Once the dead node has been stonith'ed, pacemaker then decides what to do with the lost services. Generally, this means "restart the service here that had been running on the dead node". The details of this, though, are decided by you when you configure the resources in pacemaker.

Service


```


## 1.5.1. Host config:

### 1.5.1.1. Config hostname:
```
[root@CDN]# yum --disablerepo=* install -y /home/vt_admin/ad_install/packages/corosync/*
[root@CDN]# vim /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.23.0.161 AD-ADDSBe-01
172.23.0.162 AD-ADDSBe-02
```
### 1.5.1.2. SSH key pairing:
```
(both of servers)
[root@CDN]# vim /etc/ssh/sshd_config
……………...
PermitRootLogin yes
………………
AllowUsers root       <- Permit to login as root.
[root@CDN]# service sshd restart

(Active server) - 0.161
[root@CDN]# ssh-keygen -t dsa -f ~/.ssh/id_dsa -N ""
[root@CDN]# cp ~/.ssh/id_dsa.pub ~/.ssh/authorized_keys
[root@CDN]# cd /root
[root@CDN]# scp -r .ssh 172.23.0.162:~

(Standby server) - 0.162
[root@CDN]# ssh-keygen -t dsa -f ~/.ssh/id_dsa -N ""
Overwrite (y/n)? y
[root@CDN]# cp ~/.ssh/id_dsa.pub ~/.ssh/authorized_keys
Overwrite (y/n)? y
[root@CDN]# cd /root
[root@CDN]# scp -r .ssh 172.23.0.161:~
```
## 1.5.2. Messaging layer config: Corosync
**(both of servers)- corosync configuration**

```
[root@CDN]# vim /etc/corosync/corosync.conf
compatibility: whitetank

totem {
        version: 2
        secauth: off 	# Disable encryption
        threads: 0 		# How many threads to use for encryption/decryption
        interface {
                ringnumber: 0

                # The following values need to be set based on your environment
                bindnetaddr: 172.23.0.160 ##This is the subnet
                mcastaddr: 226.94.1.2
                mcastport: 4000
                ttl: 1
        }
}

# This is default config from corosync
logging {
        fileline: off
        to_stderr: no
        to_logfile: yes
        to_syslog: yes
        logfile: /var/log/cluster/corosync.log
        debug: off
        timestamp: on
        logger_subsys {
                subsys: AMF
                debug: off
        }
}

# this config recommend from Pacemaker
amf {
        mode: disabled
}
quorum {
provider: corosync_votequorum
expected_votes: 2
}
```

- Tell Corosync to load the Pacemaker plugin
**(both of servers)- corosync configuration**
```
[root@CDN]# vim /etc/corosync/service.d/pcmk
service {
## Load the Pacemaker Cluster Resource Manager
name: pacemaker
ver: 0
}
```

- Start corosync: **(both of servers)- corosync start**
	`[root@CDN]# service corosync start`


## 1.5.3. Resource Management Config: Pacemaker

- Cluster automatically stores some information about the cluster: property: cib(cluster infor base)
• dc-version - the version (including upstream source-code hash) of Pacemaker used on the DC
• cluster-infrastructure - the cluster infrastructure being used (heartbeat or openais)
• expected-quorum-votes - the maximum number of nodes expected to be part of the cluster
and where the admin can set options that control the way the cluster operates
• stonith-enabled=true - Make use of STONITH
• no-quorum-policy=ignore - Ignore loss of quorum and continue to host resources
• resource-stickiness - Specify the aversion to moving resources to other machines when the master node come alive

- crm config:
(Active server)
[root@CDN]# crm configure edit
```
node AD-ADDSBe-01 \
## When a cluster node is in standby mode, it will no longer be able to host cluster resources and services. The standby mode is useful for cluster node maintenance operations.
        attributes standby="off"

node AD-ADDSBe-02 \
        attributes standby="off"
primitive BOND0 ocf:heartbeat:ethmonitor \
        params interface="bond0" \
        op monitor interval="30s" timeout="30s" depth="0" \
        meta is-managed="true"
primitive BOND0_VIP ocf:heartbeat:IPaddr2 \
        params ip="172.23.42.6" nic="bond0:1" cidr_netmask="27" \   # IP in here is the Service VIP
        op monitor interval="30s" \
        meta is-managed="true"
primitive LOGSTASH lsb:logstash \		# Service in /etc/init.d/
        op monitor interval="10s" timeout="30s" \
        op start interval="0" timeout="40s" \
        op stop interval="0" timeout="60s" \
        meta target-role="Started"
primitive TOMCAT_BE lsb:tomcat_be \
        op monitor interval="10s" timout="30s" \
        op start interval="0" timeout="40s" \
        op stop interval="0" timeout="60s" \
        meta target-role="Started"
primitive TOMCAT_IM lsb:tomcat_importer \
        op monitor interval="10s" timout="30s" \
        op start interval="0" timeout="40s" \
        op stop interval="0" timeout="60s" \
        meta target-role="Started"
primitive mariaDB lsb:mysql \
        op monitor interval="10s" timeout="30s" \
        op start interval="0" timeout="40s" \
        op stop interval="0" timeout="60s" \
        meta target-role="Started"
primitive storage_data ocf:heartbeat:Filesystem \
        params device="/dev/mapper/ADDSBe-DATAp1p1" directory="/DATA" fstype="xfs" \
        op monitor interval="60s" timeout="60s" \
        op start interval="0" timeout="60s" \
        op stop interval="0" timeout="60s"
primitive storage_log ocf:heartbeat:Filesystem \
        params device="/dev/mapper/ADDSBe-LOGp1p1" directory="/castis/log" fstype="xfs" \
        op monitor interval="60s" timeout="60s" \
        op start interval="0" timeout="60s" \
        op stop interval="0" timeout="60s"
group DB_IP BOND0 BOND0_VIP \
        meta target-role="Started" migration-threshold="3" multiple-active="stop-start"
group g_process mariaDB TOMCAT_BE TOMCAT_IM LOGSTASH \
        meta target-role="Started" migration-threshold="3" multiple-active="stop-start"
group g_storage storage_log storage_data \
        meta target-role="Started" migration-threshold="3" multiple-active="stop-start"
location PREFER-NODE1 DB_IP 100: AD-ADDSBe-01
colocation OTHERS-WITH-IP inf: DB_IP g_storage g_process
order g_process-AFTER-g_storage inf: g_storage g_process
order g_storage-AFTER-DB_IP inf: DB_IP g_storage

# This is define what to do with the node in cluster and the service
property $id="cib-bootstrap-options" \
        dc-version="1.1.10-14.el6_5.1-368c726" \
        cluster-infrastructure="classic openais (with plugin)" \
        expected-quorum-votes="4" \
        last-lrm-refresh="1468981518" \
        stonith-enabled="false" \
        no-quorum-policy="ignore" \    # Use this when cluster has only 2 node
        default-resource-stickiness="100"
```
- cleanup the resource
[root@CDN]# crm resource cleanup DB_IP 
[root@CDN]# crm resource cleanup g_storage
[root@CDN]# crm resource cleanup g_process

[root@CDN]# crm_mon


## 1.5.4. Test Service:
Corosync
# Server-01
[root@CDN]# crm_mon
Online: [ AD-ADDSBe-01 AD-ADDSBe-02 ]

 Resource Group: DB_IP
     BOND0	(ocf::heartbeat:ethmonitor):    Started AD-ADDSBe-01
     BOND0_VIP  (ocf::heartbeat:IPaddr2):	Started AD-ADDSBe-01
 Resource Group: g_TOMCAT
     storage_log        (ocf::heartbeat:Filesystem):    Started AD-ADDSBe-01
     TOMCAT_IM  (lsb:tomcat_importer):  Started AD-ADDSBe-01
     TOMCAT_BE  (lsb:tomcat_be):        Started AD-ADDSBe-01
 Resource Group: g_mariaDB
     storage_data	(ocf::heartbeat:Filesystem):    Started AD-ADDSBe-01
     mariaDB    (lsb:mysql):    Started AD-ADDSBe-01

[root@CDN]# crm node standby

# all processes fail-over to server-02
[root@CDN]# crm_mon
Node AD-ADDSBe-01: standby
Online: [ AD-ADDSBe-02 ]

  Resource Group: DB_IP
     BOND0	(ocf::heartbeat:ethmonitor):    Started AD-ADDSBe-02
     BOND0_VIP  (ocf::heartbeat:IPaddr2):	Started AD-ADDSBe-02
 Resource Group: g_TOMCAT
     storage_log        (ocf::heartbeat:Filesystem):    Started AD-ADDSBe-02
     TOMCAT_IM  (lsb:tomcat_importer):  Started AD-ADDSBe-02
     TOMCAT_BE  (lsb:tomcat_be):        Started AD-ADDSBe-02
 Resource Group: g_mariaDB
     storage_data	(ocf::heartbeat:Filesystem):    Started AD-ADDSBe-02
     mariaDB    (lsb:mysql):    Started AD-ADDSBe-02

[root@CDN]# crm node online
