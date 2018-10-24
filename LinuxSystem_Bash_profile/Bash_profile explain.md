# Bash startup files [Doc](http://www.tldp.org/LDP/Bash-Beginners-Guide/html/)
- **Startup files are scripts that are read and executed by Bash when it starts**. The following subsections describe different ways to start the shell, and the startup files that are read consequently.

## Distinguish all kind of invoke shell:

## Interactive shells
- An interactive shell generally reads from, and writes to, a user's terminal: input and output are connected to a terminal. Bash interactive behavior is started when the bash command is called upon without non-option arguments

## Invoked as an interactive login shell, or with `--login`
Interactive means you can enter commands. The shell is not running because a script has been activated. A login shell means that you got the shell after authenticating to the system, usually by giving your user name and password.
```
Files read:
	•	/etc/profile
	•	~/.bash_profile, ~/.bash_login or ~/.profile: first existing readable file is read
	•	~/.bash_logout upon logout.
```
Error messages are printed if configuration files exist but are not readable. If a file does not exist, bash searches for the next.

## Invoked as an interactive non-login shell
A non-login shell means that you did not have to authenticate to the system. For instance, when you open a terminal using an icon, or a menu item, X terminal, that is a non-login shell.
```
Files read:
	•	~/.bashrc (rc mean: run command)
This file is usually referred to in ~/.bash_profile:
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
```
## Invoked non-interactively: bash script
- All bash scripts use non-interactive shells. 
	- They are programmed to do certain tasks and cannot be instructed to do other jobs than those for which they are programmed.
```
Files read:
	defined by BASH_ENV
```

## Invoked remotely

```
Files read when invoked by rshd or sshd:
~/.bashrc
```

# Briefly (see here for more details), with examples:

- ***interactive login shell***: You log into a remote computer via, for example **ssh**. Alternatively, you drop to a tty on your local machine (Ctrl+Alt+F1) and log in there.

- ***interactive non-login shell***: Open a new terminal.

- ***non-interactive non-login shell***: Run a script. All scripts run in their own subshell and this shell is not interactive. It only opens to execute the script and closes immediately once the script is finished.

- ***non-interactive login shell***: This is extremely rare, and you're unlikey to encounter it. One way of launching one is echo command | ssh server. When ssh is launched without a command (so ssh instead of ssh command which will run command on the remote shell) it starts a login shell. If the stdin of the ssh is not a tty, it starts a non-interactive shell. This is why echo command | ssh server will launch a non-interactive login shell. You can also start one with bash -l -c command.

# How to check which kind?
## Is this shell interactive?
- Check the contents of the $- variable. For interactive shells, it will include i:

```
## Normal shell, just running a command in a terminal: interacive
$ echo $-
himBHs
## Non interactive shell
$ bash -c 'echo $-'
hBc
```
## Is this a login shell?
- There is no portable way of checking this but, for bash, you can check if the login_shell option is set:

```
## Normal shell, just running a command in a terminal: interacive
$ shopt login_shell 
login_shell     off
## Login shell; 
$ ssh localhost
$ shopt login_shell 
login_shell     on
```

## Real Example:
```
Putting all this together, here's one of each possible type of shell:

## Interactive login shell: 
- Use bash with option login, 
- When you log in on a text console, or through SSH, or with su -, you get an interactive login shell. 
$ bash -l
$ echo $-; shopt login_shell
himBHs
login_shell     on

## Interactive, non-login shell. 
- When you log in in graphical mode (on an X display manager), you don't get a login shell, instead you get a session manager or a window manager.
- When you start a shell in a terminal in an existing session (screen, X terminal, Emacs terminal buffer, a shell inside another, etc.), you get an interactive, non-login shell. 

$ echo $-; shopt login_shell
himBHs
login_shell     off

## Non-interactive, non-login shell:
- When a shell runs a script or a command passed on its command line, it's a non-interactive, non-login shell. Such shells run all the time
$ ssh localhost 'echo $-; shopt login_shell'
hBc
login_shell     off

## Non-interactive login shell: 
- log in remotely with a command passed through standard input which is not a terminal,
- ssh remotehost <my-script-which-is-stored-locally>
- # ssh pcmk-1 -- /etc/init.d/pacemaker stop
$ echo 'echo $-; shopt login_shell' | ssh localhost
Pseudo-terminal will not be allocated because stdin is not a terminal.
hBs
login_shell     on
```

# Shell initialization files
## System-wide configuration files(/etc/profile, /etc/bashrc)
The /etc/profile file is systemwide initialization file, executed for login shells.

### /etc/profile
- When invoked interactively with the **--login** option or when invoked as ***sh***, Bash reads the **/etc/profile** instructions. These usually set the shell variables PATH, USER, MAIL, HOSTNAME and HISTSIZE.

- On some systems, the umask value is configured in /etc/profile; on other systems this file holds pointers to other configuration files such as:
	- ***/etc/inputrc***, the system-wide Readline initialization file where you can configure the command line bell-style.
	- the ***/etc/profile.d*** directory, which contains files configuring system-wide behavior of specific programs.
- The Bash source contains sample profile files for general or individual use. 

### /etc/bashrc
- On systems offering multiple types of shells, it might be better to put Bash-specific configurations in this file, since /etc/profile is also read by other shells, such as the Bourne shell. Errors generated by shells that dont understand the Bash syntax are prevented by splitting the configuration files for the different types of shells. In such cases, the user's `~/.bashrc` might point to `/etc/bashrc` in order to include it in the shell initialization process upon login.

- You might also find that /etc/profile on your system only holds shell environment and program startup settings, while /etc/bashrc contains system-wide definitions for shell functions and aliases. The /etc/bashrc file might be referred to in /etc/profile or in individual user shell initialization files.

## Individual user configuration files
```
I don't have these files?! These files might not be in your home directory by default; create them if needed
```
### `~/`.bash_profile
- This is the preferred configuration file for configuring user environments individually. In this file, users can add extra configuration options or change default settings:
- This user configures the backspace character for login on different operating systems. Apart from that, the user's .*bashrc* and *.bash_login* are read.

### `~/`.bash_login
- This file contains specific settings that are normally only executed when you log in to the system. In the example, we use it to configure the umask value and to show a list of connected users upon login. This user also gets the calendar for the current month:
- In the **absence** of `~/`.bash_profile, this file will be read.

### `~/`.profile
- In the absence of `~/`.bash_profile and ~/.bash_login, ~/.profile is read. It can hold the same configurations, which are then also accessible by other shells. Mind that other shells might not understand the Bash syntax.

###  `~/`.bashrc
- Today, it is more common to use a non-login shell, for instance when ***logged in graphically using X terminal windows. Upon opening such a window, the user does not have to provide a user name or password***; no authentication is done. Bash searches for `~/`.bashrc when this happens, so it is referred to in the files read upon login as well, which means you don't have to enter the same settings in multiple files.

- In this user's .bashrc a couple of aliases are defined and variables for specific programs are set after the system-wide /etc/bashrc is read:

## .bashrc vs .bash_profile files
Let us see the difference with these two scripts:

> ~/.bashrc file runs every time you open a new non-login bash shell such as xterm / aterm, and ~/.bash_profile runs only with login shells i.e when you first log in into system.

## `~/`.bash_logout
- This file contains specific instructions for the logout procedure. In the example, the terminal window is cleared upon logout. This is useful for remote connections, which will leave a clean window after closing them.



# List the file open by the shell

If your system has strace then you can list the files opened by the shell, for example using
```
echo exit | strace bash -li |& less | grep '^open'
(-li means login shell interactive; use only -i for an interactive non-login shell.)
```
This will show a list of files which the shell opened or tried to open. On my system, they are as follows:

```
/etc/profile
/etc/profile.d/* (various scripts in /etc/profile.d/)
/home/<username>/.bash_profile (this fails, I have no such file)
/home/<username>/.bash_login (this fails, I have no such file)
/home/<username>/.profile
/home/<username>/.bashrc
/home/<username>/.bash_history (history of command lines; this is not a script)
/usr/share/bash-completion/bash_completion
/etc/bash_completion.d/* (various scripts providing autocompletion functionality)
/etc/inputrc (defines key bindings; this is not a script)
```



