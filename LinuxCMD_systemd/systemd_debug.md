
- By default the systemd configuration files controlling the service are under the folder/usr/lib/systemd/system. This is also evident in the Loaded: line in the output of the systemctl status command.
```
✔ ~/knowledge/test 
18:10 $ sudo systemctl status docker.service | grep Loaded
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)

```

- So, say we want to modify the daemon options so that the service is accessible over the network and also have it bind to the unix socker at/var/run/docker.sock. We would first want to see what the option is set to currently. This can be done using the systemctl cat like below:
```
✔ ~/knowledge/test 
18:18 $ sudo systemctl cat docker.service | grep Exec
#ExecStart=/usr/bin/dockerd -H unix://
#ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375
ExecStart=/usr/bin/dockerd 
ExecReload=/bin/kill -s HUP $MAINPID
ExecStart=
ExecStart=/usr/bin/dockerd
```

- To change the value of an option, ExecStart in this case, do the following:
```
    [ec2-user@ip-10-0-46-113 ~]$ sudo systemctl edit docker

This will create the necessary directory structure under /etc/systemd/system/docker.service.d and open an editor (using the default editor configured for the user) to the override file. Add the section below into the editor:

    [Service]
    ExecStart=
    ExecStart=/usr/bin/docker -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
```

- Edit "/lib/systemd/system/docker.service":
```
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 unix:///var/run/docker.sock

```

- After edit:
```
18:25 $ sudo systemctl status docker.service 
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
  Drop-In: /etc/systemd/system/docker.service.d
           └─override.conf
   Active: active (running) since Tue 2018-12-25 18:25:57 +07; 4s ago
     Docs: https://docs.docker.com
 Main PID: 4882 (dockerd)
    Tasks: 13
   CGroup: /system.slice/docker.service
           └─4882 /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock

Dec 25 18:25:56 mrd09 dockerd[4882]: time="2018-12-25T18:25:56.990628204+07:00" level=warning msg="Your kernel does not support cgroup rt period"
Dec 25 18:25:56 mrd09 dockerd[4882]: time="2018-12-25T18:25:56.990636124+07:00" level=warning msg="Your kernel does not support cgroup rt runtime"
Dec 25 18:25:56 mrd09 dockerd[4882]: time="2018-12-25T18:25:56.990939606+07:00" level=info msg="Loading containers: start."
Dec 25 18:25:57 mrd09 dockerd[4882]: time="2018-12-25T18:25:57.182009225+07:00" level=info msg="Default bridge (docker0) is assigned with an IP address 172.17.0.0/16. 
Dec 25 18:25:57 mrd09 dockerd[4882]: time="2018-12-25T18:25:57.384981384+07:00" level=info msg="Loading containers: done."
Dec 25 18:25:57 mrd09 dockerd[4882]: time="2018-12-25T18:25:57.647249929+07:00" level=info msg="Docker daemon" commit=4d60db4 graphdriver(s)=overlay2 version=18.09.0
Dec 25 18:25:57 mrd09 dockerd[4882]: time="2018-12-25T18:25:57.647311001+07:00" level=info msg="Daemon has completed initialization"
Dec 25 18:25:57 mrd09 dockerd[4882]: time="2018-12-25T18:25:57.735219893+07:00" level=info msg="API listen on [::]:2375"
Dec 25 18:25:57 mrd09 systemd[1]: Started Docker Application Container Engine.
Dec 25 18:25:57 mrd09 dockerd[4882]: time="2018-12-25T18:25:57.736033836+07:00" level=info msg="API listen on /var/run/docker.sock"

✘-INT ~/knowledge/test 
18:26 $ sudo docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

```