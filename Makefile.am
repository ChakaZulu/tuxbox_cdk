TARGET = powerpc-tuxbox-linux-gnu

PATH := $(hostprefix)/bin:$(PATH)

bootstrap: .gcc

$(hostprefix)/bin/$(TARGET)-gcc:
	if [ -f $(hostprefix)/$(TARGET)/lib/libc.so ]; then \
		make .gcc; \
	else \
		make bootstrap_gcc; \
	fi

#######################
#
#   core
#

.directories:
	install -d $(targetprefix)/dev
	install -d $(targetprefix)/proc
	install -d $(targetprefix)/include
	install -d $(targetprefix)/lib
	install -d $(hostprefix)/$(TARGET)
	-rm $(hostprefix)/$(TARGET)/include
	-rm $(hostprefix)/$(TARGET)/lib
	ln -s $(targetprefix)/include $(hostprefix)/$(TARGET)/include
	install -d $(hostprefix)/$(TARGET)/sys-include
	ln -s $(targetprefix)/lib $(hostprefix)/$(TARGET)/lib
	ln -s $(buildprefix)/linux-$(KERNELVERSION)/include/asm $(hostprefix)/$(TARGET)/include
	ln -s $(buildprefix)/linux-$(KERNELVERSION)/include/linux $(hostprefix)/$(TARGET)/include
	touch .directories

.linuxdir: .directories @DEPENDS_linuxdir@
	@PREPARE_linuxdir@
	cat Patches/linux-$(KERNELVERSION).dbox.config > linux-$(KERNELVERSION)/.config
	make -C linux-$(KERNELVERSION) oldconfig
	make -C linux-$(KERNELVERSION) include/linux/version.h
	touch .linuxdir

.binutils: .directories @DEPENDS_binutils@
	@PREPARE_binutils@
	cd @DIR_binutils@ && @CONFIGURE_binutils@ \
		--target=$(TARGET) \
		--prefix=$(hostprefix) \
		--nfp
	make -C @DIR_binutils@ all install
	@CLEANUP_binutils@
	touch .binutils

#
# gcc first stage without glibc
#
bootstrap_gcc: .binutils .linuxdir @DEPENDS_bootstrap_gcc@
	@PREPARE_bootstrap_gcc@
	cp -a $(buildprefix)/linux-$(KERNELVERSION)/include/asm $(hostprefix)/$(TARGET)/sys-include/
	cd @DIR_bootstrap_gcc@ && @CONFIGURE_bootstrap_gcc@ \
		--target=$(TARGET) \
		--prefix=$(hostprefix) \
		--with-cpu=823 \
		--enable-target-optspace \
		--enable-languages="c" \
		--disable-shared \
		--disable-nls \
		--nfp
	make -C @DIR_bootstrap_gcc@ all install
	rm -rf $(hostprefix)/$(TARGET)/sys-include/asm
	@CLEANUP_bootstrap_gcc@

.glibc: $(hostprefix)/bin/$(TARGET)-gcc @DEPENDS_glibc@
	@PREPARE_glibc@
	cd @DIR_glibc@ && \
	CC=$(TARGET)-gcc AR=$(TARGET)-ar RANLIB=$(TARGET)-ranlib CFLAGS="$(TARGET_CFLAGS)" \
	@CONFIGURE_glibc@ \
		--build=$(BUILD) \
		--host=$(TARGET) \
		--prefix= \
		--with-headers=$(buildprefix)/linux-$(KERNELVERSION)/include \
		--enable-kernel=$(KERNELVERSION) \
		--disable-profile \
		--enable-shared \
		--enable-add-ons=linuxthreads \
		--without-fp
	make -C @DIR_glibc@ all install install_root=$(targetprefix)
	@CLEANUP_glibc@
	touch .glibc

#
# gcc second stage with glibc
#
.gcc: .glibc @DEPENDS_gcc@
	@PREPARE_gcc@
	cp -a $(hostprefix)/$(TARGET)/include/limits.h $(hostprefix)/$(TARGET)/sys-include/
	cd @DIR_gcc@ && @CONFIGURE_gcc@ \
		--target=$(TARGET) \
		--prefix=$(hostprefix) \
		--with-cpu=823 \
		--enable-target-optspace \
		--enable-languages="c,c++" \
		--enable-shared \
		--enable-threads \
		--disable-nls \
		--nfp
	make -C @DIR_gcc@ all install
	rm -rf $(hostprefix)/$(TARGET)/sys-include/limits.h
	@CLEANUP_gcc@
	touch .gcc

#######################
#
#   minimal root
#

.busybox: .gcc @DEPENDS_busybox@
	@PREPARE_busybox@
	make -C @DIR_busybox@ CROSS=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	make -C @DIR_busybox@ install PREFIX=$(targetprefix)
	@CLEANUP_busybox@
	touch .busybox

#######################
#
#   contrib libs
#

.libcurl: .gcc @DEPENDS_libcurl@
	@PREPARE_libcurl@
	cd @DIR_libcurl@ && \
	CC=$(TARGET)-gcc CXX=$(TARGET)-g++ CFLAGS="$(TARGET_CFLAGS)" \
	./configure \
		--host=$(TARGET) \
		--prefix=$(targetprefix) \
		--with-random=no \
		--with-ssl=no
	make -C @DIR_libcurl@ all install
	-rm $(hostprefix)/bin/curl-config
	ln -s $(targetprefix)/bin/curl-config $(hostprefix)/bin
	@CLEANUP_libcurl@
	touch .libcurl
	
.libfreetype: .gcc @DEPENDS_libfreetype@
	@PREPARE_libfreetype@
	make -C @DIR_libfreetype@ \
		CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" \
		CFG="--host=${TARGET} --prefix=${targetprefix}"
	make -C @DIR_libfreetype@ all install
	-rm $(hostprefix)/bin/freetype-config
	ln -s $(targetprefix)/bin/freetype-config $(hostprefix)/bin
	@CLEANUP_libfreetype@
	touch .libfreetype

.libncurses: .gcc @DEPENDS_libncurses@
	@PREPARE_libncurses@
	cd @DIR_libncurses@ && \
	CC=$(TARGET)-gcc CXX=$(TARGET)-g++ CFLAGS="$(TARGET_CFLAGS)" BUILD_CC=gcc \
	./configure \
		--build=$(BUILD) \
		--host=$(TARGET) \
		--prefix=$(targetprefix) \
		--disable-big-core \
		--without-debug \
		--without-progs \
		--without-ada \
		--with-shared \
		--without-profile \
		--disable-rpath \
		--without-cxx-binding \
		--with-fallbacks='linux vt100 xterm'
	make -C @DIR_libncurses@ install.libs install.includes
	@CLEANUP_libncurses@
	touch .libncurses

.libjpeg: .gcc @DEPENDS_libjpeg@
	@PREPARE_libjpeg@
	cd @DIR_libjpeg@ && \
	CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" \
	./configure \
		--host=$(TARGET) \
		--prefix=$(targetprefix)
	make -C @DIR_libjpeg@ install-lib
	@CLEANUP_libjpeg@
	touch .libjpeg

.libpng: .gcc .libz @DEPENDS_libpng@
	@PREPARE_libpng@
	cp @DIR_libpng@/scripts/makefile.linux @DIR_libpng@/Makefile
	make -C @DIR_libpng@ install CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS) -DPNG_DEBUG=0" prefix=$(targetprefix)
	@CLEANUP_libpng@
	touch .libpng

#
# qt embedded (current only moc)
#
.libqt: .gcc .libfreetype .libjpeg .libpng .libz @DEPENDS_libqt@
	@PREPARE_libqt@
	cd @DIR_libqt@ && \
	QTDIR=`pwd` \
	./configure \
		-platform linux-x86-g++ \
		-xplatform linux-powerpc-g++ \
		-system-zlib \
		-system-jpeg \
		-system-libpng \
		-qconfig dbox \
		-qvfb \
		-depths 4,8,16,24,32 && \
	make -C src/moc QTDIR=`pwd`
	install @DIR_libqt@/src/moc/moc $(hostprefix)/bin
	@CLEANUP_libqt@
	touch .libqt

.libxml2: .gcc @DEPENDS_libxml2@
	@PREPARE_libxml2@
	cd @DIR_libxml2@ && \
	CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" \
	./configure \
		--host=$(TARGET) \
		--prefix=$(targetprefix) \
		--without-html-dir --with-threads --without-ftp --without-http --without-html \
		--without-catalog --without-docbook --without-xpath --without-xptr \
		--without-xinclude --without-iconv --without-debug --without-mem-debug
	make -C @DIR_libxml2@ all install
	-rm $(hostprefix)/bin/xml2-config
	ln -s $(targetprefix)/bin/xml2-config $(hostprefix)/bin
	@CLEANUP_libxml2@
	touch .libxml2

.libz: .gcc @DEPENDS_libz@
	@PREPARE_libz@
	cd @DIR_libz@ && CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" \
	./configure \
		--prefix=$(targetprefix) \
		--shared
	make -C @DIR_libz@ libz.so.1.1.3 install
	@CLEANUP_libz@
	touch .libz

#######################
#
#   own applications
#

apps/Makefile: .libxml2 .freetype .libqte .curl
	cd apps && ./autogen.sh && \
	./configure \
		--prefix=$(targetprefix) \
		--with-driver=$(buildprefix)/driver \
		--with-target=$(TARGET)

.edvb: apps/Makefile
	make -C apps/edvb all install
	touch .edvb

#######################
#
#   internal
#

distclean-local:
	-rm Makefile-archive
	-rm .directories .linuxdir .binutils .glibc .gcc
	-rm .busybox
	-rm .libcurl .libfreetype .libncurses .libjpeg .libpng .libqt .libxml2 .libz
	-rm -rf $(targetprefix)
	-rm -rf $(hostprefix)
	-rm -f linux
	-rm -rf linux-$(KERNELVERSION)

include Makefile-archive

Makefile-archive: $(top_srcdir)/rules-archive
	$(top_srcdir)/rules-archive.pl $(top_srcdir)/rules-archive > Makefile-archive

$(ACLOCAL_M4): $(top_srcdir)/tuxbox.m4

EXTRA_DIST = rules-archive rules-archive.pl rules-make rules-make.pl tuxbox.m4
CONFIG_STATUS_DEPENDENCIES = rules-make

