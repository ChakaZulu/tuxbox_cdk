PATH := $(hostprefix)/bin:$(PATH)
BUILDENV := \
	AR=$(target)-ar \
	AS=$(target)-as \
	CC=$(target)-gcc \
	CXX=$(target)-g++ \
	NM=$(target)-nm \
	RANLIB=$(target)-ranlib \
	CFLAGS="$(TARGET_CFLAGS)" \
	CXXFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH=$(targetprefix)/lib/pkgconfig

all: core libs root boot apps devel
extra: java contrib_apps fun dvb_apps

# This rule script checks if all archives are present at the given address but
# does NOT download them.
#
# It takes some time so it's not useful to include it in a regular
# build

archivecheck:
	@$(buildprefix)/rules-downcheck.pl

#######################
#
#   core
#

core: directories binutils linuxdir glibc gcc

DEPDIR = .deps
	
VPATH = $(DEPDIR)

DEP_FILES = $(DEPDIR)/dummy

$(DEPDIR):
	$(INSTALL) -d $(DEPDIR)

$(DEPDIR)/bootstrap:
	@if [ ! -f glibc ]; then \
		$(MAKE) glibc gcc; \
	elif [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) gcc; \
	fi
	touch $@

$(DEPDIR)/directories:
	$(INSTALL) -d $(targetprefix)/bin
	$(INSTALL) -d $(targetprefix)/boot
	$(INSTALL) -d $(targetprefix)/dev
	$(INSTALL) -d $(targetprefix)/etc
	$(INSTALL) -d $(targetprefix)/include
	$(INSTALL) -d $(targetprefix)/mnt
	$(INSTALL) -d $(targetprefix)/lib
	$(INSTALL) -d $(targetprefix)/lib/pkgconfig
	$(INSTALL) -d $(targetprefix)/proc
	$(INSTALL) -d $(targetprefix)/root
	$(INSTALL) -d $(targetprefix)/sbin
	$(INSTALL) -d $(targetprefix)/tmp
	$(INSTALL) -d $(targetprefix)/var
	$(INSTALL) -d $(targetprefix)/var/etc
	$(INSTALL) -d $(targetprefix)/var/run
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
	touch $@

$(DEPDIR)/linuxdir: @DEPENDS_linux@
	@if [ ! -d $(targetprefix)/bin ]; then \
		$(MAKE) directories; \
	fi
	@PREPARE_linux@
if TARGETRULESET_FLASH
	cat Patches/linux-$(KERNELVERSION).config-flash > @DIR_linux@/.config
else
	cat Patches/linux-$(KERNELVERSION).config > @DIR_linux@/.config
endif
	$(MAKE) -C @DIR_linux@ oldconfig \
		ARCH=ppc
	$(MAKE) -C @DIR_linux@ include/linux/version.h \
		ARCH=ppc
	touch $@

$(DEPDIR)/binutils: @DEPENDS_binutils@
	@if [ ! -h linux ]; then \
		$(MAKE) linuxdir; \
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
	touch $@

#
# gcc first stage without glibc
#
bootstrap_gcc: @DEPENDS_bootstrap_gcc@
	@if [ ! -d $(hostprefix)/$(target)/bin/as ]; then \
		$(MAKE) binutils; \
	fi
	@PREPARE_bootstrap_gcc@
	$(INSTALL) -d $(hostprefix)/$(target)/sys-include
	ln -sf $(buildprefix)/linux/include/{asm,linux} $(hostprefix)/$(target)/sys-include/
	cd @DIR_bootstrap_gcc@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_bootstrap_gcc@ \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--with-cpu=$(CPU_MODEL) \
			--enable-target-optspace \
			--enable-languages="c" \
			--disable-shared \
			--disable-threads \
			--disable-nls \
			--nfp && \
		$(MAKE) all && \
		@INSTALL_bootstrap_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include
	@CLEANUP_bootstrap_gcc@

if TARGETRULESET_FLASH
GLIBC_EXTRA_FLAGS="--enable-kernel=$(KERNELVERSION)"
endif

$(DEPDIR)/glibc: @DEPENDS_glibc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so -a ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) bootstrap_gcc; \
	elif [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) gcc; \
	fi
	@PREPARE_glibc@
	cd @DIR_glibc@ && \
		$(BUILDENV) \
		@CONFIGURE_glibc@ \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-headers=$(buildprefix)/linux/include \
			--disable-profile \
			--enable-shared \
			--enable-add-ons=linuxthreads \
			--without-fp \
			$(GLIBC_EXTRA_FLAGS) && \
		$(MAKE) all && \
		@INSTALL_glibc@
	@CLEANUP_glibc@
	touch $@

#
# uClibc
# a minimalistic libc, won't currently work with libstdc++
#
$(DEPDIR)/uclibc: @DEPENDS_uclibc@
	@PREPARE_uclibc@
	cd @DIR_uclibc@ && \
		$(MAKE) all CROSS=$(target)- && \
		@INSTALL_uclibc@
	@CLEANUP_uclibc@
	touch $@

#
# gcc second stage with glibc
#
$(DEPDIR)/gcc: @DEPENDS_gcc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so ]; then \
		$(MAKE) glibc; \
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
			--with-cpu=$(CPU_MODEL) \
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
	touch $@

#######################
#
#   root
#

if TARGETRULESET_FLASH
root: \
	rootdirectories busybox ftpd \
	procps watchdog
else
root: \
	rootdirectories busybox ftpd modutils \
	procps watchdog
endif

root_optional: \
	portmap mrouted

$(DEPDIR)/busybox: bootstrap @DEPENDS_busybox@
	@PREPARE_busybox@
if TARGETRULESET_FLASH
	cat Patches/busybox-flash.config > @DIR_busybox@/.config
else
	cat Patches/busybox.config > @DIR_busybox@/.config
endif
	cd @DIR_busybox@ && \
		$(MAKE) dep all \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
	touch $@

$(DEPDIR)/rootdirectories:
	$(MAKE) -C root install
	touch $@

$(DEPDIR)/ftpd: bootstrap @DEPENDS_ftpd@
	@PREPARE_ftpd@
	cd @DIR_ftpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) && \
		@INSTALL_ftpd@
	@CLEANUP_ftpd@
	touch $@

$(DEPDIR)/module_init_tools: bootstrap @DEPENDS_module_init_tools@
	@PREPARE_module_init_tools@
	cd @DIR_module_init_tools@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) && \
		@INSTALL_module_init_tools@
	@CLEANUP_module_init_tools@
	touch $@

$(DEPDIR)/modutils: bootstrap @DEPENDS_modutils@
	@PREPARE_modutils@
	cd @DIR_modutils@ && \
		$(BUILDENV) \
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
	touch $@

$(DEPDIR)/portmap: bootstrap @DEPENDS_portmap@
	@PREPARE_portmap@
	cd @DIR_portmap@ && \
		$(BUILDENV) \
		$(MAKE) && \
		@INSTALL_portmap@
	@CLEANUP_portmap@
	touch $@

$(DEPDIR)/procps: bootstrap libncurses @DEPENDS_procps@
	@PREPARE_procps@
	cd @DIR_procps@ && \
		$(BUILDENV) \
		$(MAKE) top ps && \
		@INSTALL_procps@
	@CLEANUP_procps@
	touch $@

$(DEPDIR)/udev: bootstrap @DEPENDS_udev@
	@PREPARE_udev@
	cd @DIR_udev@ && \
		$(BUILDENV) \
		CROSS=$(target)- \
		$(MAKE) && \
		@INSTALL_udev@
	@CLEANUP_udev@
	touch $@

$(DEPDIR)/watchdog: bootstrap @DEPENDS_watchdog@
	@PREPARE_watchdog@
	cd @DIR_watchdog@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--cache-file=/dev/null && \
		$(MAKE) all && \
		@INSTALL_watchdog@
	@CLEANUP_watchdog@
	touch $@

$(DEPDIR)/mrouted: bootstrap @DEPENDS_mrouted@
	@PREPARE_mrouted@
	cd @DIR_mrouted@ && \
	    $(BUILDENV) \
	    $(MAKE) all && \
	    $(INSTALL) -m755 mrouted $(targetprefix)/bin/mrouted && \
	    $(INSTALL) -m755 map-mbone $(targetprefix)/bin/map-mbone && \
	    $(INSTALL) -m755 mrinfo $(targetprefix)/bin/mrinfo
	@CLEANUP_mrouted@
	touch $@

#######################
#
#   contrib libs
#

if WITH_LIBCRYPTO
OPTIONAL_LIBCRYPTO = libcrypto
endif

libs: \
	$(OPTIONAL_LIBCRYPTO) libcurl libdirectfb libdirectfbpp libdvbpsi \
	libfreetype libjpeg libmad libid3tag libncurses libpng \
	libreadline libsdl libsigc libz libdvb

libs_optional: \
	libcommoncplusplus libffi \
	libpcap libxml2

$(DEPDIR)/libboost: bootstrap @DEPENDS_libboost@
	@PREPARE_libboost@
	cd @DIR_libboost@ && \
		@INSTALL_libboost@
	@CLEANUP_libboost@
	touch $@

$(DEPDIR)/libcommoncplusplus: bootstrap libxml2 @DEPENDS_libcommoncplusplus@
	@PREPARE_libcommoncplusplus@
	cd @DIR_libcommoncplusplus@ && \
		$(BUILDENV) \
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
	touch $@

$(DEPDIR)/libcrypto: bootstrap @DEPENDS_libcrypto@
	@PREPARE_libcrypto@
	cd @DIR_libcrypto@ && \
		sed -e 's/__TUXBOX_CC__/$(target)-gcc/' -e 's/__TUXBOX_CFLAGS__/$(TARGET_CFLAGS)/' ./Configure > ./Configure.tuxbox && \
		sh ./Configure.tuxbox shared no-hw no-idea no-md2 no-md4 no-mdc2 no-rc2 no-rc5 tuxbox --prefix=/ --openssldir=/ && \
		$(MAKE) depend all && \
		@INSTALL_libcrypto@
	rm -f $(targetprefix)/lib/pkgconfig/openssl.pc && \
	sed -e "s,^prefix=,prefix=$(targetprefix)," < openssl-0.9.7d/openssl.pc > $(targetprefix)/lib/pkgconfig/openssl.pc && \
	@CLEANUP_libcrypto@
	touch $@

$(DEPDIR)/libcurl: bootstrap @DEPENDS_libcurl@
	@PREPARE_libcurl@
	cd @DIR_libcurl@ && \
		$(BUILDENV) \
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
	touch $@

$(DEPDIR)/libdirectfb: bootstrap libfreetype libjpeg libpng libz @DEPENDS_libdirectfb@
	@PREPARE_libdirectfb@
	cd @DIR_libdirectfb@ && \
		$(BUILDENV) \
		LDFLAGS=-L$(targetprefix)/lib \
		CPPFLAGS="-I$(buildprefix)/linux/arch/ppc" \
		CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
		./autogen.sh \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-debug \
			--enable-linux-input \
			--disable-sdl \
			--with-gfxdrivers=none && \
		$(MAKE) all && \
		@INSTALL_libdirectfb@
	@CLEANUP_libdirectfb@
	mv $(targetprefix)/lib/libdirectfb.la $(targetprefix)/lib/libdirectfb.la.old
	mv $(targetprefix)/lib/libfusion.la $(targetprefix)/lib/libfusion.la.old
	sed -e "s, /lib, $(targetprefix)/lib,g" < $(targetprefix)/lib/libdirectfb.la.old >$(targetprefix)/lib/libdirectfb.la
	sed -e "s, /lib, $(targetprefix)/lib,g" < $(targetprefix)/lib/libfusion.la.old >$(targetprefix)/lib/libfusion.la
	rm -f $(targetprefix)/lib/libdirectfb.la.old
	rm -f $(targetprefix)/lib/libfusion.la.old
	touch $@

$(DEPDIR)/libdirectfbpp: bootstrap libdirectfb @DEPENDS_libdirectfbpp@
	@PREPARE_libdirectfbpp@
	cd @DIR_libdirectfbpp@ && \
		$(BUILDENV) \
		./autogen.sh \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libdirectfbpp@
	@CLEANUP_libdirectfbpp@
	mv $(targetprefix)/lib/libdfb++.la $(targetprefix)/lib/libdfb++.la.old
	sed -e "s, /lib, $(targetprefix)/lib,g" < $(targetprefix)/lib/libdfb++.la.old >$(targetprefix)/lib/libdfb++.la
	rm -f $(targetprefix)/lib/libdfb++.la.old
	touch $@

$(DEPDIR)/libdvb: bootstrap @DEPENDS_libdvb@
	@PREPARE_libdvb@
	cd @DIR_libdvb@ && \
		$(MAKE) libdvb.a libdvbci.a libdvbmpegtools.a \
		$(BUILDENV) \
		CFLAGS="$(TARGET_CFLAGS) -I$(driverdir)/dvb/include -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" && \
		@INSTALL_libdvb@
	@CLEANUP_libdvb@
	touch $@

$(DEPDIR)/libdvbpsi: bootstrap @DEPENDS_libdvbpsi@
	@PREPARE_libdvbpsi@
	cd @DIR_libdvbpsi@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libdvbpsi@
	@CLEANUP_libdvbpsi@
	touch $@

$(DEPDIR)/libexpat: bootstrap @DEPENDS_libexpat@
	@PREPARE_libexpat@
	cd @DIR_libexpat@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libexpat@
	@CLEANUP_libexpat@
	touch $@

$(DEPDIR)/libffi: bootstrap @DEPENDS_libffi@
	@PREPARE_libffi@
	cd @DIR_libffi@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libffi@
	@CLEANUP_libffi@
	touch $@

$(DEPDIR)/libfreetype: bootstrap @DEPENDS_libfreetype@
	@PREPARE_libfreetype@
	cd @DIR_libfreetype@ && \
		$(BUILDENV) \
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
	touch $@

$(DEPDIR)/libfribidi: bootstrap @DEPENDS_libfribidi@
	@PREPARE_libfribidi@
	cd @DIR_libfribidi@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-memopt && \
		$(MAKE) all && \
		@INSTALL_libfribidi@
	@CLEANUP_libfribidi@
	touch $@

$(DEPDIR)/libgmp: bootstrap @DEPENDS_libgmp@
	@PREPARE_libgmp@
	cd @DIR_libgmp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libgmp@
	@CLEANUP_libgmp@
	touch $@

$(DEPDIR)/libid3tag: bootstrap libz @DEPENDS_libid3tag@
	@PREPARE_libid3tag@
	cd @DIR_libid3tag@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-shared=yes && \
		$(MAKE) all && \
		@INSTALL_libid3tag@
	@CLEANUP_libid3tag@
	touch $@

$(DEPDIR)/libjpeg: bootstrap @DEPENDS_libjpeg@
	@PREPARE_libjpeg@
	cd @DIR_libjpeg@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) libjpeg.so.6 && \
		@INSTALL_libjpeg@
	@CLEANUP_libjpeg@
	touch $@

$(DEPDIR)/libmad: bootstrap libz @DEPENDS_libmad@
	@PREPARE_libmad@
	cd @DIR_libmad@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-shared=yes \
			--enable-speed \
			--enable-fpm=ppc \
			--enable-sso && \
		$(MAKE) all && \
		@INSTALL_libmad@
	@CLEANUP_libmad@
	touch $@

$(DEPDIR)/libncurses: bootstrap @DEPENDS_libncurses@
	@PREPARE_libncurses@
	cd @DIR_libncurses@ && \
		$(BUILDENV) \
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
	touch $@

$(DEPDIR)/libpcap: bootstrap @DEPENDS_libpcap@
	@PREPARE_libpcap@
	cd @DIR_libpcap@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-pcap=linux && \
		$(MAKE) all && \
		@INSTALL_libpcap@
	@CLEANUP_libpcap@
	touch $@

$(DEPDIR)/libpng: bootstrap libz @DEPENDS_libpng@
	@PREPARE_libpng@
	cd @DIR_libpng@ && \
		$(MAKE) libpng.a libpng12.so libpng.pc libpng-config \
	 		$(BUILDENV) \
			CPPFLAGS="-DPNG_DEBUG=0" \
			prefix=$(targetprefix) && \
		@INSTALL_libpng@
	@CLEANUP_libpng@
	touch $@

$(DEPDIR)/libreadline: bootstrap @DEPENDS_libreadline@
	@PREPARE_libreadline@
	cd @DIR_libreadline@ && \
		autoconf && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libreadline@
	@CLEANUP_libreadline@
	touch $@

$(DEPDIR)/libsdl: bootstrap libdirectfb @DEPENDS_libsdl@
	@PREPARE_libsdl@
	cd @DIR_libsdl@ && \
		$(BUILDENV) \
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
	touch $@

$(DEPDIR)/libsigc: bootstrap @DEPENDS_libsigc@
	@PREPARE_libsigc@
	cd @DIR_libsigc@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-checks && \
		$(MAKE) all && \
		@INSTALL_libsigc@
	@CLEANUP_libsigc@
	touch $@

$(DEPDIR)/libvorbisidec: bootstrap @DEPENDS_libvorbisidec@
	@PREPARE_libvorbisidec@
	cd @DIR_libvorbisidec@ && \
		$(BUILDENV) \
		./autogen.sh \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) && \
		@INSTALL_libvorbisidec@
	@CLEANUP_libvorbisidec@
	touch $@

$(DEPDIR)/libxml2: bootstrap @DEPENDS_libxml2@
	@PREPARE_libxml2@
	cd @DIR_libxml2@ && \
		$(BUILDENV) \
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
		@INSTALL_libxml2@
	@CLEANUP_libxml2@
	touch $@

$(DEPDIR)/libz: bootstrap @DEPENDS_libz@
	@PREPARE_libz@
	cd @DIR_libz@ && \
		$(BUILDENV) \
		./configure \
			--prefix= \
			--shared && \
		$(MAKE) all && \
		@INSTALL_libz@
	@CLEANUP_libz@
	touch $@

$(DEPDIR)/libglib: bootstrap @DEPENDS_libglib@
	@PREPARE_libglib@
	cd @DIR_libglib@ && \
		$(BUILDENV) \
		aclocal && \
		libtoolize --force && \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) &&\
		$(MAKE) all && \
		@INSTALL_libglib@
	@CLEANUP_libglib@
	touch $@

#######################
#
#   contrib apps
#

contrib_apps: bzip2 console_data console_tools fbset lirc lsof ssh tcpdump

$(DEPDIR)/bzip2: bootstrap @DEPENDS_bzip2@
	@PREPARE_bzip2@
	cd @DIR_bzip2@ && \
	mv Makefile-libbz2_so Makefile && \
		CC=$(target)-gcc \
		$(MAKE) all && \
		@INSTALL_bzip2@
	@CLEANUP_bzip2@
	touch $@

$(DEPDIR)/console_data: bootstrap @DEPENDS_console_data@
	@PREPARE_console_data@
	cd @DIR_console_data@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-main_compressor=gzip && \
		@INSTALL_console_data@
	@CLEANUP_console_data@
	touch $@

$(DEPDIR)/console_tools: bootstrap console_data @DEPENDS_console_tools@
	@PREPARE_console_tools@
	cd @DIR_console_tools@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		@INSTALL_console_tools@
	@CLEANUP_console_tools@
	touch $@

$(DEPDIR)/directfb_examples: bootstrap libdirectfb @DEPENDS_directfb_examples@
	@PREPARE_directfb_examples@
	cd @DIR_directfb_examples@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_directfb_examples@
	@CLEANUP_directfb_examples@
	touch $@

$(DEPDIR)/fbset: bootstrap @DEPENDS_fbset@
	@PREPARE_fbset@
	cd @DIR_fbset@ && \
		$(MAKE) \
			$(BUILDENV) && \
		@INSTALL_fbset@
	@CLEANUP_fbset@
	touch $@

$(DEPDIR)/lirc: bootstrap @DEPENDS_lirc@
	@PREPARE_lirc@
	cd @DIR_lirc@ && \
		$(BUILDENV) \
		mknod=/bin/true \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-devdir=/dev \
			--with-driver=none \
			--with-kerneldir=$(buildprefix)/linux \
			--with-moduledir=$(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
			--without-x && \
		@INSTALL_lirc@
	@CLEANUP_lirc@
	touch $@

$(DEPDIR)/lsof: bootstrap @DEPENDS_lsof@
	@PREPARE_lsof@
	cd @DIR_lsof@ && \
	tar xvf @DIR_lsof@_src.tar && \
	cd @DIR_lsof@_src && \
	patch -p1 < ../../Patches/lsof.diff && \
		CROSS_COMPILE=$(target)- \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LSOF_VSTR=$(KERNELVERSION) \
		LINUX_CLIB="-DGLIBCV=202" \
		./Configure -n linux && \
		$(MAKE) all && \
		@INSTALL_lsof@
	@CLEANUP_lsof@
	touch $@

$(DEPDIR)/ssh: bootstrap libcrypto libz @DEPENDS_ssh@
	@PREPARE_ssh@
	cd @DIR_ssh@ && \
		$(BUILDENV) \
		autoconf && \
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
	touch $@

$(DEPDIR)/tcpdump: bootstrap libpcap @DEPENDS_tcpdump@
	@PREPARE_tcpdump@
	cd @DIR_tcpdump@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-smb \
			--disable-ipv6 \
			--without-crypto && \
		$(MAKE) all && \
		@INSTALL_tcpdump@
	@CLEANUP_tcpdump@
	touch $@

$(DEPDIR)/vdr: bootstrap @DEPENDS_vdr@
	@PREPARE_vdr@
	cd @DIR_vdr@ && \
		$(BUILDENV) \
		DVBDIR="$(driverdir)/dvb" \
		$(MAKE) all DRIVERDIR=$(driverdir) && \
		$(MAKE) plugins PREFIX=$(prefix) DRIVERDIR=$(driverdir) && \
		@INSTALL_vdr@
	@CLEANUP_vdr@
	touch $@


#######################
#
#   development tools
#

devel: gdb ltrace strace nano joe
devel_optional: gdb-remote insight

$(DEPDIR)/gdb: bootstrap libncurses @DEPENDS_gdb@
	@PREPARE_gdb@
	cd @DIR_gdb@ && \
		$(BUILDENV) \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--nfp \
			--disable-tui \
			--without-tui \
			--disable-sim \
			--without-sim \
			--without-expect \
			--disable-expect \
			--prefix= && \
		$(MAKE) all-gdb && \
		@INSTALL_gdb@
	@CLEANUP_gdb@
	touch $@

$(DEPDIR)/gdb-remote: @DEPENDS_gdb@
	@PREPARE_gdb@
	cd @DIR_gdb@ && \
		./configure \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) && \
		$(MAKE) all-gdb && \
		$(MAKE) install-gdb
	@CLEANUP_gdb@
	touch $@

$(DEPDIR)/insight: @DEPENDS_insight@
	@PREPARE_insight@
	cd @DIR_insight@ && \
		./configure \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) && \
		$(MAKE) all-gdb && \
		$(MAKE) install-gdb
	@CLEANUP_insight@
	touch $@

$(DEPDIR)/ltrace: bootstrap @DEPENDS_ltrace@
	@PREPARE_ltrace@
	cd @DIR_ltrace@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) clean all LD=$(target)-ld && \
		@INSTALL_ltrace@
	@CLEANUP_ltrace@
	touch $@

$(DEPDIR)/strace: bootstrap @DEPENDS_strace@
	@PREPARE_strace@
	cd @DIR_strace@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_strace@
	@CLEANUP_strace@
	touch $@

$(DEPDIR)/nano: bootstrap libncurses @DEPENDS_nano@
	@PREPARE_nano@
	cd @DIR_nano@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=  \
			--includedir=$(targetprefix)/include && \
		$(MAKE) all && \
		@INSTALL_nano@
	@CLEANUP_nano@
	touch $@

$(DEPDIR)/joe: bootstrap libncurses @DEPENDS_joe@ 
	@PREPARE_joe@
	cd @DIR_joe@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=  \
			--includedir=$(targetprefix)/include && \
		$(MAKE) all && \
		@INSTALL_joe@
	@CLEANUP_joe@
	touch $@

$(DEPDIR)/mc: bootstrap libglib libncurses @DEPENDS_mc@
	@PREPARE_mc@
	cd @DIR_mc@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--without-gpm-mouse \
			--with-screen=ncurses \
			--without-x && \
		$(MAKE) all && \
		@INSTALL_mc@
	@CLEANUP_mc@
	touch $@


#######################
#
# java stuff
#

java: kaffeh kaffe

# for x86
$(DEPDIR)/kaffeh: bootstrap @DEPENDS_kaffeh@
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
	touch $@

# for ppc
$(DEPDIR)/kaffe: bootstrap kaffeh libffi @DEPENDS_kaffe@
	@PREPARE_kaffe@
	cd @DIR_kaffe@ && \
		$(BUILDENV) \
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
	touch $@

#######################
#
#   fun stuff
#

fun: gnuboy scummvm sdldoom

$(DEPDIR)/gnuboy: bootstrap @DEPENDS_gnuboy@
	@PREPARE_gnuboy@
	cd @DIR_gnuboy@ && \
		autoconf && \
		$(BUILDENV) \
		CPPFLAGS="-I$(driverdir)/include" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_gnuboy@
	@CLEANUP_gnuboy@
	touch $@

$(DEPDIR)/scummvm: bootstrap libreadline libsdl @DEPENDS_scummvm@
	@PREPARE_scummvm@
	cd @DIR_scummvm@ && \
		$(MAKE) \
			$(BUILDENV) \
			AR='$(target)-ar cru' \
			DEFINES="-DUNIX" && \
		@INSTALL_scummvm@
	@CLEANUP_scummvm@
	touch $@

$(DEPDIR)/sdldoom: bootstrap libsdl @DEPENDS_sdldoom@
	@PREPARE_sdldoom@
	cd @DIR_sdldoom@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_sdldoom@
	@CLEANUP_sdldoom@
	touch $@

#######################
#
#  DVB apps
#

dvb_apps: dvbdate dvbstream dvbtext dvbtune vls

$(DEPDIR)/dvbdate: bootstrap @DEPENDS_dvbdate@
	@PREPARE_dvbdate@
	cd @DIR_dvbdate@ && \
		$(MAKE) dvbdate \
			$(BUILDENV) \
			CPPFLAGS="-I$(driverdir)/dvb/include -DNEWSTRUCT" && \
		@INSTALL_dvbdate@
	@CLEANUP_dvbdate@
	touch $@

$(DEPDIR)/dvbstream: bootstrap @DEPENDS_dvbstream@
	@PREPARE_dvbstream@
	cd @DIR_dvbstream@ && \
		$(MAKE) dvbstream rtpfeed\
			INCS="-I$(driverdir)/dvb/include -DNEWSTRUCT" \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" && \
		@INSTALL_dvbstream@
	@CLEANUP_dvbstream@
	touch $@

$(DEPDIR)/dvbtext: bootstrap @DEPENDS_dvbtext@
	@PREPARE_dvbtext@
	cd @DIR_dvbtext@ && \
		$(target)-gcc $(TARGET_CFLAGS) -I$(driverdir)/dvb/include -DNEWSTRUCT -o dvbtext dvbtext.c && \
		@INSTALL_dvbtext@
	@CLEANUP_dvbtext@
	touch $@

$(DEPDIR)/dvbtune: bootstrap @DEPENDS_dvbtune@
	@PREPARE_dvbtune@
	cd @DIR_dvbtune@ && \
		$(MAKE) \
			$(BUILDENV) \
			CPPFLAGS="-I$(driverdir)/dvb/include -DNEWSTRUCT" && \
		@INSTALL_dvbtune@
	@CLEANUP_dvbtune@
	touch $@

$(DEPDIR)/vls: bootstrap libdvbpsi @DEPENDS_vls@
	@PREPARE_vls@
	cd @DIR_vls@ && \
		$(BUILDENV) \
		CCFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-dvd \
			--with-dvb=$(driverdir)/dvb/include && \
		$(MAKE) all && \
		@INSTALL_vls@
	@CLEANUP_vls@
	touch $@

#######################
#
# bluetooth
#

$(DEPDIR)/bluez_hcidump: bootstrap bluez_libs @DEPENDS_bluez_hcidump@
	@PREPARE_bluez_hcidump@
	cd @DIR_bluez_hcidump@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--with-bluez-libs=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_bluez_hcidump@
	@CLEANUP_bluez_hcidump@
	touch $@

$(DEPDIR)/bluez_libs: bootstrap @DEPENDS_bluez_libs@
	@PREPARE_bluez_libs@
	cd @DIR_bluez_libs@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_bluez_libs@
	@CLEANUP_bluez_libs@
	touch $@

$(DEPDIR)/bluez_pan: bootstrap bluez_sdp @DEPENDS_bluez_pan@
	@PREPARE_bluez_pan@
	cd @DIR_bluez_pan@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-bluez-includes=$(targetprefix)/include \
			--with-bluez-libs=$(targetprefix)/lib \
			--with-sdp-includes=$(targetprefix)/include \
			--with-sdp-libs=$(targetprefix)/lib && \
		$(MAKE) all && \
		@INSTALL_bluez_pan@
	@CLEANUP_bluez_pan@
	touch $@

$(DEPDIR)/bluez_sdp: bootstrap bluez_libs @DEPENDS_bluez_sdp@
	@PREPARE_bluez_sdp@
	cd @DIR_bluez_sdp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-bluez-includes=$(targetprefix)/include \
			--with-bluez-libs=$(targetprefix)/lib && \
		$(MAKE) all && \
		@INSTALL_bluez_sdp@
	@CLEANUP_bluez_sdp@
	touch $@

$(DEPDIR)/bluez_utils: bootstrap bluez_libs @DEPENDS_bluez_utils@
	@PREPARE_bluez_utils@
	cd @DIR_bluez_utils@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-bluez-includes=$(targetprefix)/include \
			--with-bluez-libs=$(targetprefix)/lib && \
		$(MAKE) all && \
		@INSTALL_bluez_utils@
	@CLEANUP_bluez_utils@
	touch $@

#######################
#
#   own kernel and driver
#

boot: u-boot linuxkernel driver

$(DEPDIR)/u-boot: bootstrap @DEPENDS_uboot@
	@PREPARE_uboot@
	@if [ ! -e $(bootdir)/u-boot-config/u-boot.config ]; then \
	    ln -s ./u-boot.cdk.dbox2.h $(bootdir)/u-boot-config/u-boot.config; \
	fi

	cp -pR $(bootdir)/u-boot-tuxbox/* @DIR_uboot@
	cp -p $(bootdir)/u-boot-config/u-boot.config @DIR_uboot@/include/configs/dbox2.h

	$(MAKE) -C @DIR_uboot@ dbox2_config
	$(MAKE) -C @DIR_uboot@ CROSS_COMPILE=$(target)- u-boot.stripped

	$(INSTALL) -m644 @DIR_uboot@/u-boot.stripped $(bootprefix)/u-boot
	$(INSTALL) @DIR_uboot@/tools/mkimage $(hostprefix)/bin

	@CLEANUP_uboot@
	touch $@

$(DEPDIR)/linuxkernel: bootstrap linuxdir u-boot
	$(MAKE) -C @DIR_linux@ zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C @DIR_linux@ modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 \
		-d @DIR_linux@/arch/ppc/boot/images/vmlinux.gz \
		$(bootprefix)/kernel-cdk
	chmod 644 $(bootprefix)/kernel-cdk
	$(INSTALL) -m644 @DIR_linux@/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
	$(INSTALL) -m644 @DIR_linux@/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)

if MAINTAINER_MODE
else
	$(MAKE) -C @DIR_linux@ clean
endif
	touch $@

$(DEPDIR)/driver: bootstrap linuxkernel
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix) \
		install

if MAINTAINER_MODE
else
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		distclean
endif
	touch $@

driver-clean:
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		distclean
	-rm $(DEPDIR)/driver

$(driverdir)/directfb/Makefile: bootstrap libdirectfb
	cd $(driverdir)/directfb && \
	$(BUILDENV) \
	./autogen.sh \
		--build=$(build) \
		--host=$(target) \
		--prefix= \
		--enable-maintainer-mode \
		--with-kernel-source=$(buildprefix)/linux

$(DEPDIR)/directfb_gtx: $(driverdir)/directfb/Makefile
	$(MAKE) -C $(driverdir)/directfb all install DESTDIR=$(targetprefix)
	touch $@

#######################
#
#   own applications
#

apps: dvbsnoop enigma lcars lcd neutrino plugins dvb_tools

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

# dvb/config

$(appsdir)/dvb/config/config.status:
	cd $(appsdir)/dvb/config && $(CONFIGURE)

$(DEPDIR)/config: $(appsdir)/dvb/config/config.status
	$(MAKE) -C $(appsdir)/dvb/config all install
	touch $@

# dvb/dvbsnoop

$(appsdir)/dvb/dvbsnoop/config.status: bootstrap
	cd $(appsdir)/dvb/dvbsnoop && $(CONFIGURE) CPPFLAGS="$(CPPFLAGS) -I$(driverdir)/dvb/include"

$(DEPDIR)/dvbsnoop: $(appsdir)/dvb/dvbsnoop/config.status
	$(MAKE) -C $(appsdir)/dvb/dvbsnoop all install
	touch $@

# dvb/libdvb++

$(appsdir)/dvb/libdvb++/config.status: bootstrap libdvbsi++
	cd $(appsdir)/dvb/libdvb++ && $(CONFIGURE) CPPFLAGS="$(CPPFLAGS) -I$(driverdir)/dvb/include"

$(DEPDIR)/libdvb++: $(appsdir)/dvb/libdvb++/config.status
	$(MAKE) -C $(appsdir)/dvb/libdvb++ all install
	touch $@

# dvb/libdvbsi++

$(appsdir)/dvb/libdvbsi++/config.status: bootstrap
	cd $(appsdir)/dvb/libdvbsi++ && $(CONFIGURE) CPPFLAGS="$(CPPFLAGS) -I$(driverdir)/dvb/include"

$(DEPDIR)/libdvbsi++: $(appsdir)/dvb/libdvbsi++/config.status
	$(MAKE) -C $(appsdir)/dvb/libdvbsi++ all install
	touch $@

# dvb/zapit

$(appsdir)/dvb/zapit/config.status: bootstrap misc_libs
	cd $(appsdir)/dvb/zapit && $(CONFIGURE)

$(DEPDIR)/zapit: $(appsdir)/dvb/zapit/config.status config
	$(MAKE) -C $(appsdir)/dvb/zapit all install
	touch $@

# dvb/tools

$(appsdir)/dvb/tools/config.status: bootstrap misc_libs
	cd $(appsdir)/dvb/tools && $(CONFIGURE)

$(DEPDIR)/dvb_tools: $(appsdir)/dvb/tools/config.status
	$(MAKE) -C $(appsdir)/dvb/tools all install
	touch $@

# misc/libs

$(appsdir)/misc/libs/config.status: bootstrap libz
	cd $(appsdir)/misc/libs && $(CONFIGURE)

$(DEPDIR)/misc_libs: $(appsdir)/misc/libs/config.status
	$(MAKE) -C $(appsdir)/misc/libs all install
	touch $@

# misc/tools

$(appsdir)/misc/tools/config.status: bootstrap
	cd $(appsdir)/misc/tools && $(CONFIGURE)

$(DEPDIR)/misc_tools: $(appsdir)/misc/tools/config.status
	$(MAKE) -C $(appsdir)/misc/tools all install
	touch $@

# tuxbox/enigma

$(appsdir)/tuxbox/enigma/config.status: bootstrap libfreetype libfribidi libmad libid3tag libpng libsigc libtuxbox misc_libs plugins
	cd $(appsdir)/tuxbox/enigma && $(CONFIGURE)

$(DEPDIR)/enigma: $(appsdir)/tuxbox/enigma/config.status tuxbox_tools config
	$(MAKE) -C $(appsdir)/tuxbox/enigma all install
	touch $@

# tuxbox/funstuff

$(appsdir)/tuxbox/funstuff/config.status: bootstrap
	cd $(appsdir)/tuxbox/funstuff && $(CONFIGURE)

$(DEPDIR)/funstuff: $(appsdir)/tuxbox/funstuff/config.status
	$(MAKE) -C $(appsdir)/tuxbox/funstuff all install
	touch $@

# tuxbox/lcars

$(appsdir)/tuxbox/lcars/config.status: bootstrap libcurl libfreetype plugins libcommoncplusplus
	cd $(appsdir)/tuxbox/lcars && $(CONFIGURE)

$(DEPDIR)/lcars: $(appsdir)/tuxbox/lcars/config.status
	$(MAKE) -C $(appsdir)/tuxbox/lcars all install
	touch $@

# tuxbox/lcd

$(appsdir)/tuxbox/lcd/config.status: bootstrap libfreetype misc_libs tuxbox_libs
	cd $(appsdir)/tuxbox/lcd && $(CONFIGURE)

$(DEPDIR)/lcd: $(appsdir)/tuxbox/lcd/config.status
	$(MAKE) -C $(appsdir)/tuxbox/lcd all install
	touch $@

# tuxbox/libs

$(appsdir)/tuxbox/libs/config.status: bootstrap libfreetype libpng
	cd $(appsdir)/tuxbox/libs && $(CONFIGURE)

$(DEPDIR)/tuxbox_libs: $(appsdir)/tuxbox/libs/config.status
	$(MAKE) -C $(appsdir)/tuxbox/libs all install
	touch $@

# tuxbox/libtuxbox

$(appsdir)/tuxbox/libtuxbox/config.status: bootstrap
	cd $(appsdir)/tuxbox/libtuxbox && $(CONFIGURE)

$(DEPDIR)/libtuxbox: $(appsdir)/tuxbox/libtuxbox/config.status
	$(MAKE) -C $(appsdir)/tuxbox/libtuxbox all install
	touch $@

# tuxbox/neutrino

$(appsdir)/tuxbox/neutrino/config.status: bootstrap libboost libcurl libfreetype libjpeg libmad libid3tag libvorbisidec libpng libtuxbox misc_libs plugins tuxbox_libs zapit misc_tools
	cd $(appsdir)/tuxbox/neutrino && $(CONFIGURE)

$(DEPDIR)/neutrino: $(appsdir)/tuxbox/neutrino/config.status
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install
	touch $@

# tuxbox/plugins

$(appsdir)/tuxbox/plugins/config.status: bootstrap libcurl libfreetype libz misc_libs libsigc libpng libtuxbox
	cd $(appsdir)/tuxbox/plugins && $(CONFIGURE)

$(DEPDIR)/plugins: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins all install
	touch $@

# tuxbox/tools

$(appsdir)/tuxbox/tools/config.status: bootstrap plugins libtuxbox
	cd $(appsdir)/tuxbox/tools && $(CONFIGURE)

$(DEPDIR)/tuxbox_tools: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools all install
	touch $@

$(hostappsdir)/config.status: bootstrap
	cd $(hostappsdir) && $(CONFIGURE)

$(DEPDIR)/hostapps_cross: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)
	touch $@

#######################
#
#   flash
#

# TODO: fix the flash-* for the apps... they don't work anymore
if TARGETRULESET_FLASH
flash-all: flash-neutrino flash-enigma flash-lcars flash-lcdmenu flash-plugins flash-ftpd flash-ssh flash-sshd flash-lib

flash-ssl: flash-ssh flash-sshd flash-lib

flash-enigma-all: flash-enigma flash-lcdmenu flash-plugins flash-ftpd flash-lib

flash-neutrino-all: flash-neutrino flash-lcdmenu flash-plugins flash-ftpd flash-dvb-tools flash-lib

flash-lcars-all: flash-lcars flash-lcdmenu flash-plugins flash-ftpd flash-lib

rebuild-flash:
	-rm -rf $(flashprefix)/root
	-rm -f $(flashprefix)/.flash
	$(MAKE) flash-lib

$(flashprefix)/.flash: procps busybox driver tuxbox_tools lirc
	if [ -d $(flashprefix)/root ]; then \
		echo "directory $(flashprefix)/root already exists. please remove manually." && false; \
	fi
	$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) -d $(flashprefix)/root/dev
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox
	$(INSTALL) -d $(flashprefix)/root/mnt
	$(INSTALL) -d $(flashprefix)/root/proc
	$(INSTALL) -d $(flashprefix)/root/sbin
	$(INSTALL) -d $(flashprefix)/root/share/tuxbox
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/ucodes
	$(INSTALL) -d $(flashprefix)/root/tmp
	$(MAKE) -C root install targetprefix=$(flashprefix)/root
	cp -pa $(bootprefix)/kernel-cdk $(flashprefix)/root/vmlinuz
	echo "version=0200`date +%Y%m%d%H%M`" > $(flashprefix)/root/.version
	echo "comment=Erstellt von `id -un`" >> $(flashprefix)/root/.version
	$(INSTALL) $(targetprefix)/bin/busybox $(flashprefix)/root/bin
	for i in `find $(targetprefix)/bin/ -lname "*busybox"` ; do cp -ap $$i $(flashprefix)/root/bin/ ; done
	for i in `find $(targetprefix)/sbin/ -lname "*busybox"` ; do cp -pa $$i $(flashprefix)/root/sbin/ ; done
	$(INSTALL) $(targetprefix)/bin/switch $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/tuxinfo $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/sbin/lircd $(flashprefix)/root/sbin
	if [ -e $(targetprefix)/bin/eraseall ] ; then \
		$(INSTALL) $(targetprefix)/bin/eraseall $(flashprefix)/root/bin ; \
	fi
	rm -f $(flashprefix)/root/etc/init.d/start_*
	$(INSTALL) -d $(flashprefix)/root/lib/modules/$(KERNELVERSION)
	cp -ap $(targetprefix)/lib/modules/$(KERNELVERSION)/kernel $(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
		$(flashprefix)/root/lib/modules/$(KERNELVERSION)
	ln -s /tmp $(flashprefix)/root/var/run
	ln -s /var $(flashprefix)/root/root
	@touch $@

flash-ftpd: $(flashprefix)/.part_ftpd

$(flashprefix)/.part_ftpd: $(flashprefix)/.flash 
	$(INSTALL) -d $(flashprefix)/root/share/empty
	$(INSTALL) $(targetprefix)/etc/vsftpd.conf $(flashprefix)/root/etc
	$(INSTALL) $(targetprefix)/sbin/in.ftpd $(flashprefix)/root/sbin
	@touch $@

flash-telnetd: $(flashprefix)/.part_telnetd

$(flashprefix)/.part_telnetd: $(flashprefix)/.flash
	$(INSTALL) $(targetprefix)/sbin/telnetd $(flashprefix)/root/sbin
	@touch $@

flash-ssh: $(flashprefix)/.part_ssh

$(flashprefix)/.part_ssh: $(flashprefix)/.flash ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh $(targetprefix)/bin/scp \
		$(targetprefix)/bin/sftp $(flashprefix)/root/bin
	cp -ap $(targetprefix)/etc/ssh/ssh_config $(flashprefix)/root/etc/ssh
	@touch $@

flash-sshd: $(flashprefix)/.part_sshd

$(flashprefix)/.part_sshd: $(flashprefix)/.flash ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) -d $(flashprefix)/root/libexec
	$(INSTALL) -d $(flashprefix)/root/share/empty
	$(INSTALL) $(targetprefix)/bin/ssh-keygen $(targetprefix)/bin/scp \
		$(flashprefix)/root/bin
	cp -ap $(targetprefix)/etc/ssh/* $(flashprefix)/root/etc/ssh
	cp -ap $(targetprefix)/etc/init.d/start_sshd $(flashprefix)/root/etc/init.d/
	$(INSTALL) $(targetprefix)/libexec/sftp-server $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/sbin/sshd $(flashprefix)/root/sbin
	@touch $@

flash-dvb-tools: $(flashprefix)/.part_dvb_tools

$(flashprefix)/.part_dvb_tools: $(flashprefix)/.flash dvb_tools
	$(INSTALL) $(targetprefix)/sbin/streampes $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/streamsec $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/streamts $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/udpstreampes $(flashprefix)/root/sbin
	@touch $@

flash-neutrino: $(flashprefix)/.part_neutrino

$(flashprefix)/.part_neutrino: $(flashprefix)/.flash neutrino root
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	$(INSTALL) -d $(flashprefix)/root/share/iso-codes
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config/lirc
	$(INSTALL) $(targetprefix)/bin/controld $(targetprefix)/bin/neutrino \
		$(targetprefix)/bin/nhttpd $(targetprefix)/bin/timerd \
		$(flashprefix)/root/bin
	cp -pa $(targetprefix)/share/tuxbox/neutrino $(targetprefix)/share/tuxbox/lcdd \
		$(flashprefix)/root/share/tuxbox
	$(INSTALL) $(targetprefix)/bin/camd2 $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/sectionsd $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/pzapit $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/satfind $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/zapit $(flashprefix)/root/bin
	sed -e 's/neutrino/neutrino -u -f/' $(targetprefix)/etc/init.d/start_neutrino > \
		$(flashprefix)/root/etc/init.d/start_neutrino ;
	chmod 755 $(flashprefix)/root/etc/init.d/start_neutrino ;
	cp -pa $(targetprefix)/share/fonts/micron*.ttf $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/share/fonts/12.pcf.gz $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/share/fonts/14B.pcf.gz $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/share/fonts/15B.pcf.gz $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/share/iso-codes/iso-639.tab $(flashprefix)/root/share/iso-codes
	cp -pa $(targetprefix)/var/tuxbox/config/zapit $(flashprefix)/root/var/tuxbox/config
	@touch $@

flash-enigma: $(flashprefix)/.part_enigma

$(flashprefix)/.part_enigma: $(flashprefix)/.flash enigma root
	$(INSTALL) $(targetprefix)/bin/enigma $(flashprefix)/root/bin
	cp -pa $(targetprefix)/share/tuxbox/enigma $(flashprefix)/root/share/tuxbox
	$(INSTALL) $(targetprefix)/bin/camd2 $(flashprefix)/root/bin
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/share/fonts/blue*.ttf $(targetprefix)/share/fonts/unmrs.pfa \
		$(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/share/fonts/md_khmurabi_10.ttf $(flashprefix)/root/share/fonts 
	cp -pa $(targetprefix)/etc/init.d/start_enigma $(flashprefix)/root/etc/init.d
	$(INSTALL) $(targetprefix)/etc/timezone.xml $(flashprefix)/root/etc
	cp -pa $(targetprefix)/share/zoneinfo $(flashprefix)/root/share
	ln -sf /var/etc/localtime $(flashprefix)/root/etc 
	@touch $@

flash-lcars: $(flashprefix)/.part_lcars

$(flashprefix)/.part_lcars: $(flashprefix)/.flash lcars
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	$(INSTALL) $(targetprefix)/bin/lcars $(flashprefix)/root/bin
	cp -pa $(targetprefix)/etc/init.d/start_lcars $(flashprefix)/root/etc/init.d/
	cp -pa $(targetprefix)/share/fonts/ds9.ttf $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/var/tuxbox/config/lcars $(flashprefix)/root/var/tuxbox/config
	@touch $@

flash-plugins: $(flashprefix)/.part_plugins

$(flashprefix)/.part_plugins: $(flashprefix)/.flash plugins
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config/tuxtxt
	$(INSTALL) $(targetprefix)/bin/tuxmaild $(flashprefix)/root/bin
	cp -pa $(targetprefix)/lib/tuxbox/plugins/*.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	cp -pa $(targetprefix)/lib/tuxbox/plugins/*.so $(flashprefix)/root/lib/tuxbox/plugins/
	cp -pa $(targetprefix)/share/fonts/tuxtxt.ttf $(flashprefix)/root/share/fonts/
	cp -pa $(targetprefix)/var/tuxbox/config/games.cfg $(flashprefix)/root/var/tuxbox/config/
	cp -pa $(targetprefix)/var/tuxbox/config/tuxtxt/tuxtxt.conf $(flashprefix)/root/var/tuxbox/config/tuxtxt/
	cp -pa $(targetprefix)/share/tuxbox/sokoban $(flashprefix)/root/share/tuxbox/
	@touch $@

flash-lcdmenu: $(flashprefix)/.part_lcdmenu

$(flashprefix)/.part_lcdmenu: $(flashprefix)/.flash lcd
	$(INSTALL) $(targetprefix)/bin/lcdmenu $(flashprefix)/root/bin
	cp -pa $(targetprefix)/var/tuxbox/config/lcdmenu.conf $(flashprefix)/root/var/tuxbox/config
	@touch $@

flash-lib: $(flashprefix)/.lib

$(flashprefix)/.lib: $(flashprefix)/.flash $(shell ls -1 $(flashprefix)/.part_* 2>/dev/null)
	find $(flashprefix)/root/lib -maxdepth 1 -type f -o -type l | xargs rm -f
	cp -pa $(targetprefix)/lib/libnss_dns-?.*.so $(flashprefix)/root/lib
	cp -pa $(targetprefix)/lib/libnss_files-?.*.so $(flashprefix)/root/lib
	$(MKLIBS) --target $(target) --ldlib ld.so.1 --libc-extras-dir $(targetprefix)/lib/libc_pic \
		-d $(flashprefix)/root/lib \
		-D -L $(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins \
		--root $(flashprefix)/root \
		`find $(flashprefix)/root/bin/ -path "*bin/?*"` \
		`find $(flashprefix)/root/lib/ -name "libnss_*"` \
		`find $(flashprefix)/root/lib/tuxbox/ -name "*.so" -type f` \
		`find $(flashprefix)/root/sbin/ -path "*sbin/?*"`
	$(target)-strip --remove-section=.comment --remove-section=.note \
		`find $(flashprefix)/root/bin/ -path "*bin/?*"` \
		`find $(flashprefix)/root/sbin/ -path "*sbin/?*"` 2>/dev/null || /bin/true
	$(target)-strip --remove-section=.comment --remove-section=.note --strip-unneeded \
		`find $(flashprefix)/root/lib/tuxbox -name "*.so"` 2>/dev/null || /bin/true
	$(target)-strip $(flashprefix)/root/lib/* 2>/dev/null || /bin/true
	chmod u+rwX,go+rX -R $(flashprefix)/root/
	if [ -e $(flashprefix)/root/lib/libfx2.so ]; then \
	if [ -e $(flashprefix)/root/lib/tuxbox/plugins/ ]; then \
	rm -f $(flashprefix)/root/lib/tuxbox/plugins/libfx2.so ; \
	ln -s /lib/libfx2.so $(flashprefix)/root/lib/tuxbox/plugins/libfx2.so ; \
	fi ; \
	fi
	@touch $@

flash-cramfs: $(flashprefix)/root-cramfs.img

flash-var-jffs2: $(flashprefix)/var-jffs2.img

flash-root-jffs2: $(flashprefix)/root-jffs2.img

flash-cramfsimage: $(flashprefix)/cramfsjffs2.img

flash-jffs2image: $(flashprefix)/jffs2only.img

$(flashprefix)/root-cramfs.img: $(flashprefix)/.lib
	rm -fr $(flashprefix)/cramfs
	cp -pa $(flashprefix)/root $(flashprefix)/cramfs
	rm -fr $(flashprefix)/cramfs/boot
	rm -fr $(flashprefix)/cramfs/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $(flashprefix)/cramfs/etc/fstab
	$(INSTALL) -d $(flashprefix)/jffs2/etc/init.d
	for i in `find $(flashprefix)/cramfs/etc/init.d/ -name "start*"` ; do \
		rm $$i ; ln -sf ../../var/etc/init.d/`basename $$i` $$i ; \
	done
	rm -f $(flashprefix)/cramfs/etc/resolv.conf
	ln -sf ../var/etc/resolv.conf $(flashprefix)/cramfs/etc/resolv.conf
	if [ -d $(flashprefix)/cramfs/etc/network ] ; then \
		rm -fr $(flashprefix)/cramfs/etc/network ; \
		ln -sf ../var/etc/network $(flashprefix)/cramfs/etc/network ; \
	fi
	if [ -d $(flashprefix)/cramfs/etc/ssh ] ; then \
		rm -fr $(flashprefix)/cramfs/etc/ssh ; \
		ln -sf ../var/etc/ssh $(flashprefix)/cramfs/etc/ssh ; \
	fi
	$(FAKEROOT) $(MKCRAMFS) -p -n "0106`date +%Y%m%d%H%M`" $(flashprefix)/cramfs/ $(flashprefix)/root-cramfs.img
	rm -fr $(flashprefix)/cramfs

$(flashprefix)/var-jffs2.img: $(flashprefix)/.lib
	rm -rf $(flashprefix)/jffs2
	cp -pa $(flashprefix)/root/var $(flashprefix)/jffs2
	rm -f $(flashprefix)/jffs2/tuxbox/boot
	cp -pa $(flashprefix)/root/boot $(flashprefix)/jffs2/tuxbox/boot
	$(INSTALL) -d $(flashprefix)/jffs2/etc/init.d
	for i in `find $(flashprefix)/root/etc/init.d/ -name "start*"` ; do \
		cp -pa $$i $(flashprefix)/jffs2/etc/init.d/ ; \
	done
	cp -pa $(flashprefix)/root/etc/resolv.conf $(flashprefix)/jffs2/etc/resolv.conf
	if [ -d $(flashprefix)/root/etc/network ] ; then \
		cp -pa $(flashprefix)/root/etc/network $(flashprefix)/jffs2/etc/network ; \
	fi
	if [ -d $(flashprefix)/root/etc/ssh ] ; then \
		cp -pa $(flashprefix)/root/etc/ssh $(flashprefix)/jffs2/etc/ssh ; \
	fi
	$(FAKEROOT) $(MKJFFS2) -b -e 131072 -p -r $(flashprefix)/jffs2/ -o $(flashprefix)/var-jffs2.img
	rm -rf $(flashprefix)/jffs2

$(flashprefix)/cramfsjffs2.img: $(flashprefix)/root-cramfs.img $(flashprefix)/var-jffs2.img $(flashprefix)/cramfs-flfs.img
	$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/cramfsjffs2.img -o build \
		--part ppcboot=$(flashprefix)/cramfs-flfs.img \
		--part root=$(flashprefix)/root-cramfs.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/root-jffs2.img: $(flashprefix)/.lib
	$(FAKEROOT) $(MKJFFS2) -b -e 0x20000 --pad=0x7c0000 -r $(flashprefix)/root/ -o $(flashprefix)/root-jffs2.img

$(flashprefix)/jffs2only.img: $(flashprefix)/.lib $(flashprefix)/jffs2-flfs.img
	$(FAKEROOT) $(MKJFFS2) -b -e 0x20000 --pad=0x7c0000 -r $(flashprefix)/root/ -o $(flashprefix)/root-jffs2.tmp
	cat $(flashprefix)/jffs2-flfs.img > $(flashprefix)/jffs2only.img
	cat $(flashprefix)/root-jffs2.tmp >> $(flashprefix)/jffs2only.img
	rm -f  $(flashprefix)/root-jffs2.tmp
endif

#######################
#
#   internal
#

clean-local:
	-$(MAKE) -C etc clean
	-$(MAKE) -C $(appsdir) clean
	-$(MAKE) -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
	-rm -f linux
	-rm -rf build
	-@CLEANUP@

distclean-local:
	-$(MAKE) -C root distclean
	-$(MAKE) -C $(appsdir) distclean
	-$(MAKE) -C $(appsdir)/dvb/configtools distclean
	-$(MAKE) -C $(appsdir)/dvb/dvbsnoop distclean
	-$(MAKE) -C $(appsdir)/dvb/dvb/libdvb++ distclean
	-$(MAKE) -C $(appsdir)/dvb/dvb/libdvbsi++ distclean
	-$(MAKE) -C $(appsdir)/dvb/tools distclean
	-$(MAKE) -C $(appsdir)/dvb/zapit distclean
	-$(MAKE) -C $(appsdir)/misc/libs distclean
	-$(MAKE) -C $(appsdir)/misc/tools distclean
	-$(MAKE) -C $(appsdir)/tuxbox/enigma distclean
	-$(MAKE) -C $(appsdir)/tuxbox/funstuff distclean
	-$(MAKE) -C $(appsdir)/tuxbox/lcars distclean
	-$(MAKE) -C $(appsdir)/tuxbox/lcd distclean
	-$(MAKE) -C $(appsdir)/tuxbox/libs distclean
	-$(MAKE) -C $(appsdir)/tuxbox/libtuxbox distclean
	-$(MAKE) -C $(appsdir)/tuxbox/neutrino distclean
	-$(MAKE) -C $(appsdir)/tuxbox/tools distclean
	-$(MAKE) -C $(driverdir) distclean KERNEL_LOCATION=$(buildprefix)/linux
	-rm Makefile-archive
	-rm rules-downcheck.pl
	-rm $(DEPDIR) -rf
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
	rules.pl rules-archive.pl rules-downcheck.pl.in \
	rules-archive \
	rules-install rules-install-flash \
	rules-make rules-make-cygwin

ACLOCAL_AMFLAGS = -I .

CONFIG_STATUS_DEPENDENCIES = \
	$(top_srcdir)/rules.pl \
	$(top_srcdir)/rules-install $(top_srcdir)/rules-install-flash \
	$(top_srcdir)/rules-make $(top_srcdir)/rules-make-cygwin \
	Makefile-archive

-include ./Makefile.am.local
