PATH := $(hostprefix)/bin:$(PATH)

all: core libs root apps boot devel
extra: java contrib_apps fun dvb_apps

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
	$(INSTALL) -d $(targetprefix)/bin
	$(INSTALL) -d $(targetprefix)/dev
	$(INSTALL) -d $(targetprefix)/etc
	$(INSTALL) -d $(targetprefix)/include
	$(INSTALL) -d $(targetprefix)/lib
	$(INSTALL) -d $(targetprefix)/proc
	$(INSTALL) -d $(targetprefix)/root
	$(INSTALL) -d $(targetprefix)/sbin
	$(INSTALL) -d $(targetprefix)/tmp
	$(INSTALL) -d $(targetprefix)/var
	$(INSTALL) -d $(targetprefix)$(UCODEDIR)
	$(INSTALL) -d $(hostprefix)/$(target)
	$(INSTALL) -d $(bootprefix)
	-rm $(hostprefix)/$(target)/include
	-rm $(hostprefix)/$(target)/lib
	-ln -s $(targetprefix)/include $(hostprefix)/$(target)/include
	-ln -s $(targetprefix)/lib $(hostprefix)/$(target)/lib
	-ln -s $(buildprefix)/linux/include/asm $(hostprefix)/$(target)/include
	-ln -s $(buildprefix)/linux/include/linux $(hostprefix)/$(target)/include
if TARGETRULESET_FLASH
	$(INSTALL) -d $(flashprefix)
endif
	touch .directories

.linuxdir: @DEPENDS_linux@
	@if [ ! -d $(targetprefix)/bin ]; then \
		make .directories; \
	fi
	@PREPARE_linux@
	cat Patches/linux-$(KERNELVERSION).dbox.config > @DIR_linux@/.config
	make -C @DIR_linux@ oldconfig \
		ARCH=ppc
	make -C @DIR_linux@ include/linux/version.h \
		ARCH=ppc
	touch .linuxdir

.binutils: @DEPENDS_binutils@
	@if [ ! -h linux ]; then \
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
	$(INSTALL) -d $(hostprefix)/$(target)/sys-include
	ln -sf $(buildprefix)/@DIR_linux@/include/asm $(hostprefix)/$(target)/sys-include/
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
	rm -rf $(hostprefix)/$(target)/sys-include
	@CLEANUP_bootstrap_gcc@

#
# gcc first stage without glibc (2.95)
#
bootstrap_gcc_2_95: @DEPENDS_bootstrap_gcc_2_95@
	@if [ ! -d $(hostprefix)/$(target)/bin/as ]; then \
		make .binutils; \
	fi
	@PREPARE_bootstrap_gcc_2_95@
	$(INSTALL) -d $(hostprefix)/$(target)/sys-include
	ln -sf $(buildprefix)/@DIR_linux@/include/asm $(hostprefix)/$(target)/sys-include/
	cd @DIR_bootstrap_gcc_2_95@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_bootstrap_gcc_2_95@ \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--with-newlib \
			--with-cpu=823 \
			--enable-target-optspace \
			--enable-languages="c" \
			--disable-shared \
			--disable-nls \
			--nfp && \
		make all && \
		@INSTALL_bootstrap_gcc_2_95@
	rm -rf $(hostprefix)/$(target)/sys-include
	@CLEANUP_bootstrap_gcc_2_95@

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
			--with-headers=$(buildprefix)/@DIR_linux@/include \
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
# uClibc
# a minimalistic libc, won't currently work with libstdc++
#
.uclibc: @DEPENDS_uclibc@
	@PREPARE_uclibc@
	cd @DIR_uclibc@ && \
		make all CROSS=$(target)- && \
		@INSTALL_uclibc@
	@CLEANUP_uclibc@
	touch .uclibc

#
# gcc second stage with glibc
#
.gcc: @DEPENDS_gcc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so ]; then \
		make .glibc; \
	fi
	@PREPARE_gcc@
	$(INSTALL) -d $(hostprefix)/$(target)/sys-include
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
	rm -rf $(hostprefix)/$(target)/sys-include
	@CLEANUP_gcc@
	touch .gcc

#######################
#
#   root
#

root: .etc .busybox .ftpd .ifupdown .inetd .modutils .netkit_telnet .procps .tinylogin

.etc:
	make -C etc install
	touch .etc

.busybox: .bootstrap .etc @DEPENDS_busybox@
	@PREPARE_busybox@
	cd @DIR_busybox@ && \
		make CROSS=$(target)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
	touch .busybox

.tinylogin: .bootstrap .busybox @DEPENDS_tinylogin@
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

.ifupdown: .bootstrap @DEPENDS_ifupdown@
	@PREPARE_ifupdown@
	cd @DIR_ifupdown@ && \
		make all \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" && \
		@INSTALL_ifupdown@
	@CLEANUP_ifupdown@
	touch .ifupdown

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

.netkit_telnet: .bootstrap .inetd .tinylogin .libncurses @DEPENDS_netkit_telnet@
	@PREPARE_netkit_telnet@
	touch @DIR_netkit_telnet@/MCONFIG
	cd @DIR_netkit_telnet@ && \
		CXX=$(target)-g++ \
		CXXFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		LIBS="-lncurses" \
		make -C telnet && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		LIBS="-lutil" \
		make -C telnetd && \
		@INSTALL_netkit_telnet@
	@CLEANUP_netkit_telnet@
	touch .netkit_telnet

.procps: .bootstrap .libncurses @DEPENDS_procps@
	@PREPARE_procps@
	cd @DIR_procps@ && \
		patch -p1 < ../Patches/procps-010114.diff && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		make top ps && \
		@INSTALL_procps@
	@CLEANUP_procps@
	touch .procps


#######################
#
#   contrib libs
#

libs: \
	.libcrypto .libcurl .libffi .libfreetype .libjpeg .libncurses \
	.libpng .libreadline .libsdl .libsigc .libz

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

.libpcap: .bootstrap @DEPENDS_libpcap@
	@PREPARE_libpcap@
	cd @DIR_libpcap@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-pcap=linux \
			--build=$(build) && \
		make && \
		@INSTALL_libpcap@
	@CLEANUP_libpcap@
	touch .libpcap

.libpng: .bootstrap .libz @DEPENDS_libpng@
	@PREPARE_libpng@
	cd @DIR_libpng@ && \
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

.libsigc: .bootstrap @DEPENDS_libsigc@
	@PREPARE_libsigc@
	cd @DIR_libsigc@ && \
		libtoolize --automake --force && aclocal && autoconf && automake --add-missing && \
		CC=$(target)-gcc \
		CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-checks && \
		make all && \
		@INSTALL_libsigc@
	@CLEANUP_libsigc@
	touch .libsigc

.libxml2: .bootstrap @DEPENDS_libxml2@
	@PREPARE_libxml2@
	cd @DIR_libxml2@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--without-html-dir --with-threads --without-ftp --without-http --without-html \
			--without-catalog --without-docbook --with-xpath --without-xptr \
			--without-xinclude --without-iconv --without-debug --without-mem-debug \
			--without-python && \
		make all && \
		@INSTALL_libxml2@
	@CLEANUP_libxml2@
	touch .libxml2

.libxmlwrapp: .bootstrap .libxml2 @DEPENDS_libxmlwrapp@
	@PREPARE_libxmlwrapp@
	cd @DIR_libxmlwrapp@ && \
		CXX=$(target)-g++ \
		CXXFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure.pl \
			--disable-examples \
			--prefix $(targetprefix) && \
		make all && \
		@INSTALL_libxmlwrapp@
	@CLEANUP_libxmlwrapp@
	touch .libxmlwrapp

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

contrib_apps: .console_data .console_tools .fbset .lirc .ssh .tcpdump .xrc

.console_data: .bootstrap @DEPENDS_console_data@
	@PREPARE_console_data@
	cd @DIR_console_data@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-main_compressor=gzip && \
		@INSTALL_console_data@
	@CLEANUP_console_data@
	touch .console_data

.console_tools: .bootstrap @DEPENDS_console_tools@
	@PREPARE_console_tools@
	cd @DIR_console_tools@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		@INSTALL_console_tools@
	@CLEANUP_console_tools@
	touch .console_tools

.fbset: .bootstrap @DEPENDS_fbset@
	@PREPARE_fbset@
	cd @DIR_fbset@ && \
		make \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)" && \
		@INSTALL_fbset@
	@CLEANUP_fbset@
	touch .fbset

.lirc: .bootstrap @DEPENDS_lirc@
	@PREPARE_lirc@
	cd @DIR_lirc@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		mknod=/bin/true \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-devdir=/dev \
			--with-driver=serial \
			--with-kerneldir=$(buildprefix)/linux-$(KERNELVERSION) \
			--with-moduledir=$(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
			--without-x && \
		@INSTALL_lirc@
	@CLEANUP_lirc@
	touch .lirc

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
			--with-path="/bin:/sbin" \
			--with-privsep-user=sshd \
			--with-privsep-path=/share/empty && \
		make && \
		@INSTALL_ssh@
	@CLEANUP_ssh@
	touch .ssh

.tcpdump: .bootstrap .libpcap @DEPENDS_tcpdump@
	@PREPARE_tcpdump@
	cd @DIR_tcpdump@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS) -I$(targetprefix)/include -L$(targetprefix)/lib" LDFLAGS="$(TARGET_LDFLAGS) -L$(targetprefix)/lib"  \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--libdir=$(targetprefix)/lib \
			--build=$(build) && \
		make && \
		@INSTALL_tcpdump@
	@CLEANUP_tcpdump@
	touch .tcpdump

.xrc: .bootstrap .lirc @DEPENDS_xrc@
	@PREPARE_xrc@
	cd @DIR_xrc@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-qpe \
			--disable-qt-embedded \
			--without-x && \
		@INSTALL_xrc@
	@CLEANUP_xrc@
	touch .xrc

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
	$(INSTALL) -d $(targetprefix)$(FONTDIR)
	$(INSTALL) -m 0644 @DIR_msttf@/AriBlk.TTF $(targetprefix)$(FONTDIR)/Arial_Black.ttf
	$(INSTALL) -m 0644 @DIR_msttf@/Arial.TTF $(targetprefix)$(FONTDIR)/Arial.ttf
	$(INSTALL) -m 0644 @DIR_msttf@/Arialbd.TTF $(targetprefix)$(FONTDIR)/Arial_Bold.ttf
	$(INSTALL) -m 0644 @DIR_msttf@/Ariali.TTF $(targetprefix)$(FONTDIR)/Arial_Italic.ttf
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

.ltrace: .bootstrap @DEPENDS_ltrace@
	@PREPARE_ltrace@
	cd @DIR_ltrace@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix= && \
		make clean all LD=$(target)-ld && \
		@INSTALL_ltrace@
	@CLEANUP_ltrace@
	touch .ltrace

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

fun: .mad .scummvm

.mad: .bootstrap .libz @DEPENDS_mad@
	@PREPARE_mad@
	cd @DIR_mad@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls \
			--without-esd \
			--enable-speed \
			--enable-fpm=ppc \
			--enable-sso && \
		make all && \
		@INSTALL_mad@
	@CLEANUP_mad@
	touch .mad

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
#  DVB apps
#

dvb_apps: .dvbstream .dvbtext .dvbtune

.dvbstream: @DEPENDS_dvbstream@
	@PREPARE_dvbstream@
	cd @DIR_dvbstream@ && \
		make dvbstream \
			INCS="-I$(driverdir)/include" \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" && \
		@INSTALL_dvbstream@
	@CLEANUP_dvbstream@
	touch .dvbstream

.dvbtext: @DEPENDS_dvbtext@
	@PREPARE_dvbtext@
	cd @DIR_dvbtext@ && \
		$(target)-gcc $(TARGET_CFLAGS) -I$(driverdir)/include -o dvbtext dvbtext.c && \
		@INSTALL_dvbtext@
	@CLEANUP_dvbtext@
	touch .dvbtext

.dvbtune: @DEPENDS_dvbtune@
	@PREPARE_dvbtune@
	cd @DIR_dvbtune@ && \
		make \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -I$(driverdir)/include" && \
		@INSTALL_dvbtune@
	@CLEANUP_dvbtune@
	touch .dvbtune

#######################
#
#   own kernel and driver
#

boot: .ppcboot .linuxkernel .driver

KERNELGCC = `if [ -f $(hostprefix)/bin/$(target)-gcc-2.95 ]; then echo $(target)-gcc-2.95; else echo $(target)-gcc; fi`

.ppcboot: .bootstrap $(bootdir)/ppcboot/Makefile
if HOSTRULESET_CYGWIN
	make -C $(bootdir)/ppcboot dbox_config CYGWIN=1
	make -C $(bootdir)/ppcboot CROSS_COMPILE=$(target)- CYGWIN=1
	$(INSTALL) Patches/cygwin/mkimage.exe $(hostprefix)/bin
else
	make -C $(bootdir)/ppcboot dbox_config
	make -C $(bootdir)/ppcboot CROSS_COMPILE=$(target)- CC=$(KERNELGCC)
	$(INSTALL) $(bootdir)/ppcboot/tools/mkimage $(hostprefix)/bin
endif
	$(INSTALL) -m644 $(bootdir)/ppcboot/ppcboot $(bootprefix)
if MAINTAINER_MODE
else
	make -C $(bootdir)/ppcboot distclean
endif
	touch .ppcboot

.linuxkernel: .bootstrap .linuxdir
	@if [ ! -f $(hostprefix)/bin/mkimage ]; then \
		make .ppcboot; \
	fi
	make -C @DIR_linux@ zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- CC=$(KERNELGCC)
	make -C @DIR_linux@ modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
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
	$(INSTALL) -d $(targetprefix)/bin
	$(INSTALL) -d $(targetprefix)/lib/modules/$(KERNELVERSION)/misc
	make -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)- CC=$(KERNELGCC) \
		INSTALL_MOD_PATH=$(targetprefix)
	make -C $(driverdir) install \
		KERNEL_LOCATION=$(buildprefix)/linux \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix)
if MAINTAINER_MODE
else
	make -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
endif
	touch .driver

driver-clean:
	make -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
	rm .driver

#######################
#
#   own applications
#

apps: .dvbsnoop .edvb .enigma .fx2 .lcars .lcdmenu .neutrino .stream .tuxtxt

if MAINTAINER_MODE
$(appsdir)/configure: $(appsdir)/configure.ac
	cd $(appsdir) && \
		./autogen.sh

$(appsdir)/Makefile: .bootstrap .libcurl .libfreetype .libpng .libsigc $(appsdir)/configure $(appsdir)/Makefile.am
	cd $(appsdir) && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		./configure \
			--host=$(host) \
			--prefix=$(targetprefix) \
			--with-driver=$(driverdir) \
			--with-target=$(APPSTARGET) \
			--enable-maintainer-mode
else
$(appsdir)/Makefile: .bootstrap .libcurl .libfreetype .libpng .libsigc
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

.neutrino: $(appsdir)/Makefile .libcramfs .libconfigfile .liblcddisplay .libmd5sum .libnet .libucodes .msttf .sections .zapit
	make -C $(appsdir)/mczap all install
	touch .neutrino

.sections: $(appsdir)/Makefile
	make -C $(appsdir)/sections all install
	touch .sections

.stream: $(appsdir)/Makefile .inetd .libmpegtools
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

.libconfigfile: $(appsdir)/Makefile
	make -C $(appsdir)/libconfigfile all install
	touch .libconfigfile

.libcramfs: $(appsdir)/Makefile
	make -C $(appsdir)/libcramfs all install
	touch .libcramfs

.liblcddisplay: $(appsdir)/Makefile
	make -C $(appsdir)/liblcddisplay all install
	touch .liblcddisplay

.libmd5sum: $(appsdir)/Makefile
	make -C $(appsdir)/libmd5sum all install
	touch .libmd5sum

.libmpegtools: $(appsdir)/Makefile
	make -C $(appsdir)/libmpegtools all install
if TARGETRULESET_FLASH
	$(target)-ar cru $(targetprefix)/lib/libmpegtools_pic.a $(appsdir)/libmpegtools/*.o
endif
	touch .libmpegtools

.libnet: $(appsdir)/Makefile
	make -C $(appsdir)/libnet all install
	touch .libnet

.libucodes: $(appsdir)/Makefile
	make -C $(appsdir)/libucodes all install
	touch .libucodes

#######################
#
#   flash
#

if TARGETRULESET_FLASH
rebuild-flash:
	-rm $(flashprefix)/.flash
	make flash-lib

$(flashprefix)/.flash: .busybox .driver .modutils
	-rm -rf $(flashprefix)/root
	$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) -d $(flashprefix)/root/dev
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox
	$(INSTALL) -d $(flashprefix)/root/mnt
	$(INSTALL) -d $(flashprefix)/root/proc
	$(INSTALL) -d $(flashprefix)/root/sbin
	$(INSTALL) -d $(flashprefix)/root/share/tuxbox/image
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/ucodes
	$(INSTALL) -d $(flashprefix)/root/tmp
	make -C etc install targetprefix=$(flashprefix)/root

	$(INSTALL) $(targetprefix)/bin/busybox $(flashprefix)/root/bin
	for i in `find $(targetprefix)/bin/ -lname "*busybox"` ; do cp -a $$i $(flashprefix)/root/bin/ ; done
	for i in `find $(targetprefix)/sbin/ -lname "*busybox"` ; do cp -a $$i $(flashprefix)/root/sbin/ ; done

	$(INSTALL) $(targetprefix)/sbin/insmod $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/depmod $(flashprefix)/root/sbin
	for i in `find $(targetprefix)/sbin/ -lname "*insmod"` ; do cp -a $$i $(flashprefix)/root/sbin/ ; done

	$(INSTALL) -d $(flashprefix)/root/lib/modules/$(KERNELVERSION)
	cp -a $(targetprefix)/lib/modules/$(KERNELVERSION)/kernel $(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
		$(flashprefix)/root/lib/modules/$(KERNELVERSION)
	cp -a $(bootprefix)/kernel-cdk $(flashprefix)/root/vmlinuz
	@touch $(flashprefix)/.flash

flash-ftpd: $(flashprefix)/.part_ftpd

$(flashprefix)/.part_ftpd: $(flashprefix)/.flash $(flashprefix)/.prog_inetd .ftpd
	$(INSTALL) -m644 $(targetprefix)/etc/vsftpd.conf $(flashprefix)/root/etc
	$(INSTALL) $(targetprefix)/sbin/in.ftpd $(flashprefix)/root/sbin
	$(INSTALL) -d $(flashprefix)/root/share/empty
	@touch $(flashprefix)/.part_ftpd

$(flashprefix)/.part_inetd: $(flashprefix)/.flash .inetd
	$(INSTALL) $(targetprefix)/sbin/inetd $(flashprefix)/root/sbin
	@touch $(flashprefix)/.part_inetd

flash-telnetd: $(flashprefix)/.part_telnetd

$(flashprefix)/.part_telnetd: $(flashprefix)/.flash $(flashprefix)/.part_inetd $(flashprefix)/.part_tinylogin .netkit_telnet
	$(INSTALL) $(targetprefix)/sbin/in.telnetd $(flashprefix)/root/sbin
	@touch $(flashprefix)/.part_telnetd

$(flashprefix)/.part_tinylogin: $(flashprefix)/.flash .tinylogin
	$(INSTALL) $(targetprefix)/bin/tinylogin $(flashprefix)/root/bin
	for i in `find $(targetprefix)/sbin/ -lname "*tinylogin"` ; do cp -a $$i $(flashprefix)/root/bin/ ; done
	@touch $(flashprefix)/.part_tinylogin

flash-ssh: $(flashprefix)/.part_ssh

$(flashprefix)/.part_ssh: $(flashprefix)/.flash .ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	cp -a $(targetprefix)/etc/ssh/ssh_config $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh $(flashprefix)/root/bin
	@touch $(flashprefix)/.part_ssh

flash-sshd: $(flashprefix)/.part_sshd

$(flashprefix)/.part_sshd: $(flashprefix)/.flash .ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	cp -a $(targetprefix)/etc/ssh/* $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh-keygen $(flashprefix)/root/bin
	$(INSTALL) -d $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/libexec/sftp-server $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/sbin/sshd $(flashprefix)/root/sbin
	$(INSTALL) -d $(flashprefix)/root/share/empty
	@touch $(flashprefix)/.part_sshd

flash-neutrino: $(flashprefix)/.part_neutrino

$(flashprefix)/.part_neutrino: $(flashprefix)/.flash $(flashprefix)/.part_msttf .neutrino
	$(INSTALL) $(targetprefix)/bin/controld $(targetprefix)/bin/lcdd $(targetprefix)/bin/neutrino \
		$(targetprefix)/bin/nhttpd $(targetprefix)/bin/timerd \
		$(flashprefix)/root/bin
	cp -a $(targetprefix)/share/tuxbox/neutrino $(targetprefix)/share/tuxbox/lcdd \
		$(flashprefix)/root/share/tuxbox

	$(INSTALL) $(targetprefix)/bin/sectionsd $(flashprefix)/root/bin

	$(INSTALL) $(targetprefix)/bin/zapit $(flashprefix)/root/bin
	cp -a $(targetprefix)/var/tuxbox/config/zapit $(flashprefix)/root/var/tuxbox/config

	$(INSTALL) -d $(flashprefix)/root/share/fonts
	cp -a $(targetprefix)/share/fonts/micron*.ttf $(flashprefix)/root/share/fonts

	cp -a $(targetprefix)/var/tuxbox/config/*.xml $(flashprefix)/root/var/tuxbox/config
	@touch $(flashprefix)/.part_neutrino

$(flashprefix)/.part_msttf: $(flashprefix)/.flash .msttf
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	cp -a $(targetprefix)/share/fonts/Arial*.ttf $(flashprefix)/root/share/fonts
	@touch $(flashprefix)/.part_msttf

flash-enigma: $(flashprefix)/.part_enigma

$(flashprefix)/.part_enigma: $(flashprefix)/.flash .enigma
	$(INSTALL) $(targetprefix)/bin/enigma $(flashprefix)/root/bin
	cp -a $(targetprefix)/share/tuxbox/enigma $(flashprefix)/root/share/tuxbox
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	cp -a $(targetprefix)/share/fonts/Marlett.ttf $(targetprefix)/share/fonts/unmrs.pfa \
		$(flashprefix)/root/share/fonts
	@touch $(flashprefix)/.part_enigma

flash-lcars: $(flashprefix)/.part_lcars

$(flashprefix)/.part_lcars: $(flashprefix)/.flash .lcars
	$(INSTALL) $(targetprefix)/bin/lcars $(flashprefix)/root/bin
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	cp -a $(targetprefix)/share/fonts/ds9.ttf $(flashprefix)/root/share/fonts
	cp -a $(targetprefix)/var/tuxbox/config/lcars $(flashprefix)/root/var/tuxbox/config
	@touch $(flashprefix)/.part_lcars

flash-fx2: $(flashprefix)/.part_fx2

$(flashprefix)/.part_fx2: $(flashprefix)/.flash .fx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	cp -a $(targetprefix)/lib/tuxbox/plugins/* $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -m644 $(targetprefix)/var/tuxbox/config/games.cfg $(flashprefix)/root/var/tuxbox/config
	@touch $(flashprefix)/.part_fx2

flash-lib: $(flashprefix)/.lib

$(flashprefix)/.lib: $(flashprefix)/.flash $(shell ls -1 $(flashprefix)/.part_*)
	@find $(flashprefix)/root/lib -maxdepth 1 -type f -o -type l | xargs rm -f
	@cp -a $(targetprefix)/lib/libnss_dns-?.*.so $(flashprefix)/root/lib
	@cp -a $(targetprefix)/lib/libnss_files-?.*.so $(flashprefix)/root/lib
	@$(PYTHON) mklibs.py --target $(target) --ldlib ld.so.1 --libc-extras-dir $(targetprefix)/lib/libc_pic \
		-d $(flashprefix)/root/lib \
		-L $(targetprefix)/lib \
		`find $(flashprefix)/root/bin/ -path "*bin/?*"` \
		`find $(flashprefix)/root/lib/ -name "libnss_*"` \
		`find $(flashprefix)/root/lib/tuxbox/ -name "*.so" -type f` \
		`find $(flashprefix)/root/sbin/ -path "*sbin/?*"`
	@for i in `find $(flashprefix)/root/lib/ -name ld*.so -o -name lib*.so.?.* -o -name lib*-?.*.so` ; do \
		ln -sf `basename $$i` $(flashprefix)/root/lib/`objdump -x $$i 2>/dev/null | grep SONAME | awk '{print $$2}'` ; \
	done
	@strip --remove-section=.comment --remove-section=.note `find $(flashprefix)/root/bin/ -path "*bin/?*"` 2>/dev/null || /bin/true
	@strip --remove-section=.comment --remove-section=.note --strip-unneeded `find $(flashprefix)/root/lib/tuxbox -name "*.so"` 2>/dev/null || /bin/true
	@chmod u+rwX,go+rX-w -R $(flashprefix)/root/
	@touch $(flashprefix)/.lib

flash-compress: $(flashprefix)/root-cramfs.img $(flashprefix)/var-jffs2.img

flash-compress-complete-jffs2: $(flashprefix)/root-jffs2.img

$(flashprefix)/root-cramfs.img: $(flashprefix)/.lib
	@cp -a $(flashprefix)/root $(flashprefix)/temp
	@$(INSTALL) -d $(flashprefix)/temp/var/etc
	@mv $(flashprefix)/temp/etc/ssh $(flashprefix)/temp/var/etc/ssh
	@ln -sf /var/etc/ssh $(flashprefix)/temp/etc/ssh
	@mv $(flashprefix)/temp/var $(flashprefix)/temp/share/tuxbox/image
	@$(INSTALL) -d $(flashprefix)/temp/var
	@$(FAKEROOT) $(MKCRAMFS) -n "TuxBox-`date +%Y%m%d`" $(flashprefix)/temp/ $(flashprefix)/root-cramfs.img
	@rm -rf $(flashprefix)/temp/

$(flashprefix)/var-jffs2.img: $(flashprefix)/.lib
	@cp -a $(flashprefix)/root/var $(flashprefix)/temp
	@$(FAKEROOT) $(MKJFFS2) -b -e 131072 -o $(flashprefix)/var-jffs2.img -r $(flashprefix)/temp/
	@rm -rf $(flashprefix)/temp/

$(flashprefix)/root-jffs2.img: $(flashprefix)/.lib
	@$(FAKEROOT) $(MKJFFS2) -b -e 131072 -o $(flashprefix)/root-jffs2.img -r $(flashprefix)/root/
endif

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
	-rm .etc .busybox .ftpd .ifupdown .inetd .modutils .netkit_telnet .procps .tinylogin
	-rm .libcrypto .libcurl .libffi .libfreetype .libncurses .libjpeg
	-rm .libpcap .libpng .libqt .libreadline .libsdl .libsigc .libxml2 .libxmlwrapp .libz
	-rm .cabextract .msttf
	-rm .gdb .ltrace .strace .nano
	-rm .kaffeh .kaffe
	-rm .mad .scummvm
	-rm .ppcboot .linuxkernel .driver
	-rm .dvbsnoop .edvb .enigma .lcars .lcdmenu .neutrino .stream
	-rm .fx2 .sections .tools .tuxtxt .zapit
	-rm .libconfigfile .libcramfs
	-rm .liblcddisplay .libmd5sum .libmpegtools .libnet .libucodes
	-rm .console_data .console_tools .fbset .lirc .ssh .tcpdump .xrc
	-rm .dvbstream .dvbtext .dvbtune
	-rm -rf $(targetprefix)
	-rm -rf $(hostprefix)
if TARGETRULESET_FLASH
	-rm -rf $(flashprefix)
endif

@ARCHIVE@

if MAINTAINER_MODE
Makefile-archive: $(top_srcdir)/rules-archive
	$(top_srcdir)/rules-archive.pl $(top_srcdir)/rules-archive > Makefile-archive

$(ACLOCAL_M4): $(top_srcdir)/tuxbox.m4
endif

if TARGETRULESET_FLASH
.PHONY: core libs root apps boot devel java copy lib compress
else
.PHONY: core libs root apps boot devel java
endif

EXTRA_DIST = \
	rules-archive rules-archive.pl \
	rules-install rules-install-flash rules-install.pl \
	rules-make rules-make-cygwin rules-make.pl \
	tuxbox.m4

CONFIG_STATUS_DEPENDENCIES = \
	$(top_srcdir)/rules-install $(top_srcdir)/rules-install-flash $(top_srcdir)/rules-install.pl \
	$(top_srcdir)/rules-make $(top_srcdir)/rules-make-cygwin $(top_srcdir)/rules-make.pl \
	Makefile-archive

