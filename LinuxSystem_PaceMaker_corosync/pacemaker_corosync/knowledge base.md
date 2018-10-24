# ClusterLabs
OPEN SOURCE HIGH AVAILABILITY CLUSTER STACK

The ClusterLabs stack unifies a large group of Open Source projects related to High Availability into a cluster offering suitable for both small and large deployments. Together, Corosync, Pacemaker

# Quick Overview
- Deploy
We support many deployment scenarios, from the simplest 2-node standby cluster to a 32-node active/active configuration. We can also dramatically reduce hardware costs by allowing several active/passive clusters to be combined and share a common backup node.
- Monitor
We monitor the system for both hardware and software failures. In the event of a failure, we will automatically recover your application and make sure it is available from one of the remaning machines in the cluster.
- Recover
After a failure, we use advanced algorithms to quickly determine the optimum locations for services based on relative node preferences and/or requirements to run with other cluster services (we call these "constraints").

# Why clusters
At its core, a **cluster is a distributed finite state machine capable of co-ordinating the startup and recovery of inter-related services across a set of machines.**

System HA is possible without a cluster manager, but you save many headaches using one anyway
Even a distributed and/or replicated application that is able to survive the failure of one or more components can benefit from a higher level cluster:
```
	- awareness of other applications in the stack
	- a shared quorum implementation and calculation
	- data integrity through fencing (a non-responsive process does not imply it is not doing anything)
	- automated recovery of instances to ensure capacity
```

# Components
- A Pacemaker stack is built on five core components:
```
	libQB - core services (logging, IPC, etc)
	Corosync - Membership, messaging and quorum
	Resource agents - A collection of scripts that interact with the underlying services managed by the cluster
	Fencing agents - A collection of scripts that interact with network power switches and SAN devices to isolate 	cluster members
	Pacemaker itself
```

# Features
The ClusterLabs stack, incorporating **Corosync** and **Pacemaker** defines an Open Source, High Availability cluster offering suitable for both small and large deployments.	
- Detection and recovery of machine and application-level failures
- Supports practically any redundancy configuration
- Supports both quorate and resource-driven clusters
- Configurable strategies for dealing with quorum loss (when multiple machines fail)
- Supports application startup/shutdown ordering, regardless of which machine(s) the applications are on
- Supports applications that must/must-not run on the same machine
- Supports applications which need to be active on multiple machines
- Supports applications with multiple modes (eg. master/slave)
- Provably correct response to any failure or cluster state.
- The cluster's response to any stimuli can be tested offline before the condition exists

# Background
Pacemaker has been around since 2004 and is primarily a collaborative effort between Red Hat and SUSE, however we also receive considerable help and support from the folks at LinBit and the community in general.

"Pacemaker cluster stack is the state-of-the-art high availability and load balancing stack for the Linux platform."
-- OpenStack documentation

Corosync also began life in 2004 but was then part of the OpenAIS project. It is primarily a Red Hat initiative, with considerable help and support from the folks in the community.

# What quorum mean:
In Distributed Systems, data/computations are replicated across multiple machines to provide fault-tolerance. So if, for example, a database is replicated on 5 machines, then quorum refers to the ***minimum number of machines which perform the same action (commit or abort) for a given transaction in order to decide the final operation for that transaction***. So, in a set of 5 machines, 3 machines form the majority quorum and if they agree, then we would commit that operation.

# What is STONITH (Shoot The Other Node In The Head)
- STONITH (Shoot The Other Node In The Head) is a Linux service for **maintaining the integrity of nodes in a high-availability (HA) cluster**.

- **STONITH automatically powers down a node that is not working correctly**. An administrator might employ STONITH if one of the nodes in a cluster can not be reached by the other node(s) in the cluster.

- STONITH is traditionally implemented by hardware solutions that allow a cluster to talk to a physical server without involving the operating system (OS). Although hardware-based STONITH works well, this approach requires specific hardware to be installed in each server, which can make the nodes more expensive and result in hardware vendor lock-in.

- A disk-based solution, such as split brain detection (SBD), can be easier to implement because this approach requires no specific hardware. In SBD STONITH, the nodes in the Linux cluster keep each other updated by using a Heartbeat mechanism. If something goes wrong with a node in the cluster, the injured node will terminate itself.

