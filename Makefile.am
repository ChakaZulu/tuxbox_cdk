PATH := $(hostprefix)/bin:$(PATH)

all: core libs root apps boot devel java

#######################
#
#   core
#

core: .directories .binutils .linuxdir .glibc .gcc

.bootstrap:
	@if [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		make .gcc; \
	fi
	touch .bootstrap

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
	ln -s $(buildprefix)/linux/include/asm $(hostprefix)/$(target)/include
	ln -s $(buildprefix)/linux/include/linux $(hostprefix)/$(target)/include
	touch .directories

.linuxdir: @DEPENDS_linux@
	@if [ ! -d $(targetprefix)/bin ]; then \
		make .directories; \
	fi
	@PREPARE_linux@
	cat Patches/linux-$(KERNELVERSION).dbox.config > linux-$(KERNELVERSION)/.config
	make -C linux-$(KERNELVERSION) oldconfig
	make -C linux-$(KERNELVERSION) include/linux/version.h
	touch .linuxdir

.binutils: @DEPENDS_binutils@
	@if [ ! -d linux-$(KERNELVERSION) ]; then \
		make .linuxdir; \
	fi
	@PREPARE_binutils@
	cd @DIR_binutils@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_binutils@ \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--disable-nls \
			--nfp && \
		make all install
	@CLEANUP_binutils@
	touch .binutils

#
# gcc first stage without glibc
#
bootstrap_gcc: @DEPENDS_bootstrap_gcc@
	@if [ ! -d $(hostprefix)/$(target)/bin/as ]; then \
		make .binutils; \
	fi
	@PREPARE_bootstrap_gcc@
	cp -pR $(buildprefix)/linux-$(KERNELVERSION)/include/asm $(hostprefix)/$(target)/sys-include/
	cd @DIR_bootstrap_gcc@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_bootstrap_gcc@ \
			--build=$(build) \
			--host=$(build) \
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

.glibc: @DEPENDS_glibc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so -a ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		make bootstrap_gcc; \
	elif [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		make .gcc; \
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
.gcc: @DEPENDS_gcc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so ]; then \
		make .glibc; \
	fi
	@PREPARE_gcc@
	cp -p $(hostprefix)/$(target)/include/limits.h $(hostprefix)/$(target)/sys-include/
	cd @DIR_gcc@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_gcc@ \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--with-cpu=823 \
			--enable-target-optspace \
			--enable-languages="c,c++" \
			--enable-shared \
			--enable-threads \
			--disable-nls \
			--nfp && \
		make all && \
		@INSTALL_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include/limits.h
	@CLEANUP_gcc@
	touch .gcc

#######################
#
#   minimal root
#

root: .etc .busybox .tinylogin .modutils .inetd .ftpd .telnetd .top

.etc:
	make -C etc install
	touch .etc

.busybox: .bootstrap @DEPENDS_busybox@
	@PREPARE_busybox@
	cd @DIR_busybox@ && \
		make CROSS=$(target)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
	touch .busybox

.tinylogin: .bootstrap @DEPENDS_tinylogin@
	@PREPARE_tinylogin@
	cd @DIR_tinylogin@ && \
		make CROSS=$(target)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_tinylogin@
	@CLEANUP_tinylogin@
	touch .tinylogin
	
.modutils: .bootstrap @DEPENDS_modutils@
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

.inetd: .bootstrap @DEPENDS_inetd@
	@PREPARE_inetd@
	touch @DIR_inetd@/MCONFIG
	cd @DIR_inetd@/inetd && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		make all && \
		@INSTALL_inetd@
	@CLEANUP_inetd@
	touch .inetd

.ftpd: .bootstrap .inetd @DEPENDS_ftpd@
	@PREPARE_ftpd@
	cd @DIR_ftpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		make && \
		@INSTALL_ftpd@
	@CLEANUP_ftpd@
	touch .ftpd

.telnetd: .bootstrap .inetd .libncurses @DEPENDS_telnetd@
	@PREPARE_telnetd@
	touch @DIR_telnetd@/MCONFIG
	cd @DIR_telnetd@/telnetd && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		LIBS=-lutil \
		make all && \
		@INSTALL_telnetd@
	@CLEANUP_telnetd@
	touch .telnetd

.top: .bootstrap .libncurses @DEPENDS_top@
	@PREPARE_top@
	cd @DIR_top@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		make top && \
		@INSTALL_top@
	@CLEANUP_top@
	touch .top
		 
		
#######################
#
#   contrib libs
#

libs: .libcurl .libffi .libfreetype .libjpeg .libncurses .libpng .libqt .libz

.libcrypto: .bootstrap @DEPENDS_libcrypto@
	@PREPARE_libcrypto@
	cd @DIR_libcrypto@ && \
		./Configure shared no-idea no-md2 no-md4 no-mdc2 no-rc2 no-rc5 tuxbox --prefix=/ --openssldir=/ && \
		make all && \
		@INSTALL_libcrypto@
	@CLEANUP_libcrypto@
	touch .libcrypto

.libcurl: .bootstrap .libcrypto @DEPENDS_libcurl@
	@PREPARE_libcurl@
	cd @DIR_libcurl@ && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-random \
			--with-ssl && \
		make all && \
		@INSTALL_libcurl@
	@CLEANUP_libcurl@
	touch .libcurl

.libffi: .bootstrap @DEPENDS_libffi@
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
	
.libfreetype: .bootstrap @DEPENDS_libfreetype@
	@PREPARE_libfreetype@
	cd @DIR_libfreetype@ && \
		make \
			CC=$(target)-gcc CFLAGS="$(TARGET_CFLAGS)" \
			CFG="--host=${target} --prefix=${targetprefix}" && \
		make all && \
		@INSTALL_libfreetype@
	@CLEANUP_libfreetype@
	touch .libfreetype

.libncurses: .bootstrap @DEPENDS_libncurses@
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

.libjpeg: .bootstrap @DEPENDS_libjpeg@
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

.libpng: .bootstrap .libz @DEPENDS_libpng@
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
.libqt: .bootstrap .libfreetype .libjpeg .libpng .libz @DEPENDS_libqt@
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

.libreadline: .bootstrap @DEPENDS_libreadline@
	@PREPARE_libreadline@
	cd @DIR_libreadline@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		make shared && \
		@INSTALL_libreadline@
	@CLEANUP_libreadline@
	touch .libreadline

.libsdl: .bootstrap @DEPENDS_libsdl@
	@PREPARE_libsdl@
	cd @DIR_libsdl@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-alsa \
			--disable-openbsdaudio \
			--disable-esd \
			--disable-arts \
			--disable-nas \
			--disable-diskaudio \
			--disable-nasm \
			--disable-nanox \
			--disable-video-x11 \
			--without-x \
			--enable-video-fbcon \
			--disable-video-photon \
			--disable-video-directfb \
			--disable-video-ps2gs \
			--disable-video-ggi \
			--disable-video-svga \
			--disable-video-vgl \
			--disable-video-aalib \
			--disable-video-dummy \
			--disable-video-opengl \
			--disable-stdio-redirect \
			--disable-directx && \
		make all && \
		@INSTALL_libsdl@
	@CLEANUP_libsdl@
	touch .libsdl

.libxml2: .bootstrap @DEPENDS_libxml2@
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

.libz: .bootstrap @DEPENDS_libz@
	@PREPARE_libz@
	cd @DIR_libz@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--prefix=$(targetprefix) \
			--shared && \
		make libz.so.1.1.4 && \
		@INSTALL_libz@
	@CLEANUP_libz@
	touch .libz

#######################
#
#   contrib apps
#

.ssh: .bootstrap .libcrypto .libz @DEPENDS_ssh@
	@PREPARE_ssh@
	cd @DIR_ssh@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--sysconfdir=/etc/ssh \
			--without-shadow \
			--with-4in6 \
			--disable-suid-ssh \
			--with-path="/sbin:/bin" && \
		make && \
		@INSTALL_ssh@
	@CLEANUP_ssh@
	touch .ssh

#######################
#
# msttf
#

.cabextract: .bootstrap @DEPENDS_cabextract@
	@PREPARE_cabextract@
	cd @DIR_cabextract@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		./configure \
			--prefix=$(hostprefix) && \
		make all && \
		@INSTALL_cabextract@
	@CLEANUP_cabextract@
	touch .cabextract

.msttf: .bootstrap .cabextract @DEPENDS_msttf@
	@PREPARE_msttf@
	install -d $(targetprefix)$(FONTDIR)
	install -m 0644 @DIR_msttf@/AriBlk.TTF $(targetprefix)$(FONTDIR)/Arial_Black.ttf
	install -m 0644 @DIR_msttf@/Arial.TTF $(targetprefix)$(FONTDIR)/Arial.ttf
	install -m 0644 @DIR_msttf@/Arialbd.TTF $(targetprefix)$(FONTDIR)/Arial_Bold.ttf
	install -m 0644 @DIR_msttf@/Ariali.TTF $(targetprefix)$(FONTDIR)/Arial_Italic.ttf
	@CLEANUP_msttf@
	touch .msttf

#######################
#
#   development tools
#

devel: .gdb .strace .nano

.gdb: .bootstrap .libncurses @DEPENDS_gdb@
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

.strace: .bootstrap @DEPENDS_strace@
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

.nano: .bootstrap @DEPENDS_nano@
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
# java stuff
#

java: .kaffeh .kaffe

# for x86
.kaffeh: .bootstrap @DEPENDS_kaffeh@
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
.kaffe: .bootstrap .kaffeh .libffi @DEPENDS_kaffe@
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

#######################
#
#   fun stuff
#

.scummvm: .bootstrap .libreadline .libsdl @DEPENDS_scummvm@
	@PREPARE_scummvm@
	cd @DIR_scummvm@ && \
		make \
			CC=$(target)-g++ \
			CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TAGET_LDFLAGS)" \
			DEFINES="-DUNIX" && \
		@INSTALL_scummvm@
	@CLEANUP_scummvm@
	touch .scummvm

#######################
#
#   own kernel and driver
#

boot: .ppcboot .linuxkernel .driver

.ppcboot: .bootstrap $(bootdir)/ppcboot/Makefile
	make -C $(bootdir)/ppcboot dbox_config
	make -C $(bootdir)/ppcboot CROSS_COMPILE=$(target)-
	install -m644 $(bootdir)/ppcboot/ppcboot $(bootprefix)
	install $(bootdir)/ppcboot/tools/mkimage $(hostprefix)/bin
if MAINTAINER_MODE
else
	make -C $(bootdir)/ppcboot distclean
endif
	touch .ppcboot

.linuxkernel: .bootstrap .linuxdir
	@if [ ! -f $(hostprefix)/bin/mkimage ]; then \
		make .ppcboot; \
	fi
	make -C @DIR_linux@ dep zImage modules CROSS_COMPILE=$(target)-
	make -C @DIR_linux@ modules_install INSTALL_MOD_PATH=$(targetprefix)
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 \
		-d `if [ -f @DIR_linux@/arch/ppc/coffboot/vmlinux.gz ]; then echo @DIR_linux@/arch/ppc/coffboot/vmlinux.gz; else echo @DIR_linux@/arch/ppc/boot/images/vmlinux.gz; fi` \
		$(bootprefix)/kernel-cdk;
if MAINTAINER_MODE
else
	make -C @DIR_linux@ clean
endif
	touch .linuxkernel

.driver: .bootstrap .linuxkernel
	install -d $(targetprefix)/bin
	install -d $(targetprefix)/lib/modules/$(KERNELVERSION)/misc
	make -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)-
	make -C $(driverdir) install \
		KERNEL_LOCATION=$(buildprefix)/linux \
		BIN_DEST=$(targetprefix)/bin \
		MODULE_DEST=$(targetprefix)/lib/modules/$(KERNELVERSION)/misc
if MAINTAINER_MODE
else
	make -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
endif
	touch .driver

#######################
#
#   own applications
#

apps: .dvbsnoop .dvbstream .edvb .enigma .fx2 .lcars .lcdmenu .neutrino .stream .tuxtxt

if MAINTAINER_MODE
$(appsdir)/configure: $(appsdir)/configure.ac
	cd $(appsdir) && \
		./autogen.sh

$(appsdir)/Makefile: .bootstrap .libcurl .libfreetype .libqt $(appsdir)/configure $(appsdir)/Makefile.am
	cd $(appsdir) && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		./configure \
			--host=$(host) \
			--prefix=$(targetprefix) \
			--with-driver=$(driverdir) \
			--with-target=$(APPSTARGET) \
			--enable-maintainer-mode
else
$(appsdir)/Makefile: .bootstrap .libcurl .libfreetype .libqt
	cd $(appsdir) && \
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

.edvb: $(appsdir)/Makefile .tools .msttf
	make -C $(appsdir)/edvb all install
	touch .edvb

.enigma: $(appsdir)/Makefile .tools
	make -C $(appsdir)/enigma all install
	touch .enigma

.fx2: $(appsdir)/Makefile
	make -C $(appsdir)/fx2 all install
	touch .fx2

.lcars: $(appsdir)/Makefile
	make -C $(appsdir)/lcars all install
	touch .lcars

.lcdmenu: $(appsdir)/Makefile .liblcddisplay .msttf
	make -C $(appsdir)/lcdmenu all install
	touch .lcdmenu

.neutrino: $(appsdir)/Makefile .liblcddisplay .libmd5sum .libnet .libucodes .msttf .sections .zapit
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

.tuxtxt: $(appsdir)/Makefile
	make -C $(appsdir)/tuxtxt all install
	touch .tuxtxt

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
	-rm .bootstrap
	-rm .directories .linuxdir .binutils .glibc .gcc
	-rm .etc .busybox .tinylogin .modutils .inetd .ftpd .telnetd .top
	-rm .libcurl .libffi .libfreetype .libncurses .libjpeg .libpng .libqt .libreadline .libsdl .libxml2 .libz
	-rm .cabextract .msttf
	-rm .gdb .strace .nano
	-rm .kaffeh .kaffe
	-rm .scummvm
	-rm .ppcboot .linuxkernel .driver
	-rm .dvbsnoop .edvb .enigma .lcars .lcdmenu .neutrino .stream
	-rm .fx2 .sections .tools .tuxtxt .zapit
	-rm .liblcddisplay .libmd5sum .libnet .libucodes
	-rm .dvbstream
	-rm -rf $(targetprefix)
	-rm -rf $(hostprefix)

@ARCHIVE@

if MAINTAINER_MODE
Makefile-archive: $(top_srcdir)/rules-archive
	$(top_srcdir)/rules-archive.pl $(top_srcdir)/rules-archive > Makefile-archive

$(ACLOCAL_M4): $(top_srcdir)/tuxbox.m4
endif

.PHONY: core libs root apps boot devel java

EXTRA_DIST = \
	rules-archive rules-archive.pl \
	rules-install rules-install-flash rules-install.pl \
	rules-make rules-make-cygwin rules-make.pl \
	tuxbox.m4

CONFIG_STATUS_DEPENDENCIES = \
	$(top_srcdir)/rules-install $(top_srcdir)/rules-install-flash $(top_srcdir)/rules-install.pl \
	$(top_srcdir)/rules-make $(top_srcdir)/rules-make-cygwin $(top_srcdir)/rules-make.pl \
	Makefile-archive

