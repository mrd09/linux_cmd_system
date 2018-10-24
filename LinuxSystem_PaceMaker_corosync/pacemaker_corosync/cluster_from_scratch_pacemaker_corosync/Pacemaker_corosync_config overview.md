- install pacemaker corosync
- /etc/hosts
- ssh config
- /etc/corosync/corosync.conf
- /etc/corosync/service.d/pcmk
- cp to second node /etc/hosts /etc/corosync/corosync.conf /etc/corosync/service.d/pcmk
- start at everynode corosync, pacemaker
- pacemaker cluster option config:
	• dc-version - the version (including upstream source-code hash) of Pacemaker used on the DC
	• cluster-infrastructure - the cluster infrastructure being used (heartbeat or openais)
	• expected-quorum-votes - the maximum number of nodes expected to be part of the cluster
	and where the admin can set options that control the way the cluster operates
	• stonith-enabled=true - Make use of STONITH
	• no-quorum-policy=ignore - Ignore loss of quorum and continue to host resources.
```
	property $id="cib-bootstrap-options" \
	 dc-version="1.1.5-bdd89e69ba545404d02445be1f3d72e6a203ba2f" \
	 cluster-infrastructure="openais" \
	 expected-quorum-votes="2" \
	 stonith-enabled="true" \
	 no-quorum-policy="ignore"
```
- pacemaker resource default option config:
	Here we configure cluster options that apply to every resource.
	• resource-stickiness - Prevent Resources from Moving  to other machines after Recovery
		rsc_defaults $id="rsc-options" \
		resource-stickiness="100"
