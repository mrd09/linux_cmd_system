# I. Virtual mountpoint:
## 1. create the mount point
```
# mkdir /mnt/data
```

## 2. create a file full of /dev/zero, large enough to the maximum size you want to reserve for the virtual file-system
```
# touch /home/dat.hoang/test.ext3

# dd if=/dev/zero of=/home/dat.hoang/test.ext3 bs=1000M count=1
1+0 records in
1+0 records out
1048576000 bytes (1.0 GB) copied, 1.11759 s, 938 MB/s
[root@infra15 employee]# ll /home/dat.hoang/test.ext3
-rw-r--r-- 1 root root 1048576000 May 22 18:55 /home/dat.hoang/test.ext3
[root@infra15 employee]# mkfs.ext3 /home/dat.hoang/test.ext3
mke2fs 1.42.9 (28-Dec-2013)
/home/dat.hoang/test.ext3 is not a block special device.
Proceed anyway? (y,n) y
Discarding device blocks: done                            
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
64000 inodes, 256000 blocks
12800 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=264241152
8 block groups
32768 blocks per group, 32768 fragments per group
8000 inodes per group
Superblock backups stored on blocks: 
    32768, 98304, 163840, 229376

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

# ll /home/dat.hoang/test.ext3
```

## 3. format this file with an ext3 file-system (you can format a disk space even if it is not a block device, but double check the syntax of every - dangerous - formatting command)
```
# mkfs.ext3 /home/dat.hoang/test.ext3
```

## 4. mount the newly formatted disk space in the directory you've created as mount point, e.g.
```
# mount -o loop,rw,usrquota,grpquota /home/dat.hoang/test.ext3 /mnt/data/

# df -h
/dev/loop0               969M  1.3M  918M   1% /mnt/data
```

# II. add more space to (trim the size of) the directory:

```
# umount /mnt/data/

# e2fsck -f /home/dat.hoang/test.ext3 
e2fsck 1.42.9 (28-Dec-2013)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/home/dat.hoang/test.ext3: 11/64000 files (0.0% non-contiguous), 8443/256000 blocks

# resize2fs -p /home/dat.hoang/test.ext3 2000M
resize2fs 1.42.9 (28-Dec-2013)
Resizing the filesystem on /home/dat.hoang/test.ext3 to 512000 (4k) blocks.
Begin pass 1 (max = 8)
Extending the inode table     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
The filesystem on /home/dat.hoang/test.ext3 is now 512000 blocks long.

# mount -o loop,rw,usrquota,grpquota /home/dat.hoang/test.ext3 /mnt/data/

# df -h
/dev/loop0               2.0G  1.5M  1.9G   1% /mnt/data
```

# III. Permanent mount point add in fstab:
- You add a line to the `/etc/fstab` file. For example:
```
/home/dat.hoang/test.ext3   /mnt/data   ext3    defaults    0 1

    • /dev/sda5 : File system or parition name
    • /datadisk1 : Mount point
    • ext3 : File system type
    • defaults : Mount options (Read man page of mount command for all options)
    • 0 : Indicates whether you need to include or exclude this filesystem from dump command backup. Zero means this filesystem does not required dump.
    • 2 : It is used by the fsck program to determine the order in which filesystem checks are done at reboot time. The root (/) filesystem should be specified with a #1, and otherfilesystems should have a # 2 value.
```
