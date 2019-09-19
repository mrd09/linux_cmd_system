---------------- Measure curl response time ---------------

https://stackoverflow.com/questions/18215389/how-do-i-measure-request-and-response-times-at-once-using-curl

- Create a new file, curl-format.txt, and paste in:
```
    time_namelookup:  %{time_namelookup}\n
       time_connect:  %{time_connect}\n
    time_appconnect:  %{time_appconnect}\n
   time_pretransfer:  %{time_pretransfer}\n
      time_redirect:  %{time_redirect}\n
 time_starttransfer:  %{time_starttransfer}\n
                    ----------\n
         time_total:  %{time_total}\n
```

- use curl with -w option:
curl -w "@curl-format.txt" -o /dev/null -s "http://wordpress.com/"

- What this does:
```
-w "@curl-format.txt" tells cURL to use our format file