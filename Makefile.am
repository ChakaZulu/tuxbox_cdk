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
		$(MAKE) .gcc; \
	fi
	touch .bootstrap

.directories:
	$(INSTALL) -d $(targetprefix)/bin
	$(INSTALL) -d $(targetprefix)/dev
	$(INSTALL) -d $(targetprefix)/etc
	$(INSTALL) -d $(targetprefix)/include
	$(INSTALL) -d $(targetprefix)/mnt
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
		$(MAKE) .directories; \
	fi
	@PREPARE_linux@
	cat Patches/linux-dbox2-$(KERNELVERSION).config > @DIR_linux@/.config
	$(MAKE) -C @DIR_linux@ oldconfig \
		ARCH=ppc
	$(MAKE) -C @DIR_linux@ include/linux/version.h \
		ARCH=ppc
	touch .linuxdir

.binutils: @DEPENDS_binutils@
	@if [ ! -h linux ]; then \
		$(MAKE) .linuxdir; \
	fi
	@PREPARE_binutils@
	cd @DIR_binutils@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_binutils@ \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--disable-nls \
			--nfp && \
		$(MAKE) all all-gprof && \
		@INSTALL_binutils@
	@CLEANUP_binutils@
	touch .binutils

#
# gcc first stage without glibc
#
bootstrap_gcc: @DEPENDS_bootstrap_gcc@
	@if [ ! -d $(hostprefix)/$(target)/bin/as ]; then \
		$(MAKE) .binutils; \
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
			--disable-threads \
			--nfp && \
		$(MAKE) all && \
		@INSTALL_bootstrap_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include
	@CLEANUP_bootstrap_gcc@

#
# gcc first stage without glibc (2.95)
#
bootstrap_gcc_2_95: @DEPENDS_bootstrap_gcc_2_95@
	@if [ ! -d $(hostprefix)/$(target)/bin/as ]; then \
		$(MAKE) .binutils; \
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
		$(MAKE) all && \
		@INSTALL_bootstrap_gcc_2_95@
	rm -rf $(hostprefix)/$(target)/sys-include
	@CLEANUP_bootstrap_gcc_2_95@

.rpcgen: .bootstrap
	$(RPCGEN) -h -o $(targetprefix)/include/rpcsvc/yppasswd.h $(targetprefix)/include/rpcsvc/yppasswd.x
	touch .rpcgen

.glibc: @DEPENDS_glibc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so -a ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) bootstrap_gcc; \
	elif [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) .gcc; \
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
		$(MAKE) all && \
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
		$(MAKE) all CROSS=$(target)- && \
		@INSTALL_uclibc@
	@CLEANUP_uclibc@
	touch .uclibc

#
# gcc second stage with glibc
#
.gcc: @DEPENDS_gcc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so ]; then \
		$(MAKE) .glibc; \
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
		$(MAKE) all && \
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
	$(MAKE) -C etc install
	touch .etc

.busybox: .bootstrap .etc @DEPENDS_busybox@
	@PREPARE_busybox@
	cd @DIR_busybox@ && \
		$(MAKE) CROSS=$(target)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
	touch .busybox

.tinylogin: .bootstrap .busybox @DEPENDS_tinylogin@
	@PREPARE_tinylogin@
	cd @DIR_tinylogin@ && \
		$(MAKE) CROSS=$(target)- CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
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
		$(MAKE) && \
		@INSTALL_modutils@
	@CLEANUP_modutils@
	touch .modutils

.ifupdown: .bootstrap @DEPENDS_ifupdown@
	@PREPARE_ifupdown@
	cd @DIR_ifupdown@ && \
		$(MAKE) all \
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
		$(MAKE) all && \
		@INSTALL_inetd@
	@CLEANUP_inetd@
	touch .inetd

.ftpd: .bootstrap .inetd @DEPENDS_ftpd@
	@PREPARE_ftpd@
	cd @DIR_ftpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) && \
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
		$(MAKE) -C telnet && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		LIBS="-lutil" \
		$(MAKE) -C telnetd && \
		@INSTALL_netkit_telnet@
	@CLEANUP_netkit_telnet@
	touch .netkit_telnet

.portmap: .bootstrap @DEPENDS_portmap@
	@PREPARE_portmap@
	cd @DIR_portmap@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) && \
		@INSTALL_portmap@
	@CLEANUP_portmap@
	touch .portmap

.procps: .bootstrap .libncurses @DEPENDS_procps@
	@PREPARE_procps@
	cd @DIR_procps@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) top ps && \
		@INSTALL_procps@
	@CLEANUP_procps@
	touch .procps


#######################
#
#   contrib libs
#

libs: \
	.libcrypto .libcurl .libffi .libfreetype .libjpeg \
	.libncurses .libpng .libreadline .libsdl .libsigc .libz 

.libcommoncplusplus: .bootstrap .libxml2 @DEPENDS_libcommoncplusplus@
	@PREPARE_libcommoncplusplus@
	cd @DIR_libcommoncplusplus@ &&\
		CC=$(target)-gcc \
		CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_libcommoncplusplus@
	@CLEANUP_libcommoncplusplus@
	touch .libcommoncplusplus

.libcrypto: .bootstrap @DEPENDS_libcrypto@
	@PREPARE_libcrypto@
	cd @DIR_libcrypto@ && \
		./Configure shared no-idea no-md2 no-md4 no-mdc2 no-rc2 no-rc5 tuxbox --prefix=/ --openssldir=/ && \
		$(MAKE) all && \
		@INSTALL_libcrypto@
	@CLEANUP_libcrypto@
	touch .libcrypto

.libcurl: .bootstrap .libcrypto @DEPENDS_libcurl@
	@PREPARE_libcurl@
	cd @DIR_libcurl@ && \
		CC=$(target)-gcc \
		CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-random \
			--with-ssl && \
		$(MAKE) all && \
		@INSTALL_libcurl@
	@CLEANUP_libcurl@
	touch .libcurl

.libdb2: .bootstrap @DEPENDS_libdb2@
	@PREPARE_libdb2@
	cd @DIR_libdb2@/dist && \
		chmod 755 configure && \
		autoconf && \
		CC=$(target)-gcc \
		CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		CROSS_COMPILE=$(target)- \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-compat185 \
			--enable-cxx && \
		$(MAKE) all && \
		@INSTALL_libdb2@
	@CLEANUP_libdb2@
	touch .libdb2

.libdvbpsi: .bootstrap @DEPENDS_libdvbpsi@
	@PREPARE_libdvbpsi@
	cd @DIR_libdvbpsi@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_libdvbpsi@
	@CLEANUP_libdvbpsi@
	touch .libdvbpsi

.libffi: .bootstrap @DEPENDS_libffi@
	@PREPARE_libffi@
	cd @DIR_libffi@ && \
		CC=$(target)-gcc \
		CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_libffi@
	@CLEANUP_libffi@
	touch .libffi

.libfreetype: .bootstrap @DEPENDS_libfreetype@
	@PREPARE_libfreetype@
	cd @DIR_libfreetype@ && \
		$(MAKE) \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS)" \
			CFG="--host=${target} --prefix=${targetprefix}" && \
		$(MAKE) all && \
		@INSTALL_libfreetype@
	@CLEANUP_libfreetype@
	touch .libfreetype

.libncurses: .bootstrap @DEPENDS_libncurses@
	@PREPARE_libncurses@
	cd @DIR_libncurses@ && \
		CC=$(target)-gcc \
		CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		BUILD_CC=$(CC) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-terminfo-dirs=/share/terminfo \
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

.libnet: .bootstrap @DEPENDS_libnet@
	@PREPARE_libnet@
	cd @DIR_libnet@ && \
		CC=$(target)-gcc \
		AR=$(target)-ar \
		RANLIB=$(target)-ranlib \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-pf_packet=yes \
			--with-fast_x86_check=no && \
		$(MAKE) all && \
		@INSTALL_libnet@
	@CLEANUP_libnet@
	touch .libnet

.libnids: .bootstrap .libnet @DEPENDS_libnids@
	@PREPARE_libnids@
	cd @DIR_libnids@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_libnids@
	@CLEANUP_libnids@
	touch .libnids

.libjpeg: .bootstrap @DEPENDS_libjpeg@
	@PREPARE_libjpeg@
	cd @DIR_libjpeg@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) libjpeg.so.6 && \
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
		$(MAKE) all && \
		@INSTALL_libpcap@
	@CLEANUP_libpcap@
	touch .libpcap

.libpng: .bootstrap .libz @DEPENDS_libpng@
	@PREPARE_libpng@
	cd @DIR_libpng@ && \
		$(MAKE) all CC=$(target)-gcc CFLAGS="$(TARGET_CFLAGS) -DPNG_DEBUG=0" && \
		@INSTALL_libpng@
	@CLEANUP_libpng@
	touch .libpng

.libpopt: .bootstrap @DEPENDS_libpopt@
	@PREPARE_libpopt@
	cd @DIR_libpopt@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix)\
			--with-pic \
			--disable-nls && \
		$(MAKE) all && \
		@INSTALL_libpopt@
	@CLEANUP_libpopt@
	touch .libpopt

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
		$(MAKE) -C src/moc QTDIR=`pwd` && \
		@INSTALL_libqt@
	@CLEANUP_libqt@
	touch .libqt

.libreadline: .bootstrap @DEPENDS_libreadline@
	@PREPARE_libreadline@
	cd @DIR_libreadline@ && autoconf &&\
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) shared && \
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
		$(MAKE) all && \
		@INSTALL_libsdl@
	@CLEANUP_libsdl@
	touch .libsdl

.libsigc: .bootstrap @DEPENDS_libsigc@
	@PREPARE_libsigc@
	cd @DIR_libsigc@ && \
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
		$(MAKE) all && \
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
		$(MAKE) all && \
		@INSTALL_libxml2@
	@CLEANUP_libxml2@
	touch .libxml2

.libxmlparse: .bootstrap @DEPENDS_libxmlparse@
	@PREPARE_libxmlparse@
	cd @DIR_libxmlparse@ && \
		aclocal -I . && \
		libtoolize --automake --force && \
		autoconf && \
		automake --add-missing --force-missing && \
		CC=$(target)-gcc \
		CXX=$(target)-g++ \
		RANLIB=$(target)-ranlib \
		NM=$(target)-nm \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--enable-ambiguous \
			--enable-libstdcpp3 && \
		$(MAKE) all && \
		@INSTALL_libxmlparse@
	@CLEANUP_libxmlparse@
	touch .libxmlparse

.libxmlwrapp: .bootstrap .libxml2 @DEPENDS_libxmlwrapp@
	@PREPARE_libxmlwrapp@
	cd @DIR_libxmlwrapp@ && \
		CXX=$(target)-g++ \
		CXXFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure.pl \
			--disable-examples \
			--prefix $(targetprefix) && \
		$(MAKE) all && \
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
		$(MAKE) libz.so.1.1.4 && \
		@INSTALL_libz@
	@CLEANUP_libz@
	touch .libz

#######################
#
#   contrib apps
#

contrib_apps: .console_tools .fbset .lirc .ssh .tcpdump .xrc

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

.console_tools: .bootstrap .console_data @DEPENDS_console_tools@
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

.dsniff: .bootstrap .libnet .libnids .libdb2 .rpcgen @DEPENDS_dsniff@
	@PREPARE_dsniff@
	cd @DIR_dsniff@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--without-x && \
		$(MAKE) all && \
		@INSTALL_dsniff@
	@CLEANUP_dsniff@
	touch .dsniff

.fbset: .bootstrap @DEPENDS_fbset@
	@PREPARE_fbset@
	cd @DIR_fbset@ && \
		$(MAKE) \
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

.lsof: .bootstrap @DEPENDS_lsof@
	@PREPARE_lsof@
	cd @DIR_lsof@ && \
		CROSS_COMPILE=$(target)- \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LSOF_VSTR=$(KERNELVERSION) \
		LINUX_CLIB="-DGLIBCV=202" \
		./Configure -n linux && \
		$(MAKE) all && \
		@INSTALL_lsof@
	@CLEANUP_lsof@
	touch .lsof

.pump: .bootstrap .libpopt @DEPENDS_pump@
	@PREPARE_pump@
	cd @DIR_pump@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) all && \
		@INSTALL_pump@
	@CLEANUP_pump@
	touch .pump

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
		$(MAKE) all && \
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
		$(MAKE) && \
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

.thttpd: @DEPENDS_thttpd@
	@PREPARE_thttpd@
	cd @DIR_thttpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_thttpd@
	@CLEANUP_thttpd@
	touch .thttpd


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
		$(MAKE) all && \
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
		$(MAKE) all && \
		@INSTALL_gdb@
	@CLEANUP_gdb@
	touch .gdb

.gdb-remote: .bootstrap @DEPENDS_gdb@
	@PREPARE_gdb@
	cd @DIR_gdb@ && \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) && \
		$(MAKE) all && \
		@INSTALL_gdb@
	@CLEANUP_gdb@
	touch .gdb-remote

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
		$(MAKE) clean all LD=$(target)-ld && \
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
		$(MAKE) all && \
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
		$(MAKE) all && \
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
		$(MAKE) all && \
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
		$(MAKE) all && \
		@INSTALL_kaffe@
	@CLEANUP_kaffe@
	touch .kaffe

#######################
#
#   fun stuff
#

fun: .mad .scummvm

.gnuboy: .bootstrap @DEPENDS_gnuboy@
	@PREPARE_gnuboy@
	cd @DIR_gnuboy@ && \
		autoconf && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS) -I$(driverdir)/include" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_gnuboy@
	@CLEANUP_gnuboy@
	touch .gnuboy

.mad: .bootstrap .libz @DEPENDS_mad@
	@PREPARE_mad@
	cd @DIR_mad@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--enable-shared=yes \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls \
			--without-esd \
			--enable-speed \
			--enable-fpm=ppc \
			--enable-sso && \
		$(MAKE) all && \
		@INSTALL_mad@
	@CLEANUP_mad@
	touch .mad

.scummvm: .bootstrap .libreadline .libsdl @DEPENDS_scummvm@
	@PREPARE_scummvm@
	cd @DIR_scummvm@ && \
		$(MAKE) \
			CC=$(target)-g++ \
			CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TAGET_LDFLAGS)" \
			DEFINES="-DUNIX" && \
		@INSTALL_scummvm@
	@CLEANUP_scummvm@
	touch .scummvm

.sdldoom: .bootstrap .libsdl @DEPENDS_sdldoom@
	@PREPARE_sdldoom@
	cd @DIR_sdldoom@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_sdldoom@
	@CLEANUP_sdldoom@
	touch .sdldoom

#######################
#
#  DVB apps
#

dvb_apps: .dvbdate .dvbstream .dvbtext .dvbtune

.dvbdate: .bootstrap @DEPENDS_dvbdate@
	@PREPARE_dvbdate@
	cd @DIR_dvbdate@ && \
		$(MAKE) dvbdate \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -I$(driverdir)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)" && \
		@INSTALL_dvbdate@
	@CLEANUP_dvbdate@
	touch .dvbdate

.dvbstream: .bootstrap @DEPENDS_dvbstream@
	@PREPARE_dvbstream@
	cd @DIR_dvbstream@ && \
		$(MAKE) dvbstream rtpfeed\
			INCS="-I$(driverdir)/include" \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" && \
		@INSTALL_dvbstream@
	@CLEANUP_dvbstream@
	touch .dvbstream

.dvbtext: .bootstrap @DEPENDS_dvbtext@
	@PREPARE_dvbtext@
	cd @DIR_dvbtext@ && \
		$(target)-gcc $(TARGET_CFLAGS) -I$(driverdir)/include -o dvbtext dvbtext.c && \
		@INSTALL_dvbtext@
	@CLEANUP_dvbtext@
	touch .dvbtext

.dvbtune: .bootstrap @DEPENDS_dvbtune@
	@PREPARE_dvbtune@
	cd @DIR_dvbtune@ && \
		$(MAKE) \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -I$(driverdir)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)" && \
		@INSTALL_dvbtune@
	@CLEANUP_dvbtune@
	touch .dvbtune

.vls: .bootstrap .libdvbpsi @DEPENDS_vls@
	@PREPARE_vls@
	cd @DIR_vls@ && \
		CC=$(target)-gcc \
		CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-dvd \
			--with-dvb=$(driverdir)/include \
			--with-dvbpsi=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_vls@
	@CLEANUP_vls@
	touch .vls

#######################
#
#   own kernel and driver
#

boot: .ppcboot .linuxkernel .driver

KERNELGCC = `if [ -f $(hostprefix)/bin/$(target)-gcc-2.95 ]; then echo $(target)-gcc-2.95; else echo $(target)-gcc; fi`

.ppcboot: .bootstrap $(bootdir)/ppcboot/Makefile
if HOSTRULESET_CYGWIN
	$(MAKE) -C $(bootdir)/ppcboot dbox_config CYGWIN=1
	$(MAKE) -C $(bootdir)/ppcboot CROSS_COMPILE=$(target)- CYGWIN=1
	$(INSTALL) Patches/cygwin/mkimage.exe $(hostprefix)/bin
else
	$(MAKE) -C $(bootdir)/ppcboot dbox_config
	$(MAKE) -C $(bootdir)/ppcboot CROSS_COMPILE=$(target)- CC=$(KERNELGCC)
	$(INSTALL) $(bootdir)/ppcboot/tools/mkimage $(hostprefix)/bin
endif
	$(INSTALL) -m644 $(bootdir)/ppcboot/ppcboot $(bootprefix)
if MAINTAINER_MODE
else
	$(MAKE) -C $(bootdir)/ppcboot distclean
endif
	touch .ppcboot

.linuxkernel: .bootstrap .linuxdir
	@if [ ! -f $(hostprefix)/bin/mkimage ]; then \
		$(MAKE) .ppcboot; \
	fi
	$(MAKE) -C @DIR_linux@ zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- CC=$(KERNELGCC)
	$(MAKE) -C @DIR_linux@ modules_install \
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
	$(MAKE) -C @DIR_linux@ clean
endif
	touch .linuxkernel

.driver: .bootstrap .linuxkernel
	$(INSTALL) -d $(targetprefix)/bin
	$(INSTALL) -d $(targetprefix)/lib/modules/$(KERNELVERSION)/misc
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)- CC=$(KERNELGCC) \
		INSTALL_MOD_PATH=$(targetprefix)
	$(MAKE) -C $(driverdir) install \
		KERNEL_LOCATION=$(buildprefix)/linux \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix)
if MAINTAINER_MODE
else
	$(MAKE) -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
endif
	touch .driver

driver-clean:
	$(MAKE) -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
	rm .driver

#######################
#
#   own applications
#

apps: .dvbsnoop .enigma .fx2 .lcars .lcdmenu .neutrino .stream .tuxtxt

if MAINTAINER_MODE
$(appsdir)/configure: $(appsdir)/configure.ac
	cd $(appsdir) && \
		./autogen.sh

$(appsdir)/Makefile: .bootstrap .libcurl .libfreetype .libpng .libsigc $(appsdir)/configure $(appsdir)/Makefile.am
	cd $(appsdir) && \
		CC=$(target)-gcc CXX=$(target)-g++ CFLAGS="" CXXFLAGS=""\
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

.apps: .libqt .libxml2 .mad .msttf .thttpd $(appsdir)/Makefile
	$(MAKE) -C $(appsdir) all install
	touch .apps

.camd: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/camd all install
	touch .camd

.dvbsnoop: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/dvbsnoop all install
	touch .dvbsnoop

.edvb: .libqt .msttf .tools
	$(MAKE) -C $(appsdir)/edvb all install
	touch .edvb

.enigma: .mad .tools .libxmltree
	$(MAKE) -C $(appsdir)/enigma all install
	touch .enigma

.fx2: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/fx2 all install
	touch .fx2

.lcars: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/lcars all install
	touch .lcars

.lcdmenu: $(appsdir)/Makefile .liblcddisplay
	$(MAKE) -C $(appsdir)/lcdmenu all install
	touch .lcdmenu

.neutrino: .thttpd .libconfigfile .libcramfs .libdboxnet .liblcddisplay .libmd5sum .libucodes .sections .zapit
	$(MAKE) -C $(appsdir)/mczap all install
	touch .neutrino

.sections: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/sections all install
	touch .sections

.stream: .inetd .libmpegtools
	$(MAKE) -C $(appsdir)/stream all install
	touch .stream

.tools: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/tools all install
	touch .tools

.tuxtxt: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/tuxtxt all install
	touch .tuxtxt

.zapit: .camd .libxmltree
	$(MAKE) -C $(appsdir)/zapit all install
	touch .zapit

#######################
#
#  own libs
#

.libconfigfile: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/libconfigfile all install
	touch .libconfigfile

.libcramfs: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/libcramfs all install
	touch .libcramfs

.libdboxnet: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/libnet all
	touch .libdboxnet

.liblcddisplay: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/liblcddisplay all install
	touch .liblcddisplay

.libmd5sum: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/libmd5sum all install
	touch .libmd5sum

.libmpegtools: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/libmpegtools all
	touch .libmpegtools

.libucodes: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/libucodes all install
	touch .libucodes

.libxmltree: $(appsdir)/Makefile
	$(MAKE) -C $(appsdir)/libxmltree install
	touch .libxmltree

#######################
#
#   flash
#

if TARGETRULESET_FLASH
rebuild-flash:
	-rm -rf $(flashprefix)/root
	$(MAKE) flash-lib

$(flashprefix)/root: .busybox .driver .modutils
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
	$(MAKE) -C etc install targetprefix=$(flashprefix)/root

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

$(flashprefix)/.part_network: $(flashprefix)/.flash .ifupdown .pump
	$(INSTALL) -d $(flashprefix)/root/etc/network
	cp -a $(targetprefix)/etc/network/* $(flashprefix)/root/etc/network
	$(INSTALL) $(targetprefix)/sbin/ifup $(targetprefix)/sbin/ifdown \
		$(targetprefix)/sbin/pump $(flashprefix)/root/sbin
	@touch $(flashprefix)/.part_network

flash-ftpd: $(flashprefix)/.part_ftpd

$(flashprefix)/.part_ftpd: $(flashprefix)/.flash $(flashprefix)/.part_inetd .ftpd
	$(INSTALL) -m644 $(targetprefix)/etc/vsftpd.conf $(flashprefix)/root/etc
	$(INSTALL) $(targetprefix)/sbin/in.ftpd $(flashprefix)/root/sbin
	$(INSTALL) -d $(flashprefix)/root/share/empty
	@touch $(flashprefix)/.part_ftpd

$(flashprefix)/.part_inetd: $(flashprefix)/.flash $(flashprefix)/.part_network .inetd
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

$(flashprefix)/.part_ssh: $(flashprefix)/.flash $(flashprefix)/.part_network .ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	cp -a $(targetprefix)/etc/ssh/ssh_config $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh $(targetprefix)/bin/scp \
		$(targetprefix)/bin/sftp $(flashprefix)/root/bin
	@touch $(flashprefix)/.part_ssh

flash-sshd: $(flashprefix)/.part_sshd

$(flashprefix)/.part_sshd: $(flashprefix)/.flash $(flashprefix)/.part_network .ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	cp -a $(targetprefix)/etc/ssh/* $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh-keygen $(targetprefix)/bin/scp \
		$(flashprefix)/root/bin
	$(INSTALL) -d $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/libexec/sftp-server $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/sbin/sshd $(flashprefix)/root/sbin
	$(INSTALL) -d $(flashprefix)/root/share/empty
	@touch $(flashprefix)/.part_sshd

flash-neutrino: $(flashprefix)/.part_neutrino

$(flashprefix)/.part_neutrino: $(flashprefix)/.flash .neutrino
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

flash-enigma: $(flashprefix)/.part_enigma

$(flashprefix)/.part_enigma: $(flashprefix)/.flash .enigma
	$(INSTALL) $(targetprefix)/bin/enigma $(flashprefix)/root/bin
	cp -a $(targetprefix)/share/tuxbox/enigma $(flashprefix)/root/share/tuxbox
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	cp -a $(targetprefix)/share/fonts/Marlett.ttf $(targetprefix)/share/fonts/unmrs.pfa \
		$(targetprefix)/share/fonts/blue*.ttf $(targetprefix)/share/fonts/v5loxica*.ttf \
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

flash-lcdmenu: $(flashprefix)/.part_lcdmenu

$(flashprefix)/.part_lcdmenu: $(flashprefix)/.flash .lcdmenu
	$(INSTALL) $(targetprefix)/bin/lcdmenu $(flashprefix)/root/bin
	cp -a $(targetprefix)/var/tuxbox/config/lcdmenu.conf $(flashprefix)/root/var/tuxbox/config
	@touch $(flashprefix)/.part_lcdmenu

flash-lib: $(flashprefix)/.lib

$(flashprefix)/.lib: $(flashprefix)/root $(shell ls -1 $(flashprefix)/.part_*)
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

	@$(INSTALL) -d $(flashprefix)/temp/var/etc/init.d
	@echo "/dev/mtdblock/3	/var	jffs2	defaults	0 0" >> $(flashprefix)/temp/etc/fstab

	@mv $(flashprefix)/temp/etc/init.d/start $(flashprefix)/temp/var/etc/init.d
	@ln -sf /var/etc/init.d/start $(flashprefix)/temp/etc/init.d/start

	@if [ -d $(flashprefix)/temp/etc/network ] ; then \
		ln -sf /tmp/ifstate $(flashprefix)/temp/etc/network/ifstate ; \
		mv $(flashprefix)/temp/etc/network $(flashprefix)/temp/var/etc/network ; \
		ln -sf /var/etc/network $(flashprefix)/temp/etc/network ; \
	fi

	@if [ -d $(flashprefix)/temp/etc/ssh ] ; then \
		mv $(flashprefix)/temp/etc/ssh $(flashprefix)/temp/var/etc/ssh ; \
		ln -sf /var/etc/ssh $(flashprefix)/temp/etc/ssh ; \
	fi

	@mv $(flashprefix)/temp/var $(flashprefix)/temp/share/tuxbox/image
	@$(INSTALL) -d $(flashprefix)/temp/var

	@$(FAKEROOT) $(MKCRAMFS) -n "TuxBox-`date +%Y%m%d`" $(flashprefix)/temp/ $(flashprefix)/root-cramfs.img
	@rm -rf $(flashprefix)/temp/

$(flashprefix)/var-jffs2.img: $(flashprefix)/.lib
	@cp -a $(flashprefix)/root/var $(flashprefix)/temp
	@$(FAKEROOT) $(MKJFFS2) -b -e 131072 -p -o $(flashprefix)/var-jffs2.img -r $(flashprefix)/temp/
	@rm -rf $(flashprefix)/temp/

$(flashprefix)/mix-cramfs-jffs2.img: $(flashprefix)/ppcboot-flfs.img $(flashprefix)/root-cramfs.img $(flashprefix)/var-jffs2.img
	@rm -f  $(flashprefix)/mix.img
	$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/mix-cramfs-jffs2.img -o build \
		--part ppcboot=$(flashprefix)/ppcboot-flfs.img \
		--part root=$(flashprefix)/root-cramfs.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/root-jffs2.img: $(flashprefix)/.lib
	@$(FAKEROOT) $(MKJFFS2) -b -e 131072 -o $(flashprefix)/root-jffs2.img -r $(flashprefix)/root/
endif

#######################
#
#   internal
#

clean-local:
	-$(MAKE) -C etc clean
	-$(MAKE) -C $(appsdir) clean
	-$(MAKE) -C $(bootdir)/ppcboot distclean
	-$(MAKE) -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
	-rm -f linux
	-rm -rf build
	-@CLEANUP@

distclean-local:
	-$(MAKE) -C etc distclean
	-$(MAKE) -C $(appsdir) distclean
	-rm Makefile-archive
	-rm .bootstrap
	-rm .directories .linuxdir .binutils .glibc .gcc .rpcgen
	-rm .etc .busybox .ftpd .ifupdown .inetd .modutils .netkit_telnet .procps .tinylogin
	-rm .libdb2 .libcommoncplusplus .libcrypto .libcurl .libffi .libfreetype
	-rm .libncurses .libjpeg .libnet .libnids .libpcap .libpng .libpopt
	-rm .libqt .libreadline .libsdl .libsigc .libxml2 .libxmlwrapp .libz
	-rm .cabextract .msttf
	-rm .gdb .ltrace .strace .nano
	-rm .kaffeh .kaffe
	-rm .mad .scummvm
	-rm .ppcboot .linuxkernel .driver
	-rm .camd .dvbsnoop .edvb .enigma .lcars .lcdmenu .neutrino .stream
	-rm .fx2 .sections .tools .tuxtxt .zapit
	-rm .libconfigfile .libcramfs .libxmltree
	-rm .liblcddisplay .libmd5sum .libmpegtools .libdboxnet .libucodes
	-rm .console_data .console_tools .dsniff .fbset .lirc .pump .ssh .tcpdump .xrc .thttpd
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

ACLOCAL_AMFLAGS = -I .

CONFIG_STATUS_DEPENDENCIES = \
	$(top_srcdir)/rules-install $(top_srcdir)/rules-install-flash $(top_srcdir)/rules-install.pl \
	$(top_srcdir)/rules-make $(top_srcdir)/rules-make-cygwin $(top_srcdir)/rules-make.pl \
	Makefile-archive

