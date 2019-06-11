[LinuxCMD_tmux_terminal_multiplexer](https://github.com/tmux/tmux/wiki)
[tmux cheatsheet](https://gist.github.com/MohamedAlaa/2961058)

# tmux:
- tmux is a `terminal multiplexer`. 
    - It lets you `switch easily between several programs` `in one terminal`, `detach them` (they keep running in the background) and `reattach them to a different terminal`.


# Install and Using
##  Install:
```
sudo apt-get install tmux
```

##  Using:
###     Example bash script running:
- ping bashscript:
```
$ cat test.sh 
#!/bin/bash

ping 127.0.0.1

$ ./test.sh
```

###     Getting In & Getting Out:
- Tạo một session mới:
```
$ tmux
```

- Tạo một session mới kèm theo tên gọi:
```
$ tmux new -s s_name
```

- Exit a tmux(can not go back):
```
$ exit
```

- Detach (can go back): 
```
ctrl+b d
```

###     Using Prefix:
- `All commands in tmux` `require the prefix shortcut`, which by default is `ctrl+b`

###     List, Attach, Detach & Kill:
- List
```
$ tmux ls
0: 1 windows (created Wed Jun  5 09:10:38 2019) [167x42]
1: 1 windows (created Wed Jun  5 09:13:45 2019) [167x42]
```

- Detach:
```
ctrl+b d
```

- Attach:
    - `a` : attach mode
    - `-t`: target-session
```
$ tmux a -t 0
```

- kill session:
```
$ tmux kill-session -t test
```

###     Name, Rename:
- Name:
```
$ tmux new -s s_name
```

- Rename:
```
ctrl+b $
```

###     Managing Panes:
- To split a pane horizontally:
```
ctrl+b "
```

- To split pane vertically:
```
ctrl+b %
```

- To move from pane to pane, simply use the prefix followed by the arrow key:
```
ctrl+b [arrow key]
```

###     Getting Fancy with Custom Themes:
- Install manually:
```
$ git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack
Cloning into '/home/vagrant/.tmux-themepack'...
remote: Enumerating objects: 298, done.
remote: Total 298 (delta 0), reused 0 (delta 0), pack-reused 298
Receiving objects: 100% (298/298), 57.33 KiB | 0 bytes/s, done.
Resolving deltas: 100% (191/191), done.
Checking connectivity... done.

$ cat ~/.tmux.conf
source-file "/home/vagrant/.tmux-themepack/powerline/block/green.tmuxtheme"
set -g @themepack 'basic'

$ tmux source-file ~/.tmux.conf
```
