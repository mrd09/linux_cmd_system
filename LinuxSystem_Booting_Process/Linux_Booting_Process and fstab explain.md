# A simple /etc/fstab, using kernel name descriptors:
```
/etc/fstab
# <device>             <dir>         <type>    <options>             <dump> <fsck>
/dev/sda1              /             ext4      noatime               0      1
/dev/sda2              none          swap      defaults              0      0
/dev/sda3              /home         ext4      noatime               0      2

-	<device> describes the block special device or remote filesystem to be mounted; see #Identifying filesystems.
-	<dir> describes the mount directory, <type> the file system type, and <options> the associated mount options; see mount(8) and ext4(5).
-	<dump> is checked by the dump(8) utility. This field is usually set to 0, which disables the check.
-	<fsck> sets the order for filesystem checks at boot time; see fsck(8). For the root device it should be 1. For other partitions it should be 2, or 0 to disable checking.
```
- Example:
``` 
[root@TESTBED-VOD-CMS vt_admin]# cat /etc/fstab 

UUID=8ac32966-37be-4b4a-b9c9-4e941f9569f2 /                       ext4    defaults        1 1
UUID=03AA-F495          /boot/efi               vfat    umask=0077,shortname=winnt 0 0
UUID=c87afa6a-dc43-4552-97c0-1005506683c5 /home                   ext4    defaults        1 2
UUID=d5987e6b-412f-4965-960e-55dfb01bf5db /var                    ext4    defaults        1 2
UUID=97ece0d4-0228-40c5-89e7-b9fa39d8cb20 swap                    swap    defaults        0 0
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
```

# How to show the partition table:
```
[root@TESTBED-VOD-CMS vt_admin]# lsblk -f

NAME   FSTYPE LABEL UUID                                 MOUNTPOINT
loop0  ext3         f30a9406-7bb0-494c-b494-63df429f59fa 
loop1  ext3         f30a9406-7bb0-494c-b494-63df429f59fa /NAS_INGEST01
loop2  ext3         ddfa39f4-d0ca-44d0-b39c-509f99992733 /NAS_INGEST02
loop3  ext3         f30a9406-7bb0-494c-b494-63df429f59fa 
loop4  ext3         cbef691e-631f-4e36-83b9-1ad7e7eb401a 
sda                                                      
â”œâ”€sda1 vfat         03AA-F495                            /boot/efi
â”œâ”€sda2 ext4         8ac32966-37be-4b4a-b9c9-4e941f9569f2 /
â”œâ”€sda3 ext4         d5987e6b-412f-4965-960e-55dfb01bf5db /var
â”œâ”€sda4 swap         97ece0d4-0228-40c5-89e7-b9fa39d8cb20 [SWAP]
â””â”€sda5 ext4         c87afa6a-dc43-4552-97c0-1005506683c5 /home
sr0                                                      
```

