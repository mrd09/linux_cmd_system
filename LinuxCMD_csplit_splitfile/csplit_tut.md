CSPLIT(1)                                                                  User Commands                                                                 CSPLIT(1)

NAME
       csplit - split a file into sections determined by context lines

SYNOPSIS
       csplit [OPTION]... FILE PATTERN...

       --suppress-matched
              suppress the lines matching PATTERN

DESCRIPTION
       Output pieces of FILE separated by PATTERN(s) to files 'xx00', 'xx01', ..., and output byte counts of each piece to standard output.

       Read standard input if FILE is -

       Mandatory arguments to long options are mandatory for short options too.

   Each PATTERN may be:
       {*}    repeat the previous pattern as many times as possible


- Example:
```
- Sample file:
$ cat testfile
abc
cde
----
test
test2

- use csplit:
csplit testfile /----/ {*} --suppress-matched

- show file:
$ ls
xx00 xx01

$ cat xx00
abc
cde

$ cat xx01
test
test2
```
