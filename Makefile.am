PATH := $(hostprefix)/bin:$(PATH)

all: core libs root apps boot devel

#######################
#
#   core
#

bootstrap: .gcc

core: .gcc

.directories:
	install -d $(targetprefix)/bin
	install -d $(targetprefix)/dev
	install -d $(targetprefix)/etc
	install -d $(targetprefix)/include
	install -d $(targetprefix)/lib
	install -d $(targetprefix)/proc
	install -d $(targetprefix)/root
	install -d $(targetprefix)/sbin
	install -d $(targetprefix)/tmp
	install -d $(targetprefix)/var
	install -d $(targetprefix)$(UCODEDIR)
	install -d $(hostprefix)/$(target)
	install -d $(bootprefix)
	-rm $(hostprefix)/$(target)/include
	-rm $(hostprefix)/$(target)/lib
	ln -s $(targetprefix)/include $(hostprefix)/$(target)/include
	ln -s $(targetprefix)/lib $(hostprefix)/$(target)/lib
	install -d $(hostprefix)/$(target)/sys-include
	ln -s $(buildprefix)/linux-$(KERNELVERSION)/include/asm $(hostprefix)/$(target)/include
	ln -s $(buildprefix)/linux-$(KERNELVERSION)/include/linux $(hostprefix)/$(target)/include
	touch .directories

.linuxdir: .directories @DEPENDS_linux@
	@PREPARE_linux@
	cat Patches/linux-$(KERNELVERSION).dbox.config > linux-$(KERNELVERSION)/.config
	make -C linux-$(KERNELVERSION) oldconfig
	make -C linux-$(KERNELVERSION) include/linux/version.h
	touch .linuxdir

.binutils: .directories @DEPENDS_binutils@
	@PREPARE_binutils@
	cd @DIR_binutils@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_binutils@ \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--nfp && \
		make all install
	@CLEANUP_binutils@
	touch .binutils

#
# gcc first stage without glibc
#
bootstrap_gcc: .binutils .linuxdir @DEPENDS_bootstrap_gcc@
	@PREPARE_bootstrap_gcc@
	cp -pR $(buildprefix)/linux-$(KERNELVERSION)/include/asm $(hostprefix)/$(target)/sys-include/
	cd @DIR_bootstrap_gcc@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_bootstrap_gcc@ \
			--build=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--with-cpu=823 \
			--enable-target-optspace \
			--enable-languages="c" \
			--disable-shared \
			--disable-nls \
			--nfp && \
		make all install
	rm -rf $(hostprefix)/$(target)/sys-include/asm
	@CLEANUP_bootstrap_gcc@

.glibc: .binutils .linuxdir @DEPENDS_glibc@
	if [ ! -f $(hostprefix)/$(target)/lib/libc.so -a ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		make bootstrap_gcc; \
	fi
	@PREPARE_glibc@
	cd @DIR_glibc@ && \
		CC=$(target)-gcc AR=$(target)-ar RANLIB=$(target)-ranlib \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		@CONFIGURE_glibc@ \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-headers=$(buildprefix)/linux-$(KERNELVERSION)/include \
			--enable-kernel=$(KERNELVERSION) \
			--disable-profile \
			--enable-shared \
			--enable-add-ons=linuxthreads \
			--without-fp && \
		make all && \
		@INSTALL_glibc@
	@CLEANUP_glibc@
	touch .glibc

#
# gcc second stage with glibc
#
.gcc: .glibc @DEPENDS_gcc@
	@PREPARE_gcc@
	cp -p $(hostprefix)/$(target)/include/limits.h $(hostprefix)/$(target)/sys-include/
	cd @DIR_gcc@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_gcc@ \
			--build=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--with-cpu=823 \
			--enable-target-optspace \
			--enable-languages="c,c++" \
			--enable-shared \
			--enable-threads \
			--disable-nls \
			--nfp && \
		make all install
	rm -rf $(hostprefix)/$(target)/sys-include/limits.h
	@CLEANUP_gcc@
	touch .gcc

#######################
#
#   minimal root
#

root: .busybox .tinylogin .modutils .telnetd .msttf

.busybox: .gcc .etc @DEPENDS_busybox@
	@PREPARE_busybox@
	cd @DIR_busybox@ && \
		make CROSS=$(target)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
	touch .busybox

.tinylogin: .gcc .etc @DEPENDS_tinylogin@
	@PREPARE_tinylogin@
	cd @DIR_tinylogin@ && \
		make CROSS=$(target)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_tinylogin@
	@CLEANUP_tinylogin@
	touch .tinylogin
	
.modutils: .gcc .etc @DEPENDS_modutils@
	@PREPARE_modutils@
	cd @DIR_modutils@ && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		BUILDCC=$(CC) BUILDCFLAGS="-O2" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-root-check \
			--disable-strip && \
		make && \
		@INSTALL_modutils@
	@CLEANUP_modutils@
	touch .modutils

.etc:
	make -C etc install
	touch .etc

.inetd: .gcc .etc @DEPENDS_inetd@
	@PREPARE_inetd@
	touch @DIR_inetd@/MCONFIG
	cd @DIR_inetd@/inetd && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		make all && \
		install -m755 inetd $(targetprefix)/sbin
	@CLEANUP_inetd@
	touch .inetd

.telnetd: .gcc .inetd .libncurses @DEPENDS_telnetd@
	@PREPARE_telnetd@
	touch @DIR_telnetd@/MCONFIG
	cd @DIR_telnetd@/telnetd && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		LIBS=-lutil \
		make all && \
		install -m755 telnetd $(targetprefix)/sbin/in.telnetd
	@CLEANUP_telnetd@
	touch .telnetd

#######################
#
#   contrib libs
#

libs: .libcurl .libfreetype .libncurses .libjpeg .libpng .libqt .libxml2 .libz

.libcurl: .gcc @DEPENDS_libcurl@
	@PREPARE_libcurl@
	cd @DIR_libcurl@ && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-random=no \
			--with-ssl=no && \
		make all && \
		@INSTALL_libcurl@
	@CLEANUP_libcurl@
	touch .libcurl

.libffi: .gcc @DEPENDS_libffi@
	@PREPARE_libffi@
	cd @DIR_libffi@ && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
                ./configure \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		make all && \
		@INSTALL_libffi@
	@CLEANUP_libffi@
	touch .libffi
	
.libfreetype: .gcc @DEPENDS_libfreetype@
	@PREPARE_libfreetype@
	cd @DIR_libfreetype@ && \
		make \
			CC=$(target)-gcc CFLAGS="$(TARGET_CFLAGS)" \
			CFG="--host=${target} --prefix=${targetprefix}" && \
		make all && \
		@INSTALL_libfreetype@
	@CLEANUP_libfreetype@
	touch .libfreetype

.libncurses: .gcc @DEPENDS_libncurses@
	@PREPARE_libncurses@
	cd @DIR_libncurses@ && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		BUILD_CC=$(CC) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-big-core \
			--without-debug \
			--without-progs \
			--without-ada \
			--with-shared \
			--without-profile \
			--disable-rpath \
			--without-cxx-binding \
			--with-fallbacks='linux vt100 xterm' && \
		@INSTALL_libncurses@
	@CLEANUP_libncurses@
	touch .libncurses

.libjpeg: .gcc @DEPENDS_libjpeg@
	@PREPARE_libjpeg@
	cd @DIR_libjpeg@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		make libjpeg.so.6 && \
		@INSTALL_libjpeg@
	@CLEANUP_libjpeg@
	touch .libjpeg

.libpng: .gcc .libz @DEPENDS_libpng@
	@PREPARE_libpng@
	cd @DIR_libpng@ && \
		cp scripts/makefile.linux Makefile && \
		make all CC=$(target)-gcc CFLAGS="$(TARGET_CFLAGS) -DPNG_DEBUG=0" && \
		@INSTALL_libpng@
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
		make -C src/moc QTDIR=`pwd` && \
		@INSTALL_libqt@
	@CLEANUP_libqt@
	touch .libqt

.libxml2: .gcc @DEPENDS_libxml2@
	@PREPARE_libxml2@
	cd @DIR_libxml2@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--without-html-dir --with-threads --without-ftp --without-http --without-html \
			--without-catalog --without-docbook --without-xpath --without-xptr \
			--without-xinclude --without-iconv --without-debug --without-mem-debug && \
		make all && \
		@INSTALL_libxml2@
	@CLEANUP_libxml2@
	touch .libxml2

.libz: .gcc @DEPENDS_libz@
	@PREPARE_libz@
	cd @DIR_libz@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--prefix=$(targetprefix) \
			--shared && \
		make libz.so.1.1.3 && \
		@INSTALL_libz@
	@CLEANUP_libz@
	touch .libz

#######################
#
# msttf
#

.cabextract: .gcc @DEPENDS_cabextract@
	@PREPARE_cabextract@
	cd @DIR_cabextract@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		./configure \
			--prefix=$(hostprefix) && \
		make all && \
		@INSTALL_cabextract@
	@CLEANUP_cabextract@
	touch .cabextract

.msttf: .cabextract @DEPENDS_msttf@
	@PREPARE_msttf@
	install -d $(targetprefix)$(FONTDIR)
	install -m 0644 @DIR_msttf@/AriBlk.TTF $(targetprefix)$(FONTDIR)/Arial_Black.ttf
	install -m 0644 @DIR_msttf@/Arial.TTF $(targetprefix)$(FONTDIR)/Arial.ttf
	install -m 0644 @DIR_msttf@/Arialbd.TTF $(targetprefix)$(FONTDIR)/Arial_Bold.ttf
	install -m 0644 @DIR_msttf@/Arialbi.TTF $(targetprefix)$(FONTDIR)/Arial_Bold_Italic.ttf
	install -m 0644 @DIR_msttf@/Ariali.TTF $(targetprefix)$(FONTDIR)/Arial_Italic.ttf
	install -m 0644 @DIR_msttf@/cour.ttf $(targetprefix)$(FONTDIR)/Courier_New.ttf
	install -m 0644 @DIR_msttf@/courbd.ttf $(targetprefix)$(FONTDIR)/Courier_New_Bold.ttf
	install -m 0644 @DIR_msttf@/courbi.ttf $(targetprefix)$(FONTDIR)/Courier_New_Bold_Italic.ttf
	install -m 0644 @DIR_msttf@/couri.ttf $(targetprefix)$(FONTDIR)/Courier_New_Italic.ttf
	@CLEANUP_msttf@
	touch .msttf

#######################
#
#   development tools
#

devel: .gdb .strace

.gdb: .gcc .libncurses @DEPENDS_gdb@
	@PREPARE_gdb@
	cd @DIR_gdb@ && \
		LD_LIBRARY_PATH=$(libdir) \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--nfp \
			--disable-sim \
			--prefix=$(targetprefix) && \
		make all && \
		@INSTALL_gdb@
	@CLEANUP_gdb@
	touch .gdb

.strace: .gcc @DEPENDS_strace@
	@PREPARE_strace@
	cd @DIR_strace@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) && \
		make all && \
		@INSTALL_strace@
	@CLEANUP_strace@
	touch .strace

#######################
#
# misc apps
#

# for x86
.kaffeh: @DEPENDS_kaffeh@
	@PREPARE_kaffeh@
	cd @DIR_kaffeh@ && \
		./configure \
			--prefix=$(hostprefix) \
			--disable-dependency-tracking \
			--without-x \
			--without-suncompat \
			--disable-gcj && \
		make all && \
		@INSTALL_kaffeh@
	@CLEANUP_kaffeh@
	touch .kaffeh

# for ppc
.kaffe: .gcc .kaffeh .libffi @DEPENDS_kaffe@
	@PREPARE_kaffe@
	cd @DIR_kaffe@ && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--libexecdir=$(targetprefix)/bin \
			--enable-feedback \
			--with-stats \
			--disable-dependency-tracking \
			--without-x \
			--without-suncompat \
			--disable-gcj && \
		make all && \
		@INSTALL_kaffe@
	@CLEANUP_kaffe@
	touch .kaffe

.nano: @DEPENDS_nano@
	@PREPARE_nano@
	cd @DIR_nano@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--prefix=$(targetprefix) && \
		make all && \
		@INSTALL_nano@
	@CLEANUP_nano@
	touch .nano

#######################
#
#   own kernel and driver
#

boot: .ppcboot .linuxkernel .driver

.ppcboot: .gcc $(bootdir)/ppcboot/Makefile
	make -C $(bootdir)/ppcboot dbox_config
	make -C $(bootdir)/ppcboot CROSS_COMPILE=$(target)-
	install -m644 $(bootdir)/ppcboot/ppcboot $(bootprefix)
	install $(bootdir)/ppcboot/tools/mkimage $(hostprefix)/bin
	make -C $(bootdir)/ppcboot distclean
	touch .ppcboot

.linuxkernel: .linuxdir .gcc .ppcboot
	make -C @DIR_linux@ dep zImage modules CROSS_COMPILE=$(target)-
	make -C @DIR_linux@ modules_install INSTALL_MOD_PATH=$(targetprefix)
	test -f @DIR_linux@/arch/ppc/coffboot/vmlinux.gz || \
		$(hostprefix)/bin/mkimage \
			-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
			-a 00000000 -e 00000000 \
			-d @DIR_linux@/arch/ppc/coffboot/vmlinux.gz \
			$(bootprefix)/kernel-cdk
	test -f @DIR_linux@/arch/ppc/boot/images/vmlinux.gz || \
		$(hostprefix)/bin/mkimage \
			 -n 'dbox2' -A ppc -O linux -T kernel -C gzip \
			 -a 00000000 -e 00000000 \
			 -d @DIR_linux@/arch/ppc/boot/images/vmlinux.gz \
			 $(bootprefix)/kernel-cdk
	make -C @DIR_linux@ clean
	touch .linuxkernel

.driver: .gcc .linuxkernel
	install -d $(targetprefix)/bin
	install -d $(targetprefix)/lib/modules/$(KERNELVERSION)/misc
	make -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)-
	make -C $(driverdir) install \
		KERNEL_LOCATION=$(buildprefix)/linux \
		BIN_DEST=$(targetprefix)/bin \
		MODULE_DEST=$(targetprefix)/lib/modules/$(KERNELVERSION)/misc
	make -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
	touch .driver


#######################
#
#   own applications
#

apps: .dvbsnoop .dvbstream .edvb .lcars .lcdmenu .neutrino .stream 

if MAINTAINER_MODE
$(appsdir)/configure: $(appsdir)/configure.ac
	cd $(appsdir) && \
		./autogen.sh

$(appsdir)/Makefile: .libcurl .libfreetype .libqt .libxml2 $(appsdir)/configure $(appsdir)/Makefile.am
	cd $(appsdir) && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		./configure \
			--host=$(host) \
			--prefix=$(targetprefix) \
			--with-driver=$(driverdir) \
			--with-target=$(APPSTARGET) \
			--enable-maintainer-mode
else
$(appsdir)/Makefile: .libcurl .libfreetype .libqt .libxml2
	cd $(appsdir) && \
		if [ ! -f configure ] ; then ./autogen.sh ; fi && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		./configure \
			--host=$(host) \
			--prefix=$(targetprefix) \
			--with-driver=$(driverdir) \
			--with-target=$(APPSTARGET)
endif

.dvbsnoop: $(appsdir)/Makefile
	make -C $(appsdir)/dvbsnoop all install
	touch .dvbsnoop

.edvb: $(appsdir)/Makefile .fx2 .tools .msttf
	make -C $(appsdir)/edvb all install
	touch .edvb

.fx2: $(appsdir)/Makefile
	make -C $(appsdir)/fx2 all install
	touch .fx2

.lcars: $(appsdir)/Makefile .fx2
	make -C $(appsdir)/lcars all install
	touch .lcars

.lcdmenu: $(appsdir)/Makefile .liblcddisplay .msttf
	make -C $(appsdir)/lcdmenu all install
	touch .lcdmenu

.neutrino: $(appsdir)/Makefile .fx2 .liblcddisplay .libmd5sum .libnet .libucodes .msttf .sections .zapit
	make -C $(appsdir)/mczap all install
	touch .neutrino

.sections: $(appsdir)/Makefile
	make -C $(appsdir)/sections all install
	touch .sections

.stream: $(appsdir)/Makefile .inetd
	make -C $(appsdir)/stream all install
	touch .stream

.tools: $(appsdir)/Makefile
	make -C $(appsdir)/tools all install
	touch .tools

.zapit: $(appsdir)/Makefile
	make -C $(appsdir)/zapit all install
	touch .zapit

#######################
#
#  own libs
#

.liblcddisplay: $(appsdir)/Makefile
	make -C $(appsdir)/liblcddisplay all install
	touch .liblcddisplay

.libmd5sum:  $(appsdir)/Makefile
	make -C $(appsdir)/libmd5sum all install
	touch .libmd5sum

.libnet: $(appsdir)/Makefile
	make -C $(appsdir)/libnet all install
	touch .libnet

.libucodes: $(appsdir)/Makefile
	make -C $(appsdir)/libucodes all install
	touch .libucodes

#######################
#
#  3rd party apps
#

.dvbstream: $(appsdir)/Makefile
	make -C $(appsdir)/dvbstream all install
	touch .dvbstream


#######################
#
#   internal
#

clean-local:
	-make -C etc clean
	-make -C $(appsdir) clean
	-make -C $(bootdir)/ppcboot distclean
	-make -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
	-rm -f linux
	-rm -rf build
	-@CLEANUP@

distclean-local:
	-make -C etc distclean
	-make -C $(appsdir) distclean
	-rm Makefile-archive
	-rm .directories .linuxdir .binutils .glibc .gcc
	-rm .etc .busybox .tinylogin .modutils .inetd .telnetd 
	-rm .libcurl .libffi .libfreetype .libncurses .libjpeg .libpng .libqt .libxml2 .libz
	-rm .cabextract .msttf
	-rm .gdb .strace
	-rm .kaffeh .kaffe .nano
	-rm .ppcboot .linuxkernel
	-rm .dvbsnoop .edvb .lcars .lcdmenu .neutrino .stream
	-rm .fx2 .sections .zapit
	-rm .liblcddisplay .libmd5sum .libnet .libucodes
	-rm .dvbstream
	-rm .driver
	-rm -rf $(targetprefix)
	-rm -rf $(hostprefix)

@ARCHIVE@

if MAINTAINER_MODE
Makefile-archive: $(top_srcdir)/rules-archive
	$(top_srcdir)/rules-archive.pl $(top_srcdir)/rules-archive > Makefile-archive

$(ACLOCAL_M4): $(top_srcdir)/tuxbox.m4
endif

EXTRA_DIST = rules-archive rules-archive.pl rules-install rules-install.pl rules-make rules-make.pl tuxbox.m4

CONFIG_STATUS_DEPENDENCIES = $(top_srcdir)/rules-install $(top_srcdir)/rules-install.pl $(top_srcdir)/rules-make $(top_srcdir)/rules-make.pl Makefile-archive
