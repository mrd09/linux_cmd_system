JOURNALCTL(1)                                                                                 journalctl                                                                                 JOURNALCTL(1)

NAME
       journalctl - Query the systemd journal

SYNOPSIS
       journalctl [OPTIONS...] [MATCHES...]

DESCRIPTION
       journalctl may be used to query the contents of the systemd(1) journal as written by systemd-journald.service(8).


       -f, --follow
           Show only the most recent journal entries, and continuously print new entries as they are appended to the journal.

       -u, --unit=UNIT|PATTERN
           Show messages for the specified systemd unit UNIT (such as a service unit), or for any of the units matched by PATTERN. If a pattern is specified, a list of unit names found in the
           journal is compared with the specified pattern and all that match are used. For each unit name, a match is added for messages from the unit ("_SYSTEMD_UNIT=UNIT"), along with additional
           matches for messages from systemd and messages about coredumps for the specified unit.

           This parameter can be specified multiple times.



# Example:
```
- Show the most recent log (same as log -f) of service
journalctl -f -u docker.service

- Show log of the executable:
journalctl /usr/bin/dockerd-ce
```