PATH := $(hostprefix)/bin:$(PATH)

all: core libs root boot apps devel
extra: java contrib_apps fun dvb_apps

#######################
#
#   core
#

core: .directories .binutils .linuxdir .glibc .gcc

.bootstrap:
	@if [ ! -f .glibc ]; then \
		$(MAKE) .glibc .gcc; \
	elif [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
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
	cat Patches/linux-dbox2.config > @DIR_linux@/.config
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
		CC=$(CC) \
		CFLAGS="$(CFLAGS)" \
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

.glibc: @DEPENDS_glibc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so -a ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) bootstrap_gcc; \
	elif [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) .gcc; \
	fi
	@PREPARE_glibc@
	cd @DIR_glibc@ && \
		CC=$(target)-gcc \
		AR=$(target)-ar \
		RANLIB=$(target)-ranlib \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
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

root: \
	.etc .busybox .ftpd .ifupdown .inetd .modutils \
	.netkit_telnet .procps .tinylogin .watchdog

root_optional: \
	.portmap

.busybox: .bootstrap .etc @DEPENDS_busybox@
	@PREPARE_busybox@
	cd @DIR_busybox@ && \
		CFLAGS="" \
		$(MAKE) \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
	touch .busybox

.etc:
	$(MAKE) -C etc install
	touch .etc

.ftpd: .bootstrap .inetd @DEPENDS_ftpd@
	@PREPARE_ftpd@
	cd @DIR_ftpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) && \
		@INSTALL_ftpd@
	@CLEANUP_ftpd@
	touch .ftpd

.ifupdown: .bootstrap @DEPENDS_ifupdown@
	@PREPARE_ifupdown@
	cd @DIR_ifupdown@ && \
		$(MAKE) all \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" && \
		@INSTALL_ifupdown@
	@CLEANUP_ifupdown@
	touch .ifupdown

.inetd: .bootstrap @DEPENDS_inetd@
	@PREPARE_inetd@
	touch @DIR_inetd@/MCONFIG
	cd @DIR_inetd@/inetd && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) all && \
		@INSTALL_inetd@
	@CLEANUP_inetd@
	touch .inetd

.modutils: .bootstrap @DEPENDS_modutils@
	@PREPARE_modutils@
	cd @DIR_modutils@ && \
		@BUILDENV_modutils@ \
		BUILDCC=$(CC) BUILDCFLAGS="-O2" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-root-check \
			--disable-strip && \
		$(MAKE) && \
		@INSTALL_modutils@
	@CLEANUP_modutils@
	touch .modutils

.netkit_telnet: .bootstrap .inetd .tinylogin .libncurses @DEPENDS_netkit_telnet@
	@PREPARE_netkit_telnet@
	touch @DIR_netkit_telnet@/MCONFIG
	cd @DIR_netkit_telnet@ && \
		@BUILDENV_netkit_telnet@ \
		LIBS="-lncurses" \
		$(MAKE) -C telnet && \
		@BUILDENV_netkit_telnet@ \
		LIBS="-lutil" \
		$(MAKE) -C telnetd && \
		@INSTALL_netkit_telnet@
	@CLEANUP_netkit_telnet@
	touch .netkit_telnet

.portmap: .bootstrap @DEPENDS_portmap@
	@PREPARE_portmap@
	cd @DIR_portmap@ && \
		@BUILDENV_portmap@ \
		$(MAKE) && \
		@INSTALL_portmap@
	@CLEANUP_portmap@
	touch .portmap

.procps: .bootstrap .libncurses @DEPENDS_procps@
	@PREPARE_procps@
	cd @DIR_procps@ && \
		@BUILDENV_procps@ \
		$(MAKE) top ps && \
		@INSTALL_procps@
	@CLEANUP_procps@
	touch .procps

.tinylogin: .bootstrap .busybox @DEPENDS_tinylogin@
	@PREPARE_tinylogin@
	cd @DIR_tinylogin@ && \
		CFLAGS="" \
		$(MAKE) \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_tinylogin@
	@CLEANUP_tinylogin@
	touch .tinylogin

.watchdog: .bootstrap @DEPENDS_watchdog@
	@PREPARE_watchdog@
	cd @DIR_watchdog@ && \
		@BUILDENV_watchdog@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--cache-file=/dev/null && \
		$(MAKE) all && \
		@INSTALL_watchdog@
	@CLEANUP_watchdog@
	touch .watchdog


#######################
#
#   contrib libs
#

libs: \
	.libcrypto .libcurl .libdirectfb .libdirectfbpp .libdvbpsi \
	.libfreetype .libjpeg .libmad .libncurses .libpng \
	.libreadline .libsdl .libsigc .libz

libs_optional: \
	.libcommoncplusplus .libffi \
	.libpcap .libpopt .libxml2

.libboost: .bootstrap @DEPENDS_libboost@
	@PREPARE_libboost@
	cd @DIR_libboost@ && \
		@INSTALL_libboost@
	@CLEANUP_libboost@
	touch .libboost

.libcommoncplusplus: .bootstrap .libxml2 @DEPENDS_libcommoncplusplus@
	@PREPARE_libcommoncplusplus@
	cd @DIR_libcommoncplusplus@ && \
		@BUILDENV_libcommoncplusplus@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		rm -f $(hostprefix)/bin/ccgnu2-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < src/ccgnu2-config > $(hostprefix)/bin/ccgnu2-config && \
		chmod 755 $(hostprefix)/bin/ccgnu2-config && \
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

.libcurl: .bootstrap @DEPENDS_libcurl@
	@PREPARE_libcurl@
	cd @DIR_libcurl@ && \
		@BUILDENV_libcurl@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-random && \
		$(MAKE) all && \
		rm -f $(hostprefix)/bin/curl-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < curl-config > $(hostprefix)/bin/curl-config && \
		chmod 755 $(hostprefix)/bin/curl-config && \
		@INSTALL_libcurl@
	@CLEANUP_libcurl@
	touch .libcurl

.libdirectfb: .bootstrap .libfreetype .libjpeg .libpng .libz @DEPENDS_libdirectfb@
	@PREPARE_libdirectfb@
	cd @DIR_libdirectfb@ && \
		@BUILDENV_libdirectfb@ \
		CPPFLAGS="-I$(driverdir)/include" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-avifile \
			--disable-jpeg \
			--disable-sdl && \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < directfb-config > $(hostprefix)/bin/directfb-config && \
		chmod 755 $(hostprefix)/bin/directfb-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < directfb.pc > directfb.pc.tmp && \
		mv directfb.pc.tmp directfb.pc && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < directfb-internal.pc > directfb-internal.pc.tmp && \
		mv directfb-internal.pc.tmp directfb-internal.pc && \
		@INSTALL_libdirectfb@
	@CLEANUP_libdirectfb@
	touch .libdirectfb

.libdirectfbpp: .bootstrap .libdirectfb @DEPENDS_libdirectfbpp@
	@PREPARE_libdirectfbpp@
	cd @DIR_libdirectfbpp@ && \
		@BUILDENV_libdirectfbpp@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < dfb++-config > $(hostprefix)/bin/dfb++-config && \
		chmod 755 $(hostprefix)/bin/dfb++-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < dfb++.pc > dfb++.pc.tmp && \
		mv dfb++.pc.tmp dfb++.pc && \
		@INSTALL_libdirectfbpp@
	@CLEANUP_libdirectfbpp@
	touch .libdirectfbpp

.libdvbpsi: .bootstrap @DEPENDS_libdvbpsi@
	@PREPARE_libdvbpsi@
	cd @DIR_libdvbpsi@ && \
		@BUILDENV_libdvbpsi@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libdvbpsi@
	@CLEANUP_libdvbpsi@
	touch .libdvbpsi

.libffi: .bootstrap @DEPENDS_libffi@
	@PREPARE_libffi@
	cd @DIR_libffi@ && \
		@BUILDENV_libffi@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libffi@
	@CLEANUP_libffi@
	touch .libffi

.libfreetype: .bootstrap @DEPENDS_libfreetype@
	@PREPARE_libfreetype@
	cd @DIR_libfreetype@ && \
		@BUILDENV_libfreetype@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		rm -f $(hostprefix)/bin/freetype-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < builds/unix/freetype-config > $(hostprefix)/bin/freetype-config && \
		chmod 755 $(hostprefix)/bin/freetype-config && \
		@INSTALL_libfreetype@
	@CLEANUP_libfreetype@
	touch .libfreetype

.libjpeg: .bootstrap @DEPENDS_libjpeg@
	@PREPARE_libjpeg@
	cd @DIR_libjpeg@ && \
		@BUILDENV_libjpeg@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) libjpeg.so.6 && \
		@INSTALL_libjpeg@
	@CLEANUP_libjpeg@
	touch .libjpeg

.libmad: .bootstrap .libz @DEPENDS_libmad@
	@PREPARE_libmad@
	cd @DIR_libmad@ && \
		@BUILDENV_libmad@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-shared=yes \
			--disable-nls \
			--without-esd \
			--enable-speed \
			--enable-fpm=ppc \
			--enable-sso && \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < libid3tag/id3tag.pc > libid3tag/id3tag.pc.tmp && \
		mv libid3tag/id3tag.pc.tmp libid3tag/id3tag.pc && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < libmad/mad.pc > libmad/mad.pc.tmp && \
		mv libmad/mad.pc.tmp libmad/mad.pc && \
		@INSTALL_libmad@
	@CLEANUP_libmad@
	touch .libmad

.libncurses: .bootstrap @DEPENDS_libncurses@
	@PREPARE_libncurses@
	cd @DIR_libncurses@ && \
		@BUILDENV_libncurses@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
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
		$(MAKE) libs \
			HOSTCC=$(CC) \
			HOSTCCFLAGS="$(CFLAGS) -DHAVE_CONFIG_H -I../ncurses -DNDEBUG -D_GNU_SOURCE -I../include" \
			HOSTLDFLAGS="$(LDFLAGS)" && \
		@INSTALL_libncurses@
	@CLEANUP_libncurses@
	touch .libncurses

.libpcap: .bootstrap @DEPENDS_libpcap@
	@PREPARE_libpcap@
	cd @DIR_libpcap@ && \
		@BUILDENV_libpcap@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-pcap=linux && \
		$(MAKE) all && \
		@INSTALL_libpcap@
	@CLEANUP_libpcap@
	touch .libpcap

.libpng: .bootstrap .libz @DEPENDS_libpng@
	@PREPARE_libpng@
	cd @DIR_libpng@ && \
		$(MAKE) libpng.a libpng12.so libpng.pc libpng-config \
	 		@BUILDENV_libpng@ \
			CPPFLAGS="-DPNG_DEBUG=0" \
			prefix=$(targetprefix) && \
		@INSTALL_libpng@
	@CLEANUP_libpng@
	touch .libpng

.libpopt: .bootstrap @DEPENDS_libpopt@
	@PREPARE_libpopt@
	cd @DIR_libpopt@ && \
		@BUILDENV_libpopt@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-pic \
			--disable-nls && \
		$(MAKE) all && \
		@INSTALL_libpopt@
	@CLEANUP_libpopt@
	touch .libpopt

.libreadline: .bootstrap @DEPENDS_libreadline@
	@PREPARE_libreadline@
	cd @DIR_libreadline@ && \
		autoconf && \
		@BUILDENV_libreadline@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libreadline@
	@CLEANUP_libreadline@
	touch .libreadline

.libsdl: .bootstrap .libdirectfb @DEPENDS_libsdl@
	@PREPARE_libsdl@
	cd @DIR_libsdl@ && \
		@BUILDENV_libsdl@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
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
		rm -f $(hostprefix)/bin/sdl-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < sdl-config > $(hostprefix)/bin/sdl-config && \
		chmod 755 $(hostprefix)/bin/sdl-config && \
		@INSTALL_libsdl@
	@CLEANUP_libsdl@
	touch .libsdl

.libsigc: .bootstrap @DEPENDS_libsigc@
	@PREPARE_libsigc@
	cd @DIR_libsigc@ && \
		@BUILDENV_libsigc@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-checks && \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < sigc++-1.2.pc > sigc++-1.2.pc.tmp && \
		mv sigc++-1.2.pc.tmp sigc++-1.2.pc && \
		@INSTALL_libsigc@
	@CLEANUP_libsigc@
	touch .libsigc

.libxml2: .bootstrap @DEPENDS_libxml2@
	@PREPARE_libxml2@
	cd @DIR_libxml2@ && \
		@BUILDENV_libxml2@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--without-html-dir \
			--with-threads \
			--without-ftp \
			--without-http \
			--without-html \
			--without-catalog \
			--without-docbook \
			--with-xpath \
			--without-xptr \
			--without-xinclude \
			--without-iconv \
			--without-debug \
			--without-mem-debug \
			--without-python && \
		$(MAKE) all && \
		rm -f $(hostprefix)/bin/xml2-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < xml2-config > $(hostprefix)/bin/xml2-config && \
		chmod 755 $(hostprefix)/bin/xml2-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < libxml-2.0.pc > libxml-2.0.pc.tmp && \
		mv libxml-2.0.pc.tmp libxml-2.0.pc && \
		@INSTALL_libxml2@
	@CLEANUP_libxml2@
	touch .libxml2

.libz: .bootstrap @DEPENDS_libz@
	@PREPARE_libz@
	cd @DIR_libz@ && \
		@BUILDENV_libz@ \
		./configure \
			--prefix= \
			--shared && \
		$(MAKE) all && \
		@INSTALL_libz@
	@CLEANUP_libz@
	touch .libz

#######################
#
#   contrib apps
#

contrib_apps: .console_data .console_tools .fbset .lirc .lsof .ssh .tcpdump
contrib_apps_optional: .pump

.console_data: .bootstrap @DEPENDS_console_data@
	@PREPARE_console_data@
	cd @DIR_console_data@ && \
		@BUILDENV_console_data@ \
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
		@BUILDENV_console_tools@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		@INSTALL_console_tools@
	@CLEANUP_console_tools@
	touch .console_tools

.directfb_examples: .bootstrap .libdirectfb @DEPENDS_directfb_examples@
	@PREPARE_directfb_examples@
	cd @DIR_directfb_examples@ && \
		@BUILDENV_directfb_examples@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_directfb_examples@
	@CLEANUP_directfb_examples@
	touch .directfb_examples

.fbset: .bootstrap @DEPENDS_fbset@
	@PREPARE_fbset@
	cd @DIR_fbset@ && \
		$(MAKE) \
			@BUILDENV_fbset@ && \
		@INSTALL_fbset@
	@CLEANUP_fbset@
	touch .fbset

.lirc: .bootstrap @DEPENDS_lirc@
	@PREPARE_lirc@
	cd @DIR_lirc@ && \
		@BUILDENV_lirc@ \
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
		@BUILDENV_pump@ \
		$(MAKE) all && \
		@INSTALL_pump@
	@CLEANUP_pump@
	touch .pump

.ssh: .bootstrap .libcrypto .libz @DEPENDS_ssh@
	@PREPARE_ssh@
	cd @DIR_ssh@ && \
		@BUILDENV_ssh@ \
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
		CFLAGS="$(TARGET_CFLAGS) -I$(targetprefix)/include -L$(targetprefix)/lib" \
		LDFLAGS="$(TARGET_LDFLAGS) -L$(targetprefix)/lib"  \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--libdir=$(targetprefix)/lib \
			--build=$(build) && \
		$(MAKE) && \
		@INSTALL_tcpdump@
	@CLEANUP_tcpdump@
	touch .tcpdump


#######################
#
#   development tools
#

devel: .gdb .ltrace .strace .nano
devel_optional: .gdb-remote .ksymoops

.gdb: .bootstrap .libncurses @DEPENDS_gdb@
	@PREPARE_gdb@
	cd @DIR_gdb@ && \
		@BUILDENV_gdb@ \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--nfp \
			--disable-sim \
			--without-sim \
			--without-expect \
			--disable-expect \
			--prefix= && \
		$(MAKE) all-gdb && \
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
		$(MAKE) all-gdb && \
		$(MAKE) install-gdb
	@CLEANUP_gdb@
	touch .gdb-remote

.ksymoops: .bootstrap @DEPENDS_ksymoops@
	@PREPARE_ksymoops@
	cd @DIR_ksymoops@ && \
		$(MAKE) CC=$(target)-gcc DEF_MAP="\\\"/boot/System.map-*r\\\"" DEF_VMLINUX="\\\"/boot/vmlinux-*r\\\"" && \
		@INSTALL_ksymoops@
	@CLEANUP_ksymoops@
	touch .ksymoops

.ltrace: .bootstrap @DEPENDS_ltrace@
	@PREPARE_ltrace@
	cd @DIR_ltrace@ && \
		@BUILDENV_ltrace@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) clean all LD=$(target)-ld && \
		@INSTALL_ltrace@
	@CLEANUP_ltrace@
	touch .ltrace

.strace: .bootstrap @DEPENDS_strace@
	@PREPARE_strace@
	cd @DIR_strace@ && \
		@BUILDENV_strace@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_strace@
	@CLEANUP_strace@
	touch .strace

.nano: .bootstrap @DEPENDS_nano@
	@PREPARE_nano@
	cd @DIR_nano@ && \
		@BUILDENV_nano@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
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
			--host=$(build) \
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
		@BUILDENV_kaffe@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
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

fun: .gnuboy .scummvm .sdldoom

.gnuboy: .bootstrap @DEPENDS_gnuboy@
	@PREPARE_gnuboy@
	cd @DIR_gnuboy@ && \
		autoconf && \
		@BUILDENV_gnuboy@ \
		CPPFLAGS="-I$(driverdir)/include" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_gnuboy@
	@CLEANUP_gnuboy@
	touch .gnuboy

.scummvm: .bootstrap .libreadline .libsdl @DEPENDS_scummvm@
	@PREPARE_scummvm@
	cd @DIR_scummvm@ && \
		$(MAKE) \
			@BUILDENV_scummvm@ \
			DEFINES="-DUNIX" && \
		@INSTALL_scummvm@
	@CLEANUP_scummvm@
	touch .scummvm

.sdldoom: .bootstrap .libsdl @DEPENDS_sdldoom@
	@PREPARE_sdldoom@
	cd @DIR_sdldoom@ && \
		@BUILDENV_sdldoom@ \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_sdldoom@
	@CLEANUP_sdldoom@
	touch .sdldoom

#######################
#
#  DVB apps
#

dvb_apps: .dvbdate .dvbstream .dvbtext .dvbtune .vls

.dvbdate: .bootstrap @DEPENDS_dvbdate@
	@PREPARE_dvbdate@
	cd @DIR_dvbdate@ && \
		$(MAKE) dvbdate \
			@BUILDENV_dvbdate@ \
			CPPFLAGS="-I$(driverdir)/include" && \
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
			@BUILDENV_dvbtune@ \
			CPPFLAGS="-I$(driverdir)/dvb/include -DNEWSTRUCT" && \
		@INSTALL_dvbtune@
	@CLEANUP_dvbtune@
	touch .dvbtune

.vls: .bootstrap .libdvbpsi @DEPENDS_vls@
	@PREPARE_vls@
	cd @DIR_vls@ && \
		@BUILDENV_vls@ \
		CCFLAGS="-mcpu=823 -O3 -mmultiple -mstring -pipe" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-dvd \
			--with-dvb=$(driverdir)/dvb/include && \
		$(MAKE) all && \
		@INSTALL_vls@
	@CLEANUP_vls@
	touch .vls

#######################
#
#   own kernel and driver
#

boot: .ppcboot .linuxkernel .videodevX .driver

KERNELGCC = `if [ -f $(hostprefix)/bin/$(target)-gcc-2.95 ]; then echo $(target)-gcc-2.95; else echo $(target)-gcc; fi`

.ppcboot: .bootstrap $(bootdir)/ppcboot/Makefile
if HOSTRULESET_CYGWIN
	$(MAKE) -C $(bootdir)/ppcboot dbox2_config CYGWIN=1
	$(MAKE) -C $(bootdir)/ppcboot CROSS_COMPILE=$(target)- CYGWIN=1
	$(INSTALL) Patches/cygwin/mkimage.exe $(hostprefix)/bin
else
	$(MAKE) -C $(bootdir)/ppcboot dbox2_config
	$(MAKE) -C $(bootdir)/ppcboot CROSS_COMPILE=$(target)-
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

	$(INSTALL) -d $(targetprefix)/boot
	$(INSTALL) -m644 @DIR_linux@/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
	$(INSTALL) -m644 @DIR_linux@/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)
if MAINTAINER_MODE
else
	$(MAKE) -C @DIR_linux@ clean
endif
	touch .linuxkernel

.videodevX: .bootstrap .linuxkernel @DEPENDS_videodevX@
	@PREPARE_videodevX@
	cd @DIR_videodevX@ && sed -e "s,^RUNNING.*$$,RUNNING := $(targetprefix)/lib/modules/$(KERNELVERSION)/build," \
	-e "s,^KERNEL_DIR.*$$,KERNEL_DIR := $(buildprefix)/linux," \
	-e "s,^INSTALL_MOD_PATH.*$$,INSTALL_MOD_PATH := $(targetprefix)," \
	< Makefile > Makefile.tmp && mv Makefile.tmp Makefile && \
	$(MAKE) && \
	@INSTALL_videodevX@
	@CLEANUP_videodevX@
	touch .videdevX
	

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

apps: .dvbsnoop .enigma .lcars .lcdmenu .neutrino .plugins .dvb_tools

CONFIGURE_OPTS = \
	--build=$(build) \
	--host=$(target) \
	--prefix=$(targetprefix) \
	--with-driver=$(driverdir) \
	--with-dvbincludes=$(driverdir)/dvb/include \
	--with-target=cdk

if MAINTAINER_MODE
CONFIGURE_OPTS_MAINTAINER = \
	--enable-maintainer-mode
endif

if TARGETRULESET_FLASH
CONFIGURE_OPTS_DEBUG = \
	--without-debug
endif

CONFIGURE = \
	./autogen.sh && \
	CC=$(target)-gcc \
	CXX=$(target)-g++ \
	CFLAGS="-Wall $(TARGET_CFLAGS)" \
	CXXFLAGS="-Wall $(TARGET_CXXFLAGS)" \
	./configure $(CONFIGURE_OPTS) $(CONFIGURE_OPTS_MAINTAINER) $(CONFIGURE_OPTS_DEBUG)

# dvb/dvbsnoop

$(appsdir)/dvb/dvbsnoop/Makefile: .bootstrap
	cd $(appsdir)/dvb/dvbsnoop && $(CONFIGURE)

.dvbsnoop: $(appsdir)/dvb/dvbsnoop/Makefile
	$(MAKE) -C $(appsdir)/dvb/dvbsnoop all install
	touch .dvbsnoop

# dvb/zapit

$(appsdir)/dvb/zapit/Makefile: .bootstrap .tuxbox_tools .misc_libs
	cd $(appsdir)/dvb/zapit && $(CONFIGURE)

.zapit: $(appsdir)/dvb/zapit/Makefile
	$(MAKE) -C $(appsdir)/dvb/zapit all install
	touch .zapit

# dvb/tools

$(appsdir)/dvb/tools/Makefile: .bootstrap .misc_libs
	cd $(appsdir)/dvb/tools && $(CONFIGURE)

.dvb_tools: $(appsdir)/dvb/tools/Makefile .inetd
	$(MAKE) -C $(appsdir)/dvb/tools all install
	touch .dvb_tools

# misc/libs

$(appsdir)/misc/libs/Makefile: .bootstrap .libz
	cd $(appsdir)/misc/libs && $(CONFIGURE)

.misc_libs: $(appsdir)/misc/libs/Makefile
	$(MAKE) -C $(appsdir)/misc/libs all install
	touch .misc_libs

# misc/tools

$(appsdir)/misc/tools/Makefile: .bootstrap
	cd $(appsdir)/misc/tools && $(CONFIGURE)

.misc_tools: $(appsdir)/misc/tools/Makefile
	$(MAKE) -C $(appsdir)/misc/tools all install
	touch .misc_tools

# tuxbox/enigma

$(appsdir)/tuxbox/enigma/Makefile: .bootstrap .libfreetype .libmad .libpng .libsigc .misc_libs .plugins
	cd $(appsdir)/tuxbox/enigma && $(CONFIGURE)

.enigma: $(appsdir)/tuxbox/enigma/Makefile .tuxbox_tools
	$(MAKE) -C $(appsdir)/tuxbox/enigma all install
	touch .enigma

# tuxbox/funstuff

$(appsdir)/tuxbox/funstuff/Makefile: .bootstrap
	cd $(appsdir)/tuxbox/funstuff && $(CONFIGURE)

.funstuff: $(appsdir)/tuxbox/funstuff/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/funstuff all install
	touch .funstuff

# tuxbox/lcars

$(appsdir)/tuxbox/lcars/Makefile: .bootstrap .libcurl .libfreetype .plugins
	cd $(appsdir)/tuxbox/lcars && $(CONFIGURE)

.lcars: $(appsdir)/tuxbox/lcars/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/lcars all install
	touch .lcars

# tuxbox/lcd

$(appsdir)/tuxbox/lcd/Makefile: .bootstrap .libfreetype .misc_libs .tuxbox_libs
	cd $(appsdir)/tuxbox/lcd && $(CONFIGURE)

.lcdmenu: $(appsdir)/tuxbox/lcd/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/lcd/lcdmenu all install
	touch .lcdmenu

# tuxbox/libs

$(appsdir)/tuxbox/libs/Makefile: .bootstrap .libfreetype
	cd $(appsdir)/tuxbox/libs && $(CONFIGURE)

.tuxbox_libs: $(appsdir)/tuxbox/libs/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/libs all install
	touch .tuxbox_libs

# tuxbox/neutrino

$(appsdir)/tuxbox/neutrino/Makefile: .bootstrap .libboost .libcurl .libfreetype .libmad .misc_libs .plugins .tuxbox_libs .zapit
	cd $(appsdir)/tuxbox/neutrino && $(CONFIGURE)

.neutrino: $(appsdir)/tuxbox/neutrino/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install
	touch .neutrino

# tuxbox/plugins

$(appsdir)/tuxbox/plugins/Makefile: .bootstrap .libcurl
	cd $(appsdir)/tuxbox/plugins && $(CONFIGURE)

.plugins: $(appsdir)/tuxbox/plugins/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/plugins all install
	touch .plugins

# tuxbox/tools

$(appsdir)/tuxbox/tools/Makefile: .bootstrap
	cd $(appsdir)/tuxbox/tools && $(CONFIGURE)

.tuxbox_tools: $(appsdir)/tuxbox/tools/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/tools all install
	touch .tuxbox_tools

#######################
#
#   flash
#

if TARGETRULESET_FLASH
flash-all: flash-network flash-apps

flash-network: flash-ftpd flash-telnetd flash-ssh flash-sshd

flash-apps: flash-neutrino flash-enigma flash-lcars flash-lcdmenu flash-plugins

rebuild-flash:
	-rm -rf $(flashprefix)/root
	$(MAKE) flash-lib

$(flashprefix)/.flash: .busybox .driver .modutils .tuxbox_tools
	-rm -rf $(flashprefix)/root
	$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) -d $(flashprefix)/root/boot
	$(INSTALL) -d $(flashprefix)/root/dev
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox
	$(INSTALL) -d $(flashprefix)/root/mnt
	$(INSTALL) -d $(flashprefix)/root/proc
	$(INSTALL) -d $(flashprefix)/root/sbin
	$(INSTALL) -d $(flashprefix)/root/share/tuxbox
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/ucodes
	$(INSTALL) -d $(flashprefix)/root/tmp
	$(MAKE) -C etc install targetprefix=$(flashprefix)/root
	cp -pa $(bootprefix)/kernel-cdk $(flashprefix)/root/vmlinuz
	echo "version=0106`date +%Y%m%d%H%M`" > $(flashprefix)/root/.version
	echo "comment=Erstellt von `id -un`" >> $(flashprefix)/root/.version
	$(INSTALL) $(targetprefix)/bin/busybox $(flashprefix)/root/bin
	for i in `find $(targetprefix)/bin/ -lname "*busybox"` ; do cp -ap $$i $(flashprefix)/root/bin/ ; done
	$(INSTALL) $(targetprefix)/bin/switch $(flashprefix)/root/bin
	if [ -e $(targetprefix)/bin/eraseall ] ; then \
		$(INSTALL) $(targetprefix)/bin/eraseall $(flashprefix)/root/bin ; \
	fi
	echo "console=ttyS0" > $(flashprefix)/root/boot/ppcboot.conf
	sed -e 's/tmpfs/ramfs/' $(targetprefix)/etc/fstab > $(flashprefix)/root/etc/fstab
	rm -f $(flashprefix)/root/etc/init.d/start_*
	$(INSTALL) -d $(flashprefix)/root/lib/modules/$(KERNELVERSION)
	cp -ap $(targetprefix)/lib/modules/$(KERNELVERSION)/kernel $(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
		$(flashprefix)/root/lib/modules/$(KERNELVERSION)
	for i in `find $(targetprefix)/sbin/ -lname "*busybox"` ; do cp -pa $$i $(flashprefix)/root/sbin/ ; done
	$(INSTALL) $(targetprefix)/sbin/insmod $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/depmod $(flashprefix)/root/sbin
	for i in `find $(targetprefix)/sbin/ -lname "*insmod"` ; do cp -pa $$i $(flashprefix)/root/sbin/ ; done
	ln -s ../../boot $(flashprefix)/root/var/tuxbox/boot
	@touch $(flashprefix)/.flash

$(flashprefix)/.part_network: $(flashprefix)/.flash .ifupdown .pump
	$(INSTALL) -d $(flashprefix)/root/etc/network
	ln -sf /tmp/ifstate $(flashprefix)/root/etc/network/ifstate
	$(INSTALL) $(targetprefix)/sbin/ifup $(targetprefix)/sbin/ifdown \
		$(targetprefix)/sbin/pump $(flashprefix)/root/sbin
	@touch $(flashprefix)/.part_network

flash-ftpd: $(flashprefix)/.part_ftpd

$(flashprefix)/.part_ftpd: $(flashprefix)/.flash $(flashprefix)/.part_inetd .ftpd
	$(INSTALL) -d $(flashprefix)/root/share/empty
	$(INSTALL) $(targetprefix)/etc/vsftpd.conf $(flashprefix)/root/etc
	$(INSTALL) $(targetprefix)/sbin/in.ftpd $(flashprefix)/root/sbin
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
	for i in `find $(targetprefix)/bin/ -lname "*tinylogin"` ; do cp -pa $$i $(flashprefix)/root/bin/ ; done
	for i in `find $(targetprefix)/sbin/ -lname "*tinylogin"` ; do cp -pa $$i $(flashprefix)/root/sbin/ ; done
	@touch $(flashprefix)/.part_tinylogin

flash-ssh: $(flashprefix)/.part_ssh

$(flashprefix)/.part_ssh: $(flashprefix)/.flash $(flashprefix)/.part_network .ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh $(targetprefix)/bin/scp \
		$(targetprefix)/bin/sftp $(flashprefix)/root/bin
	cp -ap $(targetprefix)/etc/ssh/ssh_config $(flashprefix)/root/etc/ssh
	@touch $(flashprefix)/.part_ssh

flash-sshd: $(flashprefix)/.part_sshd

$(flashprefix)/.part_sshd: $(flashprefix)/.flash $(flashprefix)/.part_network .ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) -d $(flashprefix)/root/libexec
	$(INSTALL) -d $(flashprefix)/root/share/empty
	$(INSTALL) $(targetprefix)/bin/ssh-keygen $(targetprefix)/bin/scp \
		$(flashprefix)/root/bin
	cp -ap $(targetprefix)/etc/ssh/* $(flashprefix)/root/etc/ssh
	cp -ap $(targetprefix)/etc/init.d/start_sshd $(flashprefix)/root/etc/init.d/
	$(INSTALL) $(targetprefix)/libexec/sftp-server $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/sbin/sshd $(flashprefix)/root/sbin
	@touch $(flashprefix)/.part_sshd

flash-neutrino: $(flashprefix)/.part_neutrino

$(flashprefix)/.part_neutrino: $(flashprefix)/.flash .neutrino
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config/lirc
	$(INSTALL) $(targetprefix)/bin/controld $(targetprefix)/bin/neutrino \
		$(targetprefix)/bin/nhttpd $(targetprefix)/bin/timerd \
		$(flashprefix)/root/bin
	cp -pa $(targetprefix)/share/tuxbox/neutrino $(targetprefix)/share/tuxbox/lcdd \
		$(flashprefix)/root/share/tuxbox
	$(INSTALL) $(targetprefix)/bin/camd2 $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/sectionsd $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/zapit $(flashprefix)/root/bin
	if [ -e $(flashprefix)/root/bin/eraseall ] ; then \
		sed -e 's/neutrino/neutrino -su -flash/' $(targetprefix)/etc/init.d/start_neutrino > \
			$(flashprefix)/root/etc/init.d/start_neutrino ; \
	else \
		cp -pa $(targetprefix)/etc/init.d/start_neutrino $(flashprefix)/root/etc/init.d/ ; \
	fi
	cp -pa $(targetprefix)/share/fonts/micron*.ttf $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/var/tuxbox/config/zapit $(flashprefix)/root/var/tuxbox/config
	@touch $(flashprefix)/.part_neutrino

flash-enigma: $(flashprefix)/.part_enigma

$(flashprefix)/.part_enigma: $(flashprefix)/.flash .enigma
	$(INSTALL) $(targetprefix)/bin/enigma $(flashprefix)/root/bin
	cp -pa $(targetprefix)/share/tuxbox/enigma $(flashprefix)/root/share/tuxbox
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/share/fonts/blue*.ttf $(targetprefix)/share/fonts/v5loxica*.ttf $(targetprefix)/share/fonts/unmrs.pfa \
		$(flashprefix)/root/share/fonts
	@touch $(flashprefix)/.part_enigma

flash-lcars: $(flashprefix)/.part_lcars

$(flashprefix)/.part_lcars: $(flashprefix)/.flash .lcars
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	$(INSTALL) $(targetprefix)/bin/lcars $(flashprefix)/root/bin
	cp -pa $(targetprefix)/etc/init.d/start_lcars $(flashprefix)/root/etc/init.d/
	cp -pa $(targetprefix)/share/fonts/ds9.ttf $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/var/tuxbox/config/lcars $(flashprefix)/root/var/tuxbox/config
	@touch $(flashprefix)/.part_lcars

flash-plugins: $(flashprefix)/.part_plugins

$(flashprefix)/.part_plugins: $(flashprefix)/.flash .plugins
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config/tuxtxt
	cp -pa $(targetprefix)/lib/tuxbox/plugins/* $(flashprefix)/root/lib/tuxbox/plugins/
	cp -pa $(targetprefix)/share/fonts/tuxtxt.fon $(flashprefix)/root/share/fonts/
	cp -pa $(targetprefix)/var/tuxbox/config/games.cfg $(flashprefix)/root/var/tuxbox/config/
	cp -pa $(targetprefix)/var/tuxbox/config/tuxtxt/tuxtxt.conf $(flashprefix)/root/var/tuxbox/config/tuxtxt/
	@touch $(flashprefix)/.part_plugins

flash-lcdmenu: $(flashprefix)/.part_lcdmenu

$(flashprefix)/.part_lcdmenu: $(flashprefix)/.flash .lcdmenu
	$(INSTALL) $(targetprefix)/bin/lcdmenu $(flashprefix)/root/bin
	cp -pa $(targetprefix)/var/tuxbox/config/lcdmenu.conf $(flashprefix)/root/var/tuxbox/config
	@touch $(flashprefix)/.part_lcdmenu

flash-lib: $(flashprefix)/.lib

$(flashprefix)/.lib: $(flashprefix)/.flash $(shell ls -1 $(flashprefix)/.part_*)
	@find $(flashprefix)/root/lib -maxdepth 1 -type f -o -type l | xargs rm -f
	@cp -pa $(targetprefix)/lib/libnss_dns-?.*.so $(flashprefix)/root/lib
	@cp -pa $(targetprefix)/lib/libnss_files-?.*.so $(flashprefix)/root/lib
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
	@$(target)-strip --remove-section=.comment --remove-section=.note \
		`find $(flashprefix)/root/bin/ -path "*bin/?*"` 2>/dev/null || /bin/true
	@$(target)-strip --remove-section=.comment --remove-section=.note --strip-unneeded \
		`find $(flashprefix)/root/lib/tuxbox -name "*.so"` 2>/dev/null || /bin/true
	@chmod 755 -R $(flashprefix)/root/
	@touch $(flashprefix)/.lib

flash-mix-cramfs: $(flashprefix)/root-cramfs.img

flash-mix-jffs2: $(flashprefix)/var-jffs2.img

flash-mix-image: $(flashprefix)/mix-cramfs-jffs2.img

flash-jffs2-root: $(flashprefix)/root-jffs2.img

flash-jffs2-image: $(flashprefix)/only-jffs2.img

$(flashprefix)/root-cramfs.img: $(flashprefix)/.lib
	@rm -fr $(flashprefix)/cramfs
	@cp -pa $(flashprefix)/root $(flashprefix)/cramfs
	@rm -fr $(flashprefix)/cramfs/boot
	@rm -fr $(flashprefix)/cramfs/var/*
	@echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $(flashprefix)/cramfs/etc/fstab
	@$(INSTALL) -d $(flashprefix)/jffs2/etc/init.d
	@for i in `find $(flashprefix)/cramfs/etc/init.d/ -name "start*"` ; do \
		rm $$i ; ln -sf ../../var/etc/init.d/`basename $$i` $$i ; \
	done
	@rm -f $(flashprefix)/cramfs/etc/resolv.conf
	@ln -sf ../var/etc/resolv.conf $(flashprefix)/cramfs/etc/resolv.conf
	@if [ -d $(flashprefix)/cramfs/etc/network ] ; then \
		rm -fr $(flashprefix)/cramfs/etc/network ; \
		ln -sf ../var/etc/network $(flashprefix)/cramfs/etc/network ; \
	fi
	@if [ -d $(flashprefix)/cramfs/etc/ssh ] ; then \
		rm -fr $(flashprefix)/cramfs/etc/ssh ; \
		ln -sf ../var/etc/ssh $(flashprefix)/cramfs/etc/ssh ; \
	fi
	@if [ -e $(flashprefix)/cramfs/bin/tinylogin ] ; then \
		rm $(flashprefix)/cramfs/bin/tinylogin ; \
		ln -sf ../var/bin/tinylogin $(flashprefix)/cramfs/bin/tinylogin ; \
	fi
	@$(FAKEROOT) $(MKCRAMFS) -p -n "0106`date +%Y%m%d%H%M`" $(flashprefix)/cramfs/ $(flashprefix)/root-cramfs.img
	@rm -fr $(flashprefix)/cramfs

$(flashprefix)/var-jffs2.img: $(flashprefix)/.lib
	@rm -rf $(flashprefix)/jffs2
	@cp -pa $(flashprefix)/root/var $(flashprefix)/jffs2
	@rm -f $(flashprefix)/jffs2/tuxbox/boot
	@cp -pa $(flashprefix)/root/boot $(flashprefix)/jffs2/tuxbox/boot
	@$(INSTALL) -d $(flashprefix)/jffs2/etc/init.d
	@for i in `find $(flashprefix)/root/etc/init.d/ -name "start*"` ; do \
		cp -pa $$i $(flashprefix)/jffs2/etc/init.d/ ; \
	done
	@cp -pa $(flashprefix)/root/etc/resolv.conf $(flashprefix)/jffs2/etc/resolv.conf
	@if [ -d $(flashprefix)/root/etc/network ] ; then \
		cp -pa $(flashprefix)/root/etc/network $(flashprefix)/jffs2/etc/network ; \
	fi
	@if [ -d $(flashprefix)/root/etc/ssh ] ; then \
		cp -pa $(flashprefix)/root/etc/ssh $(flashprefix)/jffs2/etc/ssh ; \
	fi
	@if [ -e $(flashprefix)/root/bin/tinylogin ] ; then \
		$(INSTALL) -d $(flashprefix)/jffs2/bin ; \
		cp -pa $(flashprefix)/root/bin/tinylogin $(flashprefix)/jffs2/bin/ ; \
	fi
	@$(FAKEROOT) $(MKJFFS2) -b -e 131072 -p -r $(flashprefix)/jffs2/ -o $(flashprefix)/var-jffs2.img
	@rm -rf $(flashprefix)/jffs2

$(flashprefix)/mix-cramfs-jffs2.img: $(flashprefix)/root-cramfs.img $(flashprefix)/var-jffs2.img $(flashprefix)/mix-ppcboot-flfs.img
	@$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/mix-cramfs-jffs2.img -o build \
		--part ppcboot=$(flashprefix)/mix-ppcboot-flfs.img \
		--part root=$(flashprefix)/root-cramfs.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/root-jffs2.img: $(flashprefix)/.lib
	@$(FAKEROOT) $(MKJFFS2) -b -e 131072 -p -r $(flashprefix)/root/ -o $(flashprefix)/root-jffs2.img

$(flashprefix)/only-jffs2.img: $(flashprefix)/.lib $(flashprefix)/jffs2-ppcboot-flfs.img
	@$(FAKEROOT) $(MKJFFS2) -b -e 131072 --pad=8126464 -r $(flashprefix)/root/ -o $(flashprefix)/root-jffs2.tmp
	@cat $(flashprefix)/jffs2-ppcboot-flfs.img > $(flashprefix)/only-jffs2.img
	@cat $(flashprefix)/root-jffs2.tmp >> $(flashprefix)/only-jffs2.img
	@rm -f  $(flashprefix)/root-jffs2.tmp
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
	-rm .directories .linuxdir .binutils .glibc .gcc
	-rm .etc .busybox .ftpd .ifupdown .inetd .modutils .netkit_telnet .procps .tinylogin .watchdog
	-rm .libboost .libcommoncplusplus .libcrypto .libcurl
	-rm .libdirectfb .libdirectfbpp .libdvbpsi .libffi .libfreetype
	-rm .libncurses .libjpeg .libmad .libpcap .libpng .libpopt
	-rm .libreadline .libsdl .libsigc .libxml2 .libz
	-rm .gdb .ksymoops .ltrace .strace .nano
	-rm .kaffeh .kaffe
	-rm .gnuboy .scummvm .sdldoom
	-rm .ppcboot .linuxkernel .driver
	-rm .dvbsnoop .enigma .lcars .lcdmenu .neutrino .dvb_tools .zapit
	-rm .console_data .console_tools .fbset .lirc .pump .ssh .tcpdump
	-rm .dvbdate .dvbstream .dvbtext .dvbtune .vls
	-rm .misc_libs .misc_tools .plugins .tuxbox_libs .tuxbox_tools
	-rm -rf $(targetprefix)
	-rm -rf $(hostprefix)
if TARGETRULESET_FLASH
	-rm -rf $(flashprefix)
endif

@ARCHIVE@

if MAINTAINER_MODE
Makefile-archive: $(top_srcdir)/rules-archive
	$(top_srcdir)/rules-archive.pl $(top_srcdir)/rules-archive > Makefile-archive
endif

if TARGETRULESET_FLASH
.PHONY: core libs root apps boot devel java copy lib compress
else
.PHONY: core libs root apps boot devel java
endif

EXTRA_DIST = \
	rules-archive rules-archive.pl \
	rules-install rules-install-flash rules-install.pl \
	rules-make rules-make-cygwin rules-make.pl

ACLOCAL_AMFLAGS = -I .

CONFIG_STATUS_DEPENDENCIES = \
	$(top_srcdir)/rules-install $(top_srcdir)/rules-install-flash $(top_srcdir)/rules-install.pl \
	$(top_srcdir)/rules-make $(top_srcdir)/rules-make-cygwin $(top_srcdir)/rules-make.pl \
	Makefile-archive

-include ./Makefile.am.local
