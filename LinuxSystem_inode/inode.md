# basic knowledge of the following (file system):
- ***inode*** (contains file attributes, metadata of file, pointer structure)
- ***file*** (can be considered a table with 2 columns, filename and its inode, inode points to the raw data blocks on the block device)
- ***directory*** (just a special file, container for other filenames. It contains an array of filenames and inode numbers for each filename. Also it describes the relationship between parent and children.)
- ***symbolic link VS hard link***
- ***dentry*** (directory entries)

On typical ext4 file system (what most people use), the default inode size is 256 bytes, block size is 4096 bytes.

A directory is just a special file which contains an array of filenames and inode numbers. 
When the directory was created, the file system allocated 1 inode to the directory with a "filename" (dir name in fact). 
The inode points to a single data block (minimum overhead), which is 4096 bytes. 
That's why you see 4096 / 4.0K when using ls.

```
# cat /etc/mke2fs.conf 
[defaults]
	base_features = sparse_super,large_file,filetype,resize_inode,dir_index,ext_attr
	default_mntopts = acl,user_xattr
	enable_periodic_fsck = 0
	blocksize = 4096
	inode_size = 256
	inode_ratio = 16384

[fs_types]
	ext3 = {
		features = has_journal
	}
	ext4 = {
		features = has_journal,extent,huge_file,flex_bg,metadata_csum,64bit,dir_nlink,extra_isize
		inode_size = 256
	}
```
- formular how to calculate from disk storage to inode:
 + cat /etc/mke2fs.conf => show the **inode_ratio** : Ex:  inode_ratio= 16384
```
# cat /etc/mke2fs.conf 
[defaults]
	base_features = sparse_super,large_file,filetype,resize_inode,dir_index,ext_attr
	default_mntopts = acl,user_xattr
	enable_periodic_fsck = 0
	blocksize = 4096
	inode_size = 256
	inode_ratio = 16384
```
 + df -h : show the size of the partition(file system): Ex: 670G
 ```
 # df -h
/dev/sda1       670G  313M  636G   1% /home/mrd09/storage
 ```
 + We can cal the maximum inode = 670 x 1024 x 1024 / 16 = 43909120
 
 + show the inode for check the truth:
```
df --inodes
/dev/sda1      44670976   2502 44668474    1% /home/mrd09/storage
```
