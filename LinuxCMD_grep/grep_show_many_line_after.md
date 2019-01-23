 -A NUM, --after-context=NUM
              Print NUM lines of trailing context after matching lines.  Places a line containing a group separator (--) between  contiguous  groups  of  matches.
              With the -o or --only-matching option, this has no effect and a warning is given.

-B NUM, --before-context=NUM
              Print  NUM  lines  of  leading context before matching lines.  Places a line containing a group separator (--) between contiguous groups of matches.
              With the -o or --only-matching option, this has no effect and a warning is given.

- Useful when search the ansible inventory file:
```
$ grep -A3 'wallet-ha' dev
[wallet-ha]
1.1.1.1
2.2.2.2
```              