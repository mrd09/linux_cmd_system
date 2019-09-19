----------------- jq ---------------------
NAME
       jq - Command-line JSON processor

# SYNOPSIS
       jq [options...] filter [files...]

       jq  can transform JSON in various ways, by selecting, iterating, reducing and otherwise mangling JSON documents. For instance, running the command jq ´map(.price) | add´ will take an array of
       JSON objects as input and return the sum of their "price" fields.

       jq can accept text input as well, but by default, jq reads a stream of JSON entities (including numbers and other literals) from stdin. Whitespace is only needed to separate entities such  as
       1 and 2, and true and false. One or more files may be specified, in which case jq will read input from those instead.

       The  options  are described in the INVOKING JQ section; they mostly concern input and output formatting. The filter is written in the jq language and specifies how to transform the input file
       or document.

# INVOKING JQ
       jq filters run on a stream of JSON data. The input to jq is parsed as a sequence of whitespace-separated JSON values which are passed through the provided filter one at a time. The  output(s)
       of the filter are written to standard out, again as a sequence of whitespace-separated JSON data.

       Note: it is important to mind the shell´s quoting rules. As a general rule it´s best to always quote (with single-quote characters) the jq program, as too many characters with special meaning
       to jq are also shell meta-characters. For example, jq "foo" will fail on most Unix shells because that will be the same as jq foo, which will generally fail because foo is not  defined.  When
       using  the Windows command shell (cmd.exe) it´s best to use double quotes around your jq program when given on the command-line (instead of the -f program-file option), but then double-quotes
       in the jq program need backslash escaping.

       You can affect how jq reads and writes its input and output using some command-line options:

##  --raw-output / -r: filter´s result is a string

           With  this  option, if the filter´s result is a string then it will be written directly to standard output rather than being formatted as a JSON string with quotes. This can be useful for
           making jq filters talk to non-JSON-based systems.

# BASIC FILTERS
##   .
       The absolute simplest (and least interesting) filter is .. This is a filter that takes its input and produces it unchanged as output.

       Since jq by default pretty-prints all output, this trivial program can be a useful way of formatting JSON output from, say, curl.

           jq ´.´
              "Hello, world!"
           => "Hello, world!"

##   .[]: return all of the elements of an array
       If  you  use  the  .[index]  syntax, but omit the index entirely, it will return all of the elements of an array. Running .[] with the input [1,2,3] will produce the numbers as three separate
       results, rather than as a single array.

       You can also use this on an object, and it will return all the values of the object.

           jq ´.[]´
              [{"name":"JSON", "good":true}, {"name":"XML", "good":false}]
           => {"name":"JSON", "good":true}, {"name":"XML", "good":false}

           jq ´.[]´
              []
           =>

           jq ´.[]´
              {"a": 1, "b": 1}
           => 1, 1


# BUILTIN OPERATORS AND FUNCTIONS
       Some jq operator (for instance, +) do different things depending on the type of their arguments (arrays, numbers, etc.). However, jq never does implicit type conversions. If you try to add  a
       string to an object you´ll get an error message and no result.

##     length: get the length of string, array, object, null:
       The builtin function length gets the length of various different types of value:

       ·   The length of a string is the number of Unicode codepoints it contains (which will be the same as its JSON-encoded length in bytes if it´s pure ASCII).

       ·   The length of an array is the number of elements.

       ·   The length of an object is the number of key-value pairs.

       ·   The length of null is zero.

           jq ´.[] | length´ [[1,2], "string", {"a":2}, null] => 2, 6, 1, 0

##  keys, keys_unsorted: returns its keys in an array
       The builtin function keys, when given an object, returns its keys in an array.

       The  keys  are sorted "alphabetically", by unicode codepoint order. This is not an order that makes particular sense in any particular language, but you can count on it being the same for any
       two objects with the same set of keys, regardless of locale settings.

       When keys is given an array, it returns the valid indices for that array: the integers from 0 to length-1.

       The keys_unsorted function is just like keys, but if the input is an object then the keys will not be sorted, instead the keys will roughly be in insertion order.

           jq ´keys´
              {"abc": 1, "abcd": 2, "Foo": 3}
           => ["Foo", "abc", "abcd"]

           jq ´keys´
              [42,3,35]
           => [0,1,2]

##  select(boolean_expression)
       The function select(foo) produces its input unchanged if foo returns true for that input, and produces no output otherwise.

       It´s useful for filtering lists: [1,2,3] | map(select(. >= 2)) will give you [2,3].

           jq ´map(select(. >= 2))´
              [1,5,3,0,7]
           => [5,3,7]

           jq ´.[] | select(.id == "second")´
              [{"id": "first", "val": 1}, {"id": "second", "val": 2}]
           => {"id": "second", "val": 2}

# Example:
- json file example:
```
{
  "test_user": [
    {
      "gid": 1,
      "homedir": "/test",
      "name": "test1",
      "password": "asdf",
      "uid": 1
    }
  ],
  "test_user2": [
    {
      "gid": 2,
      "homedir": "/test2",
      "name": "test2",
      "password": "asdf",
      "uid": 2
    }
  ]
}  
```

##  Extract keys from json file:
- Get
```
$ jq -r '. | keys | .[]' users.json-decode
test_user
test_user2
```

##  Extract value from key:
```
$ jq -r '.test_user' users.json-decode
[
    {
      "gid": 1,
      "homedir": "/test",
      "name": "test1",
      "password": "asdf",
      "uid": 1
    }
]
```

##  Get the length of an array: is the number of elements
```
$ jq -r '.bank_user' users.json-decode | length  # The length of an array is the number of elements.
1
```

##  Get the "map's value" from "key[index].map's key":
```
$ jq -r .test_user[0].name users.json-decode 
test1
```

##  Select objects based on value of variable in object using jq
https://stackoverflow.com/questions/18592173/select-objects-based-on-value-of-variable-in-object-using-jq

- Example json:
```
{
    "FOO": {
        "name": "Donald",
        "location": "Stockholm"
    },
    "BAR": {
        "name": "Walt",
        "location": "Stockholm"
    },
    "BAZ": {
        "name": "Jack",
        "location": "Whereever"
    }
}
```
- Extract:
```
$ jq '.[] | select(.location=="Stockholm")' json
{
  "location": "Stockholm",
  "name": "Walt"
}
{
  "location": "Stockholm",
  "name": "Donald"
}
```