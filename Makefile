# Copyright 2003 Marcin Siennicki <m.siennicki@cloos.pl>
# see COPYING file for details 

VERSION = 0
REVISION = 9
MINOR = 4
AGE = 0

FULLVERSION = $(VERSION).$(REVISION).$(MINOR)

DISTNAME = libcssl-$(FULLVERSION)

SOURCEFILES = Makefile README INSTALL COPYING \
	test.c cssl.c cssl.h libcssl.spec libcssl.spec.in

SRPMPATH = /usr/src/redhat/SRPMS

RPMPATH = /usr/src/redhat/RPMS/i386

SRPMNAME = $(DISTNAME)-1.src.rpm

RPMNAME = $(DISTNAME)-1.i386.rpm

ifndef PREFIX
PREFIX = /usr
endif

LIBPATH = $(PREFIX)/lib
INCLUDEPATH = $(PREFIX)/include
PKGCONFIGPATH = $(PREFIX)/lib/pkgconfig

all: libcssl.la test libcssl.pc

cssl.lo: cssl.c Makefile
	libtool gcc -Wall -D_GNU_SOURCE -g -O -c cssl.c

libcssl.la: cssl.lo
	libtool gcc -g -O -o libcssl.la -rpath $(LIBPATH)\
	-version-info $(VERSION):$(REVISION):$(AGE)\
	cssl.lo

test.o:	test.c
	libtool gcc -Wall -D_GNU_SOURCE -g -O -c test.c

test:	test.o libcssl.la
	libtool gcc -g -O -o test test.o libcssl.la

test.shared: test.c
	gcc -g -O -o test.shared test.c -lcssl

install: libcssl.la cssl.h libcssl.pc
	install -d $(LIBPATH) $(INCLUDEPATH) $(PKGCONFIGPATH)
	libtool install -c libcssl.la $(LIBPATH) 
	install -c cssl.h $(INCLUDEPATH)
	install -c libcssl.pc $(PKGCONFIGPATH)

dist:	libcssl.spec
	rm -rf $(DISTNAME)
	mkdir $(DISTNAME)
	for i in $(SOURCEFILES) ; { ln $$i $(DISTNAME)/$$i ; }
	tar -czf $(DISTNAME).tar.gz $(DISTNAME)

libcssl.spec: Makefile libcssl.spec.in
	m4 -D____CSSL_VERSION____=$(FULLVERSION) libcssl.spec.in > libcssl.spec

libcssl.pc: Makefile
	echo "prefix=$(PREFIX)" > $@
	echo "exec_prefix=$(PREFIX)" >> $@
	echo "libdir=$(LIBPATH)">> $@
	echo "includedir=$(INCLUDEPATH)" >> $@
	echo "" >> $@
	echo "Name: libcssl-$(VERSION).$(REVISION)" >> $@
	echo "Description: a serial port communication library" >> $@
	echo "Version: $(VERSION).$(REVISION).$(MINOR)" >> $@
	echo "Libs: -L\$${libdir} -lcssl" >> $@
	echo "Cflags: -I\$${includedir}" >> $@

rpm:	dist
	rpmbuild -ta $(DISTNAME).tar.gz
	mv $(SRPMPATH)/$(SRPMNAME) .
	mv $(RPMPATH)/$(RPMNAME) .

clean:
	rm -fr .libs test test.shared *.la *.lo *.o *~ $(DISTNAME) *.gz *.rpm libcssl.spec
