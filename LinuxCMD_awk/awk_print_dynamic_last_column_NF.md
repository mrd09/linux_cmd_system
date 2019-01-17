- Situation:
```
Exemple: File1

A    3    8    6    7
B    4    6    2    3    6    8
c    1    9

would return:

7
8
9
```
- You can make smart use of the NF variable in awk
`awk '{print $NF}' File1`

- From man awk
   ` NF The number of fields in the current input record.`

- So NF will give you the amount of fields and $NF will then expand to $3 for example, which you can use in a print statement.
