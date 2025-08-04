# Toolchain prefix (can be overriden when calling make)
CROSS_COMPILE ?=

# Compiler and flags
# A note on variable assingments in Makefile
# := immediate assignment, the value is evaluated right away, at the time the variable is defined
# = lazy (deferred) assignment, the value is evaluated when the variable is used, not when it's defined

CC ?= gcc
AR ?= ar
ARFLAGS ?= rcs
CFLAGS ?= -Wall -Wextra -O2
PICFLAGS ?= -fPIC
LDFLAGS_SHARED ?= -shared

LIB_SHARED := libtest.so
LIB_STATIC := libtest.a

OBJS := test1.o test2.o
OBJS_PIC := test1.pic.o test2.pic.o
MAIN_OBJ := main.op

.PHONY: all clean

all: helloworld-static helloworld-shared

# Object files (normal)
# $< is an automatic variable which expands to the first prerequisite in the line
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@ 

# Static library
# $@ is an automatic variable which expands to the name of the target of the rule
# $^ is an automatic variable which expands to the list of all prerequisites (dependencies)
$(LIB_STATIC): $(OBJS)
	$(AR) $(ARFLAGS) $@ $^ 

# Object files with PIC for shared libs
%.pic.o: %.c
	$(CC) $(CFLAGS) $(PICFLAGS) -c $< -o $@ 

# Shared library
$(LIB_SHARED): $(OBJS_PIC)
	$(CC) $(LDFLAGS) $(LDFLAGS_SHARED) -o $@ $^ 

# Build helloworld with static lib
helloworld-static: helloworld.o $(LIB_STATIC)
	$(CC) -o $@ $< -L. -lm -ltest $(LDFLAGS)

# Build helloworld with shared lib
helloworld-shared: helloworld.o $(LIB_SHARED)
	$(CC) -o $@ $< -L. -lm -ltest $(LDFLAGS) -Wl,-soname,litest.so.1

#helloworld.o: helloworld.c
#	$(CC) $(CFLAGS) -c $< -o $@

# Clean all generated files
clean:
	rm -f *.o *.pic.o *.a *.so helloworld-static helloworld-shared

