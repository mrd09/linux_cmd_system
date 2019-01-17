- Case 1: If you want to run job in __background use "&"__: # ./a.sh &
- Case 2: You mistaken run job without "&": you will need to do this thing:
    - __Hit ctrl-z__    : suspend job to background
    - __jobs__          : list job in background: with "job-id"
        - note that __jobs: only show in the current terminal only__. 
        - If you __quit this terminal by accident__ you __will lose the job-id__ => so that you __can not be able to run the bg command__
    - __bg "job-id"__  : reactivated jobs in background 
```
- run script:
$ ./check_git_all_commit.sh

- Hit ctrl-z: to suspend the job to background
^Z
[1]+  Stopped                 ./check_git_all_commit.sh

- jobs: show jobs in background:
$ jobs 
[1]+  Stopped                 ./check_git_all_commit.sh
$ jobs -p
23535

- show the pid in other tab to monitor the process done or not:
$ ps aux | grep 23535
mrd09    23535  0.0  0.0  21532  3384 pts/0    S    12:06   0:00 /bin/bash /home/mrd09/knowledge/check_git_all_commit.sh
mrd09    23983  0.0  0.0  23076  1000 pts/1    S+   12:08   0:00 grep --color=auto 23535

$ ps aux | grep 23535
mrd09    24079  0.0  0.0  23076  1088 pts/1    S+   12:08   0:00 grep --color=auto 23535


- bg: reactivate the jobs in background
 $ bg 1
[1]+ ./check_git_all_commit.sh &
```