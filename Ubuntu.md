#Ubuntu

## Short key:
Ctrl Alt T 		: 	Terminal
Shift Crtl T 	: 	Open new terminal in 1 tab

## Mount
- Mount once time:
https://askubuntu.com/questions/978746/how-to-mount-ntfs-partition-in-ubuntu-16-04

- Auto-mount ntfs:
https://askubuntu.com/questions/46588/how-to-automount-ntfs-partitions

sudo vim /etc/fstab
UUID=01D487501610A4F0 /home/mrd09/ntfs ntfs rw,auto,users,exec,nls=utf8,umask=003,gid=46,uid=1000    0   0

sudo mount -a 

umount /home/mrd09/ntfs

## Unikey
- Use unikey:
https://github.com/teni-ime/ibus-teni

sudo add-apt-repository ppa:teni-ime/ibus-teni
sudo apt-get update
sudo apt-get install ibus-teni
ibus restart

## systemd
- Ctrl O : Y -> Enter to save
- Ctrl X : Exit

## vim:
- put console mouse in file path -> press: gf
	+ if want to go back to file: Ctrl + o

## Autokey-gtk: set hot key for quick pass string to terminal
- install autokey-gtk: sudo apt-get install autokey-gtk
- Turn on the window want to filter first
- turn on autokey
- Myphrases/Addresses/Firstphase/
    - fill the string want to pass
    - Hotkey/Set: Ctrl + Press to Set
    - Window Filter/Set/Detect Window Properties: Auto detect: gnome-terminal-server.Gnome-terminal
    - Save then use