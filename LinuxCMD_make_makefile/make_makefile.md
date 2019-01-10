# A tutorial by example
- **Makefiles are special format files** that together with the **make utility** will help you to **automagically build and manage your projects**.For this session you will need these files:
```
    main.cpp
    hello.cpp
    factorial.cpp
    functions.h
```

# 1. The make utility:
- If you run: `make`
    - this program will **look for a file named makefile** in your directory, and then **execute it**.
- If you have **several makefiles**, then you can execute them with the command:
```
make -f MyMakefile
```

- There are several other switches to the make utility. For more info, man make.

## 1.1. Build Process
- **Compiler**  :   **takes the source files** and **outputs object files**
- **Linker**    :   **takes the object files** and **creates an executable**

## 1.2. Compiling by hand
- The trivial way to compile the files and obtain an executable, is by running the command:
```
g++ main.cpp hello.cpp factorial.cpp -o hello
```

# 2. The basic Makefile
- The basic makefile is composed of:
```
target: dependencies
[tab] system command
```

## 2.1. Using dependencies:
- Example:
```
all: hello

hello: main.o factorial.o hello.o
    g++ main.o factorial.o hello.o -o hello

main.o: main.cpp
    g++ -c main.cpp

factorial.o: factorial.cpp
    g++ -c factorial.cpp

hello.o: hello.cpp
    g++ -c hello.cpp

clean:
    rm *o hello
```

## 2.2. Using variables and comments
- You can also use variables when writing Makefiles. It comes in handy in situations where you want to change the compiler, or the compiler options.
    + just **assign a value to a variable** before you start to write your targets. **"A = value"**
    + After that, you can just **use them** with the dereference operator **$(VAR)**

```
# I am a comment, and I want to say that the variable CC will be
# the compiler to use.
CC=g++
# Hey!, I am comment number 2. I want to say that CFLAGS will be the
# options I'll pass to the compiler.
CFLAGS=-c -Wall

all: hello

hello: main.o factorial.o hello.o
    $(CC) main.o factorial.o hello.o -o hello

main.o: main.cpp
    $(CC) $(CFLAGS) main.cpp

factorial.o: factorial.cpp
    $(CC) $(CFLAGS) factorial.cpp

hello.o: hello.cpp
    $(CC) $(CFLAGS) hello.cpp

clean:
    rm *o hello
```

# 3. Full example:
- Example:
```
CC=g++
CFLAGS=-c -Wall
LDFLAGS=
SOURCES=main.cpp hello.cpp factorial.cpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=hello

all: $(SOURCES) $(EXECUTABLE)
    
$(EXECUTABLE): $(OBJECTS) 
    $(CC) $(LDFLAGS) $(OBJECTS) -o $@

.cpp.o:
    $(CC) $(CFLAGS) $< -o $@
```