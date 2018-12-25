# Presiquite
- Step 1: do the public-private key things: [ssh key](https://github.com/mrd09/gitcli_github_quick/blob/master/SSH_public-key_authen.md)
- Step 2: create config: `~/.ssh/config`: specify the identity private File
```
### default 172.28.* ##
Host 172.28.*
	User ubuntu
	Port 22
	IdentityFile ~/.ssh/tmvn-staging.pem

Host 172.29.*
	User ubuntu
	Port 22
	IdentityFile ~/.ssh/tmvn-staging.pem

```
- Step 3: How to add shell script to linux system
```
- First ensure the shell script is executable.
	chmod u+x,g+x script.sh

- Then, edit your .bashrc file like following:
	cd
	vi .bashrc
	# Add this towards the bottom
		alias ssh2='/home/user/script.sh'

- make bash profile take effect:
	source ~/.bashrc		
```
- Step 4: test script:
```
✔ ~/knowledge/ssh_script 
11:16 $ ssh2 qa_eq
[1]: qa_eq_app-1
[2]: qa_eq_app-2
[3]: qa_eq_db-pri
[4]: qa_eq_openvpn
[5]: qa_eq_proxy
[+]Select an OPTION [Number] and press [Enter]: 3
HOST: qa_eq_db-pri
IP: 172.28.3.11
connecting to 172.28.3.11
spawn ssh 172.28.3.11
Welcome to Ubuntu 16.04.5 LTS (GNU/Linux 4.4.0-1074-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

38 packages can be updated.
0 updates are security updates.


Last login: Sat Dec 22 08:38:24 2018 from 172.28.1.200
```