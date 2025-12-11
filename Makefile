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
LDFLAGS_STATIC ?= -static
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib

# Versioned library names
LIBNAME := libtest
LIB_MAJOR := 1
LIB_MINOR := 0.0

LIB_SO := $(LIBNAME).so
LIB_REAL := $(LIBNAME).so.$(LIB_MAJOR).$(LIB_MINOR)
LIB_SONAME := $(LIBNAME).so.$(LIB_MAJOR)
LIB_STATIC := $(LIBNAME).a

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


# Versioned shared library
$(LIB_REAL): $(OBJS_PIC)
	$(CC) $(LDFLAGS) $(LDFLAGS_SHARED) -Wl,-soname,$(LIB_SONAME) -o $@ $^

# Symlinks
$(LIB_SONAME): $(LIB_REAL)
	ln -sf $(LIB_REAL) $(LIB_SONAME)

$(LIB_SO): $(LIB_SONAME)
	ln -sf $(LIB_SONAME) $(LIB_SO)

# Build helloworld with static lib
helloworld-static: helloworld.o $(LIB_STATIC)
	$(CC) $(LDFLAGS_STATIC) -o $@ $< -L. -lm -ltest $(LDFLAGS)

# Build helloworld with shared lib
helloworld-shared: helloworld.o $(LIB_SO)
	$(CC) -o $@ $< -L. -lm -ltest $(LDFLAGS) 

#helloworld.o: helloworld.c
#	$(CC) $(CFLAGS) -c $< -o $@

# Clean all generated files
clean:
	rm -f *.o *.pic.o *.a *.so helloworld-static helloworld-shared

.PHONY: install

install: all
	# Create destination directories
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(LIBDIR)

	# Install the two helloworld binaries
	install -m 0755 helloworld-static $(DESTDIR)$(BINDIR)/
	install -m 0755 helloworld-shared $(DESTDIR)$(BINDIR)/

	# Install the real library
	install -m 0755 $(LIB_REAL) $(DESTDIR)$(LIBDIR)/
	
	# install symlinks
	ln -sf $(LIB_REAL) $(DESTDIR)$(LIBDIR)/$(LIB_SONAME)
	ln -sf $(LIB_SONAME) $(DESTDIR)$(LIBDIR)/$(LIB_SO)

	# Install the static lib
	install -m 0644 $(LIB_STATIC) $(DESTDIR)$(LIBDIR)/
