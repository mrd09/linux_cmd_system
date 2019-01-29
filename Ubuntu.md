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
        - If want to have multiple apps window: use python regular expression: `[terminator.Terminator, gnome-terminal-server.Gnome-terminal]` 
        - [python regular expression](https://docs.python.org/3/library/re.html)
        - [regular exp python stackover flow](https://stackoverflow.com/questions/26985228/python-regular-expression-match-multiple-words-anywhere)
    - Save then use
- [Special key](https://github.com/autokey/autokey/wiki/Special-Keys)

## Git bash prompt
- [git bash prompt](https://github.com/magicmonty/bash-git-prompt)

## Cool alias in bashrc:
- [ssh2 version](https://github.com/mrd09/linux_cmd_system/tree/master/LinuxCMD_ssh2_script)
```alias ssh2='/home/mrd09/knowledge/ssh_script/run.sh'```
- git bash prompt:
```
GIT_PROMPT_SHOW_UPSTREAM=1
GIT_PROMPT_ONLY_IN_REPO=0
GIT_PROMPT_SHOW_UNTRACKED_FILES=all
source ~/.bash-git-prompt/gitprompt.sh
```
- show memory:
```
alias mem_check='echo "-----------Show Current Total RAM Usage----------" && free -m && echo "" && echo "-----------Show Most Process RAM Usage(6th column-KB)----------" && echo "" && ps aux --sort rss | tail -10'
```