# 1. Short version: SSH without user-pass
- bashscript: `$ cat run.sh`
```
host=${1}
homeFolder="/home/mrd09/knowledge/ssh_script"

numberOfGrep=`cat "${homeFolder}/password" | awk '{print $1}' | grep ${host} | wc -l`
if [ ${numberOfGrep} -gt 1 ]
then
    resultArray=(`cat "${homeFolder}/password" | awk '{print $1}' | grep ${host}`)
    for element in $(seq 0 $((${#resultArray[@]} - 1)))
    do
        echo [$(($element + 1))]: ${resultArray[$element]}
    done
    printf "[+]Select an OPTION [Number] and press [Enter]: "
    read option
    re='^[0-9]+$'
    if ! [[ $option =~ $re ]] ; then
        echo "Error: Not a number"
        exit 1
    else
        if [[ ( $option -gt $((${#resultArray[@]} + 1)) ) || ( ${option} -lt 0 ) ]]; then
            echo "Error: Option not Existed."
            exit 1
        else
            result=${resultArray[$(($option - 1))]} 
        fi
    fi
elif [[ ${numberOfGrep} -eq 0 ]]; then
    echo "Host NOT existed."
    exit 1
else
    result=`cat "${homeFolder}/password" | awk '{print $1}' | grep ${host}`
fi

combination=`grep -w ${result} "${homeFolder}/password"`
ip=`echo ${combination} | awk '{print $2}'`

echo "HOST: ${result}"
echo "IP: ${ip}"

${homeFolder}/sshScript.exp ${ip}
```

- expect script: `$ cat sshScript.exp`
```
$ cat sshScript.exp 
#!/usr/bin/expect -f

#example of getting arguments passed from command line..
#not necessarily the best practice for passwords though...
set server [lindex $argv 0]

set timeout 3

send_user "connecting to $server\n"

spawn ssh $server

expect {
    "(yes/no)? " { 
        send "yes\r"
     }
} 

expect {

        "$ " {
    interact
    exit 0
    }

    eof { exit 2 }
    timeout {
        send_user "Time out\n"
        exit 1
        }
```

- file password: `$ cat password` 
```
- ${name} ${IP}
$ cat password 
test 1.1.1.1
```

- bashrc alias:
```alias ssh2='/home/mrd09/knowledge/ssh_script/run.sh'```
