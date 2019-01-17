- Case 1: If you want to run job in background use "&": # ./a.sh &
- Case 2: You mistaken run job without "&": you will need to do this thing:
    - Hit ctrl-z    : suspend job to background
    - jobs          : list job in background: with "job-id"
    - bg "job-id"  : reactivated jobs in background 
```
- run script:
$ ./check_git_all_commit.sh

- Hit ctrl-z: to suspend the job to background
^Z
[1]+  Stopped                 ./check_git_all_commit.sh

- jobs: show jobs in background:
$ jobs 
[1]+  Stopped                 ./check_git_all_commit.sh

- bg: reactivate the jobs in background
 $ bg 1
[1]+ ./check_git_all_commit.sh &
```