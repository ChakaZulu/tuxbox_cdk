TARGET = powerpc-tuxbox-linux-gnu

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
	install -d $(targetprefix)/usr
	install -d $(targetprefix)/var
	install -d $(targetprefix)/var/ucodes
	install -d $(hostprefix)/$(TARGET)
	install -d $(bootprefix)
	-rm $(hostprefix)/$(TARGET)/include
	-rm $(hostprefix)/$(TARGET)/lib
	ln -s $(targetprefix)/include $(hostprefix)/$(TARGET)/include
	ln -s $(targetprefix)/lib $(hostprefix)/$(TARGET)/lib
	install -d $(hostprefix)/$(TARGET)/sys-include
	ln -s $(buildprefix)/linux-$(KERNELVERSION)/include/asm $(hostprefix)/$(TARGET)/include
	ln -s $(buildprefix)/linux-$(KERNELVERSION)/include/linux $(hostprefix)/$(TARGET)/include
	touch .directories

.linuxdir: .directories @DEPENDS_linux@
	@PREPARE_linux@
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
	cd @DIR_bootstrap_gcc@ && \
		@CONFIGURE_bootstrap_gcc@ \
			--target=$(TARGET) \
			--prefix=$(hostprefix) \
			--with-cpu=823 \
			--enable-target-optspace \
			--enable-languages="c" \
			--disable-shared \
			--disable-nls \
			--nfp && \
		make all install
	rm -rf $(hostprefix)/$(TARGET)/sys-include/asm
	@CLEANUP_bootstrap_gcc@

.glibc: .binutils @DEPENDS_glibc@
	if [ ! -f $(hostprefix)/$(TARGET)/lib/libc.so -a ! -f $(hostprefix)/bin/$(TARGET)-gcc ]; then \
		make bootstrap_gcc; \
	fi
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
	cp -a $(hostprefix)/$(TARGET)/include/limits.h $(hostprefix)/$(TARGET)/sys-include/
	cd @DIR_gcc@ && \
		@CONFIGURE_gcc@ \
			--target=$(TARGET) \
			--prefix=$(hostprefix) \
			--with-cpu=823 \
			--enable-target-optspace \
			--enable-languages="c,c++" \
			--enable-shared \
			--enable-threads \
			--disable-nls \
			--nfp && \
		make all install
	rm -rf $(hostprefix)/$(TARGET)/sys-include/limits.h
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
		make CROSS=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
	touch .busybox

.tinylogin: .gcc .etc @DEPENDS_tinylogin@
	@PREPARE_tinylogin@
	cd @DIR_tinylogin@ && \
		make CROSS=$(TARGET)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_tinylogin@
	@CLEANUP_tinylogin@
	touch .tinylogin
	
.modutils: .gcc .etc @DEPENDS_modutils@
	@PREPARE_modutils@
	cd @DIR_modutils@ && \
		CC=$(TARGET)-gcc CXX=$(TARGET)-g++ CFLAGS="$(TARGET_CFLAGS)" \
		BUILDCC=gcc BUILDCFLAGS="-O2" \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=$(targetprefix) \
			--disable-root-check \
			--disable-strip && \
		make && \
		@INSTALL_modutils@
	@CLEANUP_modutils@
	touch .modutils

.etc:
	cp -Rf ./etc $(targetprefix)
	find $(targetprefix)/etc -type d -name "CVS" -exec rm -rf {} \; || /bin/true
	chmod 755 $(targetprefix)/etc/init.d/*
	touch .etc

.inetd: .gcc .etc @DEPENDS_inetd@
	@PREPARE_inetd@
	touch @DIR_inetd@/MCONFIG
	cd @DIR_inetd@/inetd && \
		CC=$(TARGET)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		make all && \
		install -m755 inetd $(targetprefix)/sbin
	@CLEANUP_inetd@
	touch .inetd

.telnetd: .gcc .inetd @DEPENDS_telnetd@
	@PREPARE_telnetd@
	touch @DIR_telnetd@/MCONFIG
	cd @DIR_telnetd@/telnetd && \
		CC=$(TARGET)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LIBS=-lutil \
		make all && \
		install -m755 telnetd $(targetprefix)/sbin/in.telnetd
	@CLEANUP_telnetd@
	touch .telnetd

.cabextract: .gcc @DEPENDS_cabextract@
	@PREPARE_cabextract@
	cd @DIR_cabextract@ && \
		./configure \
			--prefix=$(hostprefix) && \
		make all && \
		@INSTALL_cabextract@
	@CLEANUP_cabextract@
	touch .cabextract

.msttf: .cabextract @DEPENDS_msttf@
	@PREPARE_msttf@
	install -d $(FONTDIR)
	install -m 0644 @DIR_msttf@/AriBlk.TTF $(FONTDIR)/Arial_Black.ttf
	install -m 0644 @DIR_msttf@/Arial.TTF $(FONTDIR)/Arial.ttf
	install -m 0644 @DIR_msttf@/Arialbd.TTF $(FONTDIR)/Arial_Bold.ttf
	install -m 0644 @DIR_msttf@/Arialbi.TTF $(FONTDIR)/Arial_Bold_Italic.ttf
	install -m 0644 @DIR_msttf@/Ariali.TTF $(FONTDIR)/Arial_Italic.ttf
	install -m 0644 @DIR_msttf@/cour.ttf $(FONTDIR)/Courier_New.ttf
	install -m 0644 @DIR_msttf@/courbd.ttf $(FONTDIR)/Courier_New_Bold.ttf
	install -m 0644 @DIR_msttf@/courbi.ttf $(FONTDIR)/Courier_New_Bold_Italic.ttf
	install -m 0644 @DIR_msttf@/couri.ttf $(FONTDIR)/Courier_New_Italic.ttf
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
		./configure \
	                --build=`./config.guess` \
	                --host=$(TARGET) \
	                --target=$(TARGET) \
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
		CC=$(TARGET)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix=$(targetprefix) && \
		make all && \
		@INSTALL_strace@
	@CLEANUP_strace@
	touch .strace


#######################
#
#   contrib libs
#

libs: .libcurl .libfreetype .libncurses .libjpeg .libpng .libqt .libxml2 .libz

.libcurl: .gcc @DEPENDS_libcurl@
	@PREPARE_libcurl@
	cd @DIR_libcurl@ && \
		CC=$(TARGET)-gcc CXX=$(TARGET)-g++ CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--host=$(TARGET) \
			--prefix=$(targetprefix) \
			--with-random=no \
			--with-ssl=no && \
		make all && \
		@INSTALL_libcurl@
	@CLEANUP_libcurl@
	touch .libcurl
	
.libfreetype: .gcc @DEPENDS_libfreetype@
	@PREPARE_libfreetype@
	cd @DIR_libfreetype@ && \
		make \
			CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" \
			CFG="--host=${TARGET} --prefix=${targetprefix}" && \
		make all && \
		@INSTALL_libfreetype@
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
			--with-fallbacks='linux vt100 xterm' && \
		@INSTALL_libncurses@
	@CLEANUP_libncurses@
	touch .libncurses

.libjpeg: .gcc @DEPENDS_libjpeg@
	@PREPARE_libjpeg@
	cd @DIR_libjpeg@ && \
		CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--host=$(TARGET) \
			--prefix=$(targetprefix) && \
		make libjpeg.so.6 && \
		@INSTALL_libjpeg@
	@CLEANUP_libjpeg@
	touch .libjpeg

.libpng: .gcc .libz @DEPENDS_libpng@
	@PREPARE_libpng@
	cd @DIR_libpng@ && \
		cp scripts/makefile.linux Makefile && \
		make all CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS) -DPNG_DEBUG=0" && \
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
		CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--host=$(TARGET) \
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
		CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--prefix=$(targetprefix) \
			--shared && \
		make libz.so.1.1.3 && \
		@INSTALL_libz@
	@CLEANUP_libz@
	touch .libz

#######################
#
#   own kernel and driver
#

boot: .ppcboot .linuxkernel .driver

.ppcboot: .gcc $(bootdir)/ppcboot/Makefile
	make -C $(bootdir)/ppcboot dbox_config
	make -C $(bootdir)/ppcboot CROSS_COMPILE=$(TARGET)-
	install -m644 $(bootdir)/ppcboot/ppcboot $(bootprefix)
	install $(bootdir)/ppcboot/tools/mkimage $(hostprefix)/bin
	make -C $(bootdir)/ppcboot distclean
	touch .ppcboot

.linuxkernel: .linuxdir .gcc .ppcboot
	make -C @DIR_linux@ dep zImage modules CROSS_COMPILE=$(TARGET)-
	make -C @DIR_linux@ modules_install INSTALL_MOD_PATH=$(targetprefix)
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 \
		-d @DIR_linux@/arch/ppc/coffboot/vmlinux.gz \
		$(bootprefix)/kernel-cdk
	make -C @DIR_linux@ clean
	touch .linuxkernel

.driver: .gcc .linuxkernel
	install -d $(targetprefix)/bin
	install -d $(targetprefix)/lib/modules/$(KERNELVERSION)/misc
	make -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(TARGET)-
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

$(appsdir)/Makefile: .libcurl .libfreetype .libqt .libxml2
	cd $(appsdir) && \
		./autogen.sh && \
		CC=$(TARGET)-gcc CXX=$(TARGET)-g++ \
		./configure \
			--prefix=$(targetprefix) \
			--with-driver=$(driverdir) \
			--with-target=$(APPSTARGET)

.dvbsnoop: $(appsdir)/Makefile
	make -C $(appsdir)/dvbsnoop all install
	touch .dvbsnoop

.edvb: $(appsdir)/Makefile .fx2 .tools
	make -C $(appsdir)/edvb all install
	install -d $(targetprefix)/var/elitedvb
	touch .edvb

.fx2: $(appsdir)/Makefile
	make -C $(appsdir)/fx2 all install
	touch .fx2

.lcars: $(appsdir)/Makefile .fx2
	make -C $(appsdir)/lcars all install
	install -d $(targetprefix)/var/lcars
	touch .lcars

.lcdmenu: $(appsdir)/Makefile
	make -C $(appsdir)/lcdmenu all install
	touch .lcdmenu

.neutrino: $(appsdir)/Makefile .fx2 .sections .zapit
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
	install -d $(targetprefix)/var/zapit
	touch .zapit


############################
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

distclean-local:
	-rm Makefile-archive
	-rm .directories .linuxdir .binutils .glibc .gcc
	-rm .etc .busybox .tinylogin .modutils .inetd .telnetd .cabextract .msttf
	-rm .libcurl .libfreetype .libncurses .libjpeg .libpng .libqt .libxml2 .libz
	-rm .ppcboot .linuxkernel
	-rm .gdb .strace
	-rm .dvbsnoop .edvb .fx2 .lcars .lcdmenu
	-rm .neutrino .sections .stream .tools .zapit
	-rm -rf $(targetprefix)
	-rm -rf $(hostprefix)
	-make -C $(appsdir) distclean
	-make -C $(bootdir)/ppcboot distclean
	-make -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
	-rm -f linux
	-rm -rf linux-$(KERNELVERSION)

include Makefile-archive

Makefile-archive: $(top_srcdir)/rules-archive
	$(top_srcdir)/rules-archive.pl $(top_srcdir)/rules-archive > Makefile-archive

$(ACLOCAL_M4): $(top_srcdir)/tuxbox.m4

EXTRA_DIST = rules-archive rules-archive.pl rules-install rules-install.pl rules-make rules-make.pl tuxbox.m4
CONFIG_STATUS_DEPENDENCIES = rules-install rules-make
