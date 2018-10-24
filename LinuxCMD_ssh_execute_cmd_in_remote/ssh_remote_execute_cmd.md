# How To Run Multiple SSH Command On Remote Machine And Exit Safely
There are various ways to run multiple commands on a remote Unix server. The syntax is as follows.
## Simple bash syntax to run multiple commands on remote machine
- Simply run command2 if command1 successful on a remote host called foo:
$ ssh bar@foo "command1 && command2

- Here is another example to run a multiple commands on a remote system:
```
ssh vivek@server1.cyberciti.biz << EOF
 date
 hostname
 cat /etc/resolv.conf
EOF
```

- Run with sudo:
$ ssh -t vivek@server1.cyberciti.biz "sudo /sbin/shutdown -h now"
or:
$ ssh root@server1.cyberciti.biz "sync && sync && /sbin/shutdown -h now"

> Please note that the -t option will get rid of “Sorry, you must have a tty to run sudo/insert your-command-here” error message. 

## Pipe script to a remote server
- Finally, create a script called “remote-box-commands.bash” as follows on your local server:
```
date
hostname
cat /etc/resolv.conf
```

- Run it as follows on a remote server called nas02nixcrafthomeserver:
$ cat remote-box-commands.bash | ssh user@nas02nixcrafthomeserver