#!/bin/bash
#####################################################
# Name: Bash CheatSheet for Mac OSX
# 
# A little overlook of the Bash basics
#
# Usage:
#
# Author: J. Le Coupanec
# Date: 2014/11/04
#####################################################
[Bash scripting cheatsheet](https://devhints.io/bash)

# Substitution
- ${FOO/from/to}  Replace first match
- ${FOO//from/to}   Replace all
- ${FOO%suffix}   Remove suffix
- ${FOO#prefix}   Remove prefix
- ${FOO%%suffix}  Remove long suffix
- ${FOO##prefix}  Remove long prefix

- Example
```
name="John-test1-test2"
echo ${name/-/_}    #=> "John_test1-test2" (replace first match)
echo ${name//-/_}   #=> "John_test1_test2" (replace all match)
echo ${name##John-} #=> "test1-test2" (remove prefix John-)
echo ${name%%-*}    #=> "John" (remove suffix begin with -)
```


# String manipulation tips:
STR="Hello world"
echo ${STR:6:5}   # "world"
echo ${STR:-5:5}  # "world"
- Example:
```
$ ls config/ | xargs basename -a
confd_display_banner
confd_test_abc
confd_test_abc
confd_test_abc
confd_test_abc
confd_test_abc
confd_test_abc
confd_test_abc
confd_test_abc
$ test="confd_display_banner";echo ${test:6}
display_banner
```

SRC="/path/to/foo.cpp"
BASE=${SRC##*/}   #=> "foo.cpp" (basepath)
DIR=${SRC%$BASE}  #=> "/path/to/" (dirpath)


# file permission:
- It is important to remember that these three permissions differs when applied to files or directories:
+-----------+--------------------------------+---------------------------------------------------------+
|Permission |  Applied to file               |  Applied to Directory                                   |
+------------------------------------------------------------------------------------------------------+
|Read       |  Open and read file contents   |  List contents of dir                                   |
|Write      |  Change the contents of file   |  Create and delete files/sub+dirs and modify permissions|
|Execute    |  Run the file as program/script|  Enter into the dir                                     |
+-----------+------------------------------------------------------------------------------------------+


# Redirection:
- >   :   mean send to as a whole completed file, overwriting target if exist (see noclobber bash feature at #3 later).
- >>  :   mean send in addition to would append to target if exist.

# File descriptor
- >&  :   syntax to redirect(>) a stream to another file descriptor
- 0 is stdin, 1 is stdout, and 2 is stderr
- Example:
'''
2>&1 >output.log        :   send standard error and standard output to the "log file".
2>&1 | tee output.log   :   same with the 2>&1, So it combines the two streams (error and output), then outputs that to the "terminal" and the "file".
'''


# combine output from two commands in bash

{ command1 & command2; }
OR
paste -d ' ' <(command1) <(command2)

# List and Tuple in Bash?
- in Bash there is no tuple and list datatype
- List: [value1, value2, value3]
- Tuple: (value1, value2, value3)
'''
Tuples are fixed size in nature whereas lists are dynamic.
In other words, a tuple is immutable whereas a list is mutable.

    You can't add elements to a tuple. Tuples have no append or extend method.
    You can't remove elements from a tuple. Tuples have no remove or pop method.
    You can find elements in a tuple, since this doesn’t change the tuple.
    You can also use the in operator to check if an element exists in the tuple.

    Tuples are faster than lists. If you're defining a constant set of values and all you're ever going to do with it is iterate through it, use a tuple instead of a list.

    It makes your code safer if you “write-protect” data that does not need to be changed. Using a tuple instead of a list is like having an implied assert statement that this data is constant, and that special thought (and a specific function) is required to override that.

    Some tuples can be used as dictionary keys (specifically, tuples that contain immutable values like strings, numbers, and other tuples). Lists can never be used as dictionary keys, because lists are not immutable.
'''
- Tuples alike use in bash: 
for i in a,b c,d;do
    IFS=',' read tuple1 tuple2 <<< ${i}
    echo "This will be a or c: ${tuple1}"
    echo "This will be b or d: ${tuple2}"
done

'''
$ ./tuple.sh 
This will be a or c: a
This will be b or d: b
This will be a or c: c
This will be b or d: d
'''

# [Regular Expression Test](https://regex101.com/)

# * Regular Expression:

^ (Caret)       = match expression at the start of string, as in ^A.
$ (Question)    = match expression at the end of a string, as in A$.
\ (Back Slash)  = turn off the special meaning of the next character, as in \^.
[ ] (Brackets)  = match any one of the enclosed characters, as in [aeiou]. Use Hyphen "-" for a range, as in [0-9].
[^ ]            = match any one character except those enclosed in [ ], as in [^0-9].
. (Period)      = match a single character of any value, except end of line.
* (Asterisk)    = match zero or more of the preceding character or expression.
{n}             = repeats n times
\{x,y\}         = match x to y occurrences of the preceding.
\{x\}           = match exactly x occurrences of the preceding.
\{x,\}          = match x or more occurrences of the preceding.

       c          Matches the non-metacharacter c.

       \c         Matches the literal character c.

       .          Matches any character including newline.

       ^          Matches the beginning of a string.

       $          Matches the end of a string.

       [abc...]   A character list: matches any of the characters abc....  You may include a range of characters by separating them with a dash.

       [^abc...]  A negated character list: matches any character except abc....

       r1|r2      Alternation: matches either r1 or r2.

       r1r2       Concatenation: matches r1, and then r2.

       r+         Matches one or more r's.

       r*         Matches zero or more r's.

       r?         Matches zero or one r's.

       (r)        Grouping: matches r.

       r{n}
       r{n,}
       r{n,m}     One  or  two  numbers  inside braces denote an interval expression.  If there is one number in the braces, the preceding regular expression r is
                  repeated n times.  If there are two numbers separated by a comma, r is repeated n to m times.  If there is one number followed by a comma,  then
                  r is repeated at least n times.


       \y         Matches the empty string at either the beginning or the end of a word.

       \B         Matches the empty string within a word.

       \<         Matches the empty string at the beginning of a word.

       \>         Matches the empty string at the end of a word.

       \s         Matches any whitespace character.

       \S         Matches any nonwhitespace character.

       \w         Matches any word-constituent character (letter, digit, or underscore).

       \W         Matches any character that is not word-constituent.

       \`         Matches the empty string at the beginning of a buffer (string).

       \'         Matches the empty string at the end of a buffer.

The escape sequences that are valid in string constants (see String Constants) are also valid in regular expressions.

A  character  class is only valid in a regular expression inside the brackets of a character list.  Character classes consist of [:, a keyword denoting the
       class, and :].  The character classes defined by the POSIX standard are:

       [:alnum:]  Alphanumeric characters.

       [:alpha:]  Alphabetic characters.

       [:blank:]  Space or tab characters.

       [:cntrl:]  Control characters.

       [:digit:]  Numeric characters.

       [:graph:]  Characters that are both printable and visible.  (A space is printable, but not visible, while an a is both.)

       [:lower:]  Lowercase alphabetic characters.

       [:print:]  Printable characters (characters that are not control characters.)

       [:punct:]  Punctuation characters (characters that are not letter, digits, control characters, or space characters).

       [:space:]  Space characters (such as space, tab, and formfeed, to name a few).

       [:upper:]  Uppercase alphabetic characters.

       [:xdigit:] Characters that are hexadecimal digits.


## Regular Expression Example: use grep or grep -E


grep '^From: ' /usr/mail/$USER    {list your mail}
grep '[a-zA-Z]'                   {any line with at least one letter}
grep '[^a-zA-Z0-9]                {anything not a letter or number}
grep '[0-9]\{3\}-[0-9]\{4\}'      {999-9999, like phone numbers}
grep '^.$'                        {lines with exactly one character}
grep '"smug"'                     {'smug' within double quotes}
grep '"*smug"*'                   {'smug', with or without quotes}
grep '^\.'                        {any line that starts with a Period "."}
grep '^\.[a-z][a-z]'              {line start with "." and 2 lc letters}

cat test.txt | grep -E '[[:upper:]]'  =>  TESTcap

^\w 
Matches the start of a string: start of string => 'start' of string

\w&
Matches the end of a string: end of string => end of 'string'

a+
Matches one or more consecutive `a` characters.: a aa aaa aaaa bab baab => 'a' 'aa' 'aaa' 'aaaa' b'a'b b'aa'b

ba*
Matches zero or more consecutive `a` characters.: a ba baa aaa ba b => a 'ba' 'baa' aaa 'ba' 'b'

ba?
Matches an `a` character or nothing.: ba b a => 'ba' 'b' a

a{3}
Matches exactly 3 consecutive `a` characters: a aa aaa aaaa  => a aa 'aaa' 'aaa'a

a{3,}
Matches at least 3 consecutive `a` characters.: a aa aaa aaaa aaaaaa => a aa 'aaa' 'aaaa' 'aaaaaa'

a{3,6}
Matches between 3 and 6 (inclusive) consecutive `a` characters.: a aa aaa aaaa aaaaaaaaaa => a aa 'aaa' 'aaaa' 'aaaaaa'aaaa

(a|b)
Matches the a or the b part of the subexpression.: beach => 'b'e'a'ch

[abc]
Matches either an a, b or c character: a bb ccc => 'a' 'bb' 'ccc'

[ABC]
Matches either an A, B or C character: A bb ccc => 'A' bb ccc

[^abc]
Matches any character except for an a, b or c: Anything but abc. => 'Anything' b'ut' abc'.'

[a-z]
Matches any characters between a and z, including a and z.: Only a-z => O'nly' 'a'-'z'

[A-Z]
Matches any characters between A and Z, including A and Z.: Only A-Z => O'nly' 'A'-'Z'

(Name test)
capture everything enclosed: Name test asdtestName test => 'Name test' asdtest'Name test'

(?|(candy)|(kiss)|(berry))
Any subpatterns in (...) in such a group share the same number.: A candy, kiss, or even a berry is delicious. => A 'candy', 'kiss', or even a 'berry' is delicious.

\w
Matches any letter, digit or underscore. Equivalent to [a-zA-Z0-9_]. : any word character => 'any' 'word' 'character'

\W
Matches anything other than a letter, digit or underscore.: not'.'a'@'word'%'character => 

[[:digit:]]
Matches any decimal digit. Equivalent to [0-9].

############################################

# single line comment

# many line comment: 
: '
This is for
multiple line comment 
in BASH
'

# 0. Shortcuts.


CTRL+A  # move to beginning of line
CTRL+B  # moves backward one character
CTRL+C  # halts the current command
CTRL+D  # deletes one character backward or logs out of current session, similar to exit
CTRL+E  # moves to end of line
CTRL+F  # moves forward one character
CTRL+G  # aborts the current editing command and ring the terminal bell
CTRL+J  # same as RETURN
CTRL+K  # deletes (kill) forward to end of line
CTRL+L  # clears screen and redisplay the line
CTRL+M  # same as RETURN
CTRL+N  # next line in command history
CTRL+O  # same as RETURN, then displays next line in history file
CTRL+P  # previous line in command history
CTRL+R  # searches backward
CTRL+S  # searches forward
CTRL+T  # transposes two characters
CTRL+U  # kills backward from point to the beginning of line
CTRL+V  # makes the next character typed verbatim
CTRL+W  # kills the word behind the cursor
CTRL+X  # lists the possible filename completefions of the current word
CTRL+Y  # retrieves (yank) last item killed
CTRL+Z  # stops the current command, resume with fg in the foreground or bg in the background

DELETE  # deletes one character backward
!!      # repeats the last command
exit    # logs out of current session


# 1. Bash Basics.


export              # displays all environment variables

echo $SHELL         # displays the shell you're using
echo $BASH_VERSION  # displays bash version

bash                # if you want to use bash (type exit to go back to your normal shell)
whereis bash        # finds out where bash is on your system

clear               # clears content on window (hide displayed lines)


# 1.1. File Commands.


ls                            # lists your files
ls -l                         # lists your files in 'long format', which contains the exact size of the file, who owns the file and who has the right to look at it, and when it was last modified
ls -a                         # lists all files, including hidden files
ln -s <filename> <link>       # creates symbolic link to file
touch <filename>              # creates or updates your file
cat > <filename>              # places standard input into file
more <filename>               # shows the first part of a file (move with space and type q to quit)
head <filename>               # outputs the first 10 lines of file
tail <filename>               # outputs the last 10 lines of file (useful with -f option)
emacs <filename>              # lets you create and edit a file
mv <filename1> <filename2>    # moves a file
cp <filename1> <filename2>    # copies a file
rm <filename>                 # removes a file
diff <filename1> <filename2>  # compares files, and shows where they differ
wc <filename>                 # tells you how many lines, words and characters there are in a file
chmod -options <filename>     # lets you change the read, write, and execute permissions on your files
gzip <filename>               # compresses files
gunzip <filename>             # uncompresses files compressed by gzip
gzcat <filename>              # lets you look at gzipped file without actually having to gunzip it
lpr <filename>                # print the file
lpq                           # check out the printer queue
lprm <jobnumber>              # remove something from the printer queue
genscript                     # converts plain text files into postscript for printing and gives you some options for formatting
dvips <filename>              # print .dvi files (i.e. files produced by LaTeX)
grep <pattern> <filenames>    # looks for the string in the files
grep -r <pattern> <dir>       # search recursively for pattern in directory


# 1.2. Directory Commands.


mkdir <dirname>  # makes a new directory
cd               # changes to home
cd <dirname>     # changes directory
pwd              # tells you where you currently are


# 1.3. SSH, System Info & Network Commands.


ssh user@host            # connects to host as user
ssh -p <port> user@host  # connects to host on specified port as user
ssh-copy-id user@host    # adds your ssh key to host for user to enable a keyed or passwordless login

whoami                   # returns your username
passwd                   # lets you change your password
quota -v                 # shows what your disk quota is
date                     # shows the current date and time
cal                      # shows the month's calendar
uptime                   # shows current uptime
w                        # displays whois online
finger <user>            # displays information about user
uname -a                 # shows kernel information
man <command>            # shows the manual for specified command
df                       # shows disk usage
du <filename>            # shows the disk usage of the files and directories in filename (du -s give only a total)
last <yourUsername>      # lists your last logins
ps -u yourusername       # lists your processes
kill <PID>               # kills (ends) the processes with the ID you gave
killall <processname>    # kill all processes with the name
top                      # displays your currently active processes
bg                       # lists stopped or background jobs ; resume a stopped job in the background
fg                       # brings the most recent job in the foreground
fg <job>                 # brings job to the foreground

ping <host>              # pings host and outputs results
whois <domain>           # gets whois information for domain
dig <domain>             # gets DNS information for domain
dig -x <host>            # reverses lookup host
wget <file>              # downloads file


# 2. Basic Shell Programming.


# 2.1. Variables.


varname=value                # defines a variable
varname=value command        # defines a variable to be in the environment of a particular subprocess
echo $varname                # checks a variable's value
echo $$                      # prints process ID of the current shell
echo $!                      # prints process ID of the most recently invoked background job
echo $?                      # displays the exit status of the last command
        Exit code 0        Success
        Exit code 1        General errors, Miscellaneous errors, such as "divide by zero" and other impermissible operations
        Exit code 2        Misuse of shell builtins (according to Bash documentation) 

export VARNAME=value         # defines an environment variable (will be available in subprocesses)

array[0] = val               # several ways to define an array
array[1] = val
array[2] = val
array=([2]=val [0]=val [1]=val)
array(val val val)

${array[i]}                  # displays array's value for this index. If no index is supplied, array element 0 is assumed
${#array[i]}                 # to find out the length of any element in the array
${#array[@]}                 # to find out how many values there are in the array
$@                           # is equal to "$1" "$2"... "$N", where N is the number of positional parameters. 
$#                           # holds the number of positional parameters.

declare -a                   # the variables are treaded as arrays
declare -f                   # uses funtion names only
declare -F                   # displays function names without definitions
declare -i                   # the variables are treaded as integers
declare -r                   # makes the variables read-only
declare -x                   # marks the variables for export via the environment

${varname:-word}             # if varname exists and isn't null, return its value; otherwise return word
${varname:=word}             # if varname exists and isn't null, return its value; otherwise set it word and then return its value
${varname:?message}          # if varname exists and isn't null, return its value; otherwise print varname, followed by message and abort the current command or script
${varname:+word}             # if varname exists and isn't null, return word; otherwise return null
${varname:offset:length}     # performs substring expansion. It returns the substring of $varname starting at offset and up to length characters

${variable#pattern}          # if the pattern matches the beginning of the variable's value, delete the shortest part that matches and return the rest
${variable##pattern}         # if the pattern matches the beginning of the variable's value, delete the longest part that matches and return the rest
${variable%pattern}          # if the pattern matches the end of the variable's value, delete the shortest part that matches and return the rest
${variable%%pattern}         # if the pattern matches the end of the variable's value, delete the longest part that matches and return the rest
${variable/pattern/string}   # the longest match to pattern in variable is replaced by string. Only the first match is replaced
${variable//pattern/string}  # the longest match to pattern in variable is replaced by string. All matches are replaced

${#varname}                  # returns the length of the value of the variable as a character string

*(patternlist)               # matches zero or more occurences of the given patterns
+(patternlist)               # matches one or more occurences of the given patterns
?(patternlist)               # matches zero or one occurence of the given patterns
@(patternlist)               # matches exactly one of the given patterns
!(patternlist)               # matches anything except one of the given patterns

$(UNIX command)              # command substitution: runs the command and returns standard output


# 2.2. Functions.
# The function refers to passed arguments by position (as if they were positional parameters), that is, $1, $2, and so forth.
# $@ is equal to "$1" "$2"... "$N", where N is the number of positional parameters. $# holds the number of positional parameters.


functname() {
  shell commands
}

unset -f functname  # deletes a function definition
declare -f          # displays all defined functions in your login session


# 2.3. Flow Control.


statement1 && statement2  # and operator
statement1 || statement2  # or operator

-a                        # and operator inside a test conditional expression
-o                        # or operator inside a test conditional expression

str1=str2                 # str1 matches str2
str1!=str2                # str1 does not match str2
str1<str2                 # str1 is less than str2
str1>str2                 # str1 is greater than str2
-n str1                   # str1 is not null (has length greater than 0)
-z str1                   # str1 is null (has length 0)

-a file                   # file exists
-d file                   # file exists and is a directory
-e file                   # file exists; same -a
-f file                   # file exists and is a regular file (i.e., not a directory or other special type of file)
-r file                   # you have read permission
-r file                   # file exists and is not empty
-s file                   # True if file exists and has a size greater than zero.
-w file                   # your have write permission
-x file                   # you have execute permission on file, or directory search permission if it is a directory
-N file                   # file was modified since it was last read
-O file                   # you own file
-G file                   # file's group ID matches yours (or one of yours, if you are in multiple groups)
file1 -nt file2           # file1 is newer than file2
file1 -ot file2           # file1 is older than file2

-lt                       # less than
-le                       # less than or equal
-eq                       # equal
-ge                       # greater than or equal
-gt                       # greater than
-ne                       # not equal

#[Loop, condition, statements]

if condition
then
  statements
[elif condition
  then statements...]
[else
  statements]
fi

for x := 1 to 10 do
begin
  statements
end

for ((i=1; i<=${max}; i++))
do
	statements
done

for name [in list]
do
  statements that can use $name
done

for (( initialisation ; ending condition ; update ))
do
  statements...
done

case expression in
  pattern1 )
    statements ;;
  pattern2 )
    statements ;;
  ...
esac

---------------
[Select_statement] https://bash.cyberciti.biz/guide/Select_loop

select varname [in list]
do
  statements that can use $varname
done

*** OR (combine both select and case statement)***

select varName in list
do
  case $varName in
    pattern1)
      command1;;
    pattern2)
      command2;;
    pattern1)
      command3;;
    *)
      echo "Error select option 1..3";;
  esac      
done

- Select command use "PS3" variable to print its prompt.
- Each word in list is printed on screen preceded by a number.
- The loop continues until a break (CTRL+C) is encountered.

Example: 
#!/bin/bash
# Set PS3 prompt
PS3="Enter the space shuttle to get more information : "

# set shuttle list
select shuttle in columbia endeavour challenger discovery atlantis enterprise pathfinder
....
Output:
1) columbia    3) challenger  5) atlantis    7) pathfinder
2) endeavour   4) discovery   6) enterprise
Enter the space shuttle name to get more information : 1

---------------


while condition; do
  statements
done

until condition; do
  statements
done


- Using break in a bash for quitting the loop

```
for i in [series]
do
        command 1
        command 2
        if (condition) # Condition to break the loop
        then
                command 4 # Command if the loop needs to be broken
                break
        fi
        command 5 # Command to run if the "condition" is never true 
done
```

- Using continue in a bash for skip to the next value of variable the loop:

```
for i in [series]
do
        command 1
        command 2
        if (condition) # Condition to jump over command 3
                continue # skip to the next value in "series"
        fi
        command 3
done
```


# 3. Command-Line Processing Cycle.


# The default order for command lookup is functions, followed by built-ins, with scripts and executables last.
# There are three built-ins that you can use to override this order: `command`, `builtin` and `enable`.

command  # removes alias and function lookup. Only built-ins and commands found in the search path are executed
builtin  # looks up only built-in commands, ignoring functions and commands found in PATH
enable   # enables and disables shell built-ins

eval     # takes arguments and run them through the command-line processing steps all over again


# 4. Input/Output Redirectors.


cmd1|cmd2  # pipe; takes standard output of cmd1 as standard input to cmd2
> file     # directs standard output to file
< file     # takes standard input from file
>> file    # directs standard output to file; append to file if it already exists
>|file     # forces standard output to file even if noclobber is set
n>|file    # forces output to file from file descriptor n even if noclobber is set
<> file    # uses file as both standard input and standard output
n<>file    # uses file as both input and output for file descriptor n
<<label    # here-document
n>file     # directs file descriptor n to file
n<file     # takes file descriptor n from file
n>>file    # directs file description n to file; append to file if it already exists
n>&        # duplicates standard output to file descriptor n
n<&        # duplicates standard input from file descriptor n
n>&m       # file descriptor n is made to be a copy of the output file descriptor
n<&m       # file descriptor n is made to be a copy of the input file descriptor
&>file     # directs standard output and standard error to file
<&-        # closes the standard input
>&-        # closes the standard output
n>&-       # closes the ouput from file descriptor n
n<&-       # closes the input from file descripor n


# 5. Process Handling.


# To suspend a job, type CTRL+Z while it is running. You can also suspend a job with CTRL+Y.
# This is slightly different from CTRL+Z in that the process is only stopped when it attempts to read input from terminal.
# Of course, to interupt a job, type CTRL+C.

myCommand &  # runs job in the background and prompts back the shell

jobs         # lists all jobs (use with -l to see associated PID)

fg           # brings a background job into the foreground
fg %+        # brings most recently invoked background job
fg %-        # brings second most recently invoked background job
fg %N        # brings job number N
fg %string   # brings job whose command begins with string
fg %?string  # brings job whose command contains string

kill -l      # returns a list of all signals on the system, by name and number
kill PID     # terminates process with specified PID

ps           # prints a line of information about the current running login shell and any processes running under it
ps -a        # selects all processes with a tty except session leaders

trap cmd sig1 sig2  # executes a command when a signal is received by the script
trap "" sig1 sig2   # ignores that signals
trap - sig1 sig2    # resets the action taken when the signal is received to the default

disown <PID|JID>    # removes the process from the list of jobs

wait                # waits until all background jobs have finished


# 6. Tips and Tricks.


# set an alias
cd; nano .bash_profile
> alias gentlenode='ssh admin@gentlenode.com -p 3404'  # add your alias in .bash_profile

# to quickly go to a specific directory
cd; nano .bashrc
> shopt -s cdable_vars
> export websites="/Users/mac/Documents/websites"

source .bashrc
cd websites


# 7. Debugging Shell Programs.


bash -n scriptname  # don't run commands; check for syntax errors only
set -o noexec       # alternative (set option in script)

bash -v scriptname  # echo commands before running them
set -o verbose      # alternative (set option in script)

bash -x scriptname  # echo commands after command-line processing
set -o xtrace       # alternative (set option in script)

trap 'echo $varname' EXIT  # useful when you want to print out the values of variables at the point that your script exits

function errtrap {
  es=$?
  echo "ERROR line $1: Command exited with status $es."
}

trap 'errtrap $LINENO' ERR  # is run whenever a command in the surrounding script or function exists with non-zero status 

function dbgtrap {
  echo "badvar is $badvar"
}

trap dbgtrap DEBUG  # causes the trap code to be executed before every statement in a function or script
# ...section of code in which the problem occurs...
trap - DEBUG  # turn off the DEBUG trap

function returntrap {
  echo "A return occured"
}

trap returntrap RETURN  # is executed each time a shell function or a script executed with the . or source commands finishes executing

