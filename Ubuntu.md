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
- [tutorial](https://github.com/mrd09/vim.git)

## Autokey-gtk: set hot key for quick pass string to terminal
- install autokey-gtk: sudo apt-get install autokey-gtk
- Turn on the window want to filter first
- turn on autokey
- Myphrases/Addresses/Firstphase/
    - fill the string want to pass
    - Hotkey/Set: Ctrl + Press to Set
    - Window Filter/Set/Detect Window Properties: Auto detect: gnome-terminal-server.Gnome-terminal
        - If want to have multiple apps window: use "&": gnome-terminal-server.Gnome-terminal & remmina.Remmina.*
        - Or use python regular expression: `[terminator.Terminator, gnome-terminal-server.Gnome-terminal]` 
        - [python regular expression](https://docs.python.org/3/library/re.html)
        - [regular exp python stackover flow](https://stackoverflow.com/questions/26985228/python-regular-expression-match-multiple-words-anywhere)
    - Save then use
- [Special key](https://github.com/autokey/autokey/wiki/Special-Keys)