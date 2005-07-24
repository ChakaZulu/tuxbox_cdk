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
	-ln -s $(buildprefix)/linux/include/asm-generic $(hostprefix)/$(target)/include
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
	@if [ ! -d maps ]; then \
		mkdir maps; \
	fi
	cp linux/drivers/mtd/maps/dbox2-flash.c maps
else
	cat Patches/linux-$(KERNELVERSION).config > @DIR_linux@/.config
endif
	$(MAKE) -C @DIR_linux@ oldconfig \
		ARCH=ppc
	$(MAKE) -C @DIR_linux@ include/linux/version.h \
		ARCH=ppc
	@if [ -e $(buildprefix)/linux/include/mtd ]; then \
	    ln -sf $(buildprefix)/linux/include/mtd $(hostprefix)/$(target)/include; \
	fi
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
	$(OPTIONAL_LIBCRYPTO) libcurl libdirectfb libdirectfbpp libppdirectfb libdvbpsi \
	libfreetype libjpeg libmad libid3tag libncurses libpng \
	libreadline libsdl libsigc libz libdvb

libs_optional: \
	libcommoncplusplus libffi \
	libpcap libxml2 libungif

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
	sed -e "s,^prefix=,prefix=$(targetprefix)," < @DIR_libcrypto@/openssl.pc > $(targetprefix)/lib/pkgconfig/openssl.pc && \
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

# directfb needs working directfb-csource for building tools - but only creates it for the target
#$(DEPDIR)/libdirectfb_hostdeps: bootstrap
#	@PREPARE_libdirectfb@
#	cd @DIR_libdirectfb@ && \
#	    ./autogen.sh \
#		--disable-fbdev \
#		--disable-sysfs \
#		--disable-video4linux \
#		--prefix=$(hostprefix) && \
#	    $(MAKE) -C tools directfb-csource && \
#	    $(INSTALL) -m 755 tools/directfb-csource $(hostprefix)/bin && \
#	    $(MAKE) -C tools clean
#	touch $@
#	
#	@if [ ! -e $(buildprefix)/@DIR_libdirectfb@/configure ]; then \
#	    @PREPARE_libdirectfb@ && \
#	    cd @DIR_libdirectfb@ && ./autogen.sh ; \
#	fi

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
			--with-inputdrivers=linuxinput \
			--disable-sdl \
			--disable-multi \
			--without-tools \
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

$(DEPDIR)/libppdirectfb: bootstrap libdirectfb @DEPENDS_libppdirectfb@
	@PREPARE_libppdirectfb@
	cd @DIR_libppdirectfb@ && \
		$(BUILDENV) \
		./autogen.sh \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libppdirectfb@
	@CLEANUP_libppdirectfb@
	mv $(targetprefix)/lib/lib++dfb.la $(targetprefix)/lib/lib++dfb.la.old
	sed -e "s, /lib, $(targetprefix)/lib,g" < $(targetprefix)/lib/lib++dfb.la.old >$(targetprefix)/lib/lib++dfb.la
	rm -f $(targetprefix)/lib/lib++dfb.la.old
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

$(DEPDIR)/libungif: bootstrap @DEPENDS_libungif@
	@PREPARE_libungif@
	cd @DIR_libungif@ && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--without-x && \
		$(MAKE) && \
		@INSTALL_libungif@
	@CLEANUP_libungif@
	touch $@

#######################
#
#   contrib apps
#

contrib_apps: bzip2 console_data console_tools fbset lirc lsof ssh tcpdump lufs bonnie

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

$(DEPDIR)/dropbear: bootstrap libz @DEPENDS_dropbear@
	@PREPARE_dropbear@
	cd @DIR_dropbear@ && \
		$(BUILDENV) \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-syslog \
			--disable-shadow \
			--disable-lastlog \
			--disable-utmp \
			--disable-utmpx \
			--disable-wtmp \
			--disable-wtmpx && \
		cp ../Patches/dropbear-options.h options.h && \
		$(MAKE) PROGRAMS="dropbear dbclient scp" MULTI=1 && \
		$(MAKE) install PROGRAMS="dropbear dbclient scp" MULTI=1 DESTDIR=$(targetprefix) && \
		rm -f $(targetprefix)/sbin/dropbear && \
		rm -f $(targetprefix)/sbin/dbclient && \
		rm -f $(targetprefix)/bin/scp && \
		ln -s $(targetprefix)/bin/dropbearmulti $(targetprefix)/sbin/dropbear && \
		ln -s $(targetprefix)/bin/dropbearmulti $(targetprefix)/sbin/dbclient && \
		ln -s $(targetprefix)/bin/dropbearmulti $(targetprefix)/bin/scp
	@CLEANUP_dropbear@
	touch $@

$(DEPDIR)/dropbearkey: bootstrap libz @DEPENDS_dropbear@
	@PREPARE_dropbear@
	cd @DIR_dropbear@ && \
		$(BUILDENV) \
		autoconf && \
		./configure \
			--prefix= \
			--disable-syslog \
			--disable-shadow \
			--disable-lastlog \
			--disable-utmp \
			--disable-utmpx \
			--disable-wtmp \
			--disable-wtmpx && \
		cp ../Patches/dropbear-options.h options.h && \
		$(MAKE) PROGRAMS="dropbear dropbearkey"
		@if [ ! -e $(targetprefix)/etc/dropbear ]; then \
			mkdir $(targetprefix)/etc/dropbear; \
		fi
		-rm -rf $(targetprefix)/etc/dropbear/dropbear_rsa_host_key $(targetprefix)/etc/dropbear/dropbear_dss_host_key
		./@DIR_dropbear@/dropbearkey -t rsa -f $(targetprefix)/etc/dropbear/dropbear_rsa_host_key && \
		./@DIR_dropbear@/dropbearkey -t dss -f $(targetprefix)/etc/dropbear/dropbear_dss_host_key
	@CLEANUP_dropbear@
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

$(DEPDIR)/bonnie: bootstrap @DEPENDS_bonnie@
	@PREPARE_bonnie@
	cd @DIR_bonnie@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(hostprefix) && \
		$(MAKE) all WFLAGS= && \
                $(target)-strip -s bonnie++ &&\
		cp bonnie++ $(targetprefix)/sbin/bonnie
	@CLEANUP_bonnie@
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

$(DEPDIR)/lufs: bootstrap @DEPENDS_lufs@
	@PREPARE_lufs@
	cd @DIR_lufs@ && \
		$(BUILDENV) \
		aclocal && \
		libtoolize --force && \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-kernel-support && \
		$(MAKE) all && \
		@INSTALL_lufs@
	@CLEANUP_lufs@
	touch $@


#######################
#
#   development tools
#

devel: gdb ltrace strace nano joe
devel_optional: gdb-remote insight bash

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

$(DEPDIR)/bash: bootstrap @DEPENDS_bash@
	@PREPARE_bash@
	cd @DIR_bash@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= &&\
		$(MAKE) all && \
		@INSTALL_bash@
	@CLEANUP_bash@
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

$(appsdir)/tuxbox/enigma/config.status: bootstrap libfreetype libfribidi libmad libid3tag libpng libsigc libtuxbox misc_libs plugins libjpeg libungif
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

$(appsdir)/tuxbox/neutrino/config.status: bootstrap libboost libcurl libfreetype libjpeg libmad libid3tag libvorbisidec libpng libtuxbox misc_libs plugins tuxbox_libs zapit misc_tools lufs
	cd $(appsdir)/tuxbox/neutrino && $(CONFIGURE)

$(DEPDIR)/neutrino: $(appsdir)/tuxbox/neutrino/config.status
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install
	touch $@

# tuxbox/plugins

$(appsdir)/tuxbox/plugins/config.status: bootstrap libcurl libfreetype libz misc_libs libsigc libpng libtuxbox tuxbox_libs
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

################################################################
toolcheck:
	$(hostappsdir)/toolchecker/toolchecker.sh


if TARGETRULESET_FLASH
#######################
#
#   flash
#
################################################################
#
# Public flash targets
#
# flash-$gui-$rootfs-$chips
#
# Name for images/filesystems:
#
# $partition-$gui-$rootfilesystem.$type

# where 
# $type in { cramfs, squashfs, jffs2fs, img1x, 2ximg2x, flfs1x, flfs2x }
# $partition in { root, var } (empty by full images)
# $gui in { neutrino, enigma } 

# Public targets that build one or more images (*.img*x)
## TODO: include all these in .PHONY

flash-all-all-all: flash-neutrino-all-all flash-enigma-all-all

flash-all-cramfs-all: flash-neutrino-cramfs-all flash-enigma-cramfs-all

flash-all-squashfs-all: flash-neutrino-squashfs-all flash-enigma-squashfs-all

flash-all-jffs2fs-all: flash-neutrino-jffs2fs-all flash-enigma-jffs2fs-all


flash-all-all-1x: flash-neutrino-all-1x flash-enigma-all-1x

flash-all-all-2x: flash-neutrino-all-2x flash-enigma-all-2x

flash-neutrino-all-1x: flash-neutrino-cramfs-1x flash-neutrino-squashfs-1x flash-neutrino-jffs2fs-1x

flash-enigma-all-1x: flash-enigma-cramfs-1x flash-enigma-squashfs-1x flash-enigma-jffs2fs-1x

flash-all-all-2x: flash-neutrino-all-2x flash-enigma-all-2x

flash-neutrino-all-2x: flash-neutrino-cramfs-2x flash-neutrino-squashfs-2x flash-neutrino-jffs2fs-2x

flash-enigma-all-2x: flash-enigma-cramfs-2x flash-enigma-squashfs-2x flash-enigma-jffs2fs-2x

flash-neutrino-all-all: flash-neutrino-cramfs-all flash-neutrino-squashfs-all flash-neutrino-jffs2fs-all 

flash-neutrino-cramfs-all: flash-neutrino-cramfs-1x flash-neutrino-cramfs-2x

flash-neutrino-squashfs-all: flash-neutrino-squashfs-1x flash-neutrino-squashfs-2x

flash-neutrino-jffs2fs-all: flash-neutrino-jffs2fs-1x flash-neutrino-jffs2fs-2x

flash-enigma-all-all: flash-enigma-cramfs-all flash-enigma-squashfs-all flash-enigma-jffs2fs-all 

flash-enigma-cramfs-all: flash-enigma-cramfs-1x flash-enigma-cramfs-2x

flash-enigma-squashfs-all: flash-enigma-squashfs-1x flash-enigma-squashfs-2x

flash-enigma-jffs2fs-all: flash-enigma-jffs2fs-1x flash-enigma-jffs2fs-2x

flash-all-cramfs-1x: flash-enigma-cramfs-1x flash-neutrino-cramfs-1x 

flash-all-cramfs-2x: flash-enigma-cramfs-2x flash-neutrino-cramfs-2x 

flash-all-squashfs-1x: flash-enigma-squashfs-1x flash-neutrino-squashfs-1x 

flash-all-squashfs-2x: flash-enigma-squashfs-2x flash-neutrino-squashfs-2x 

flash-all-jffs2fs-1x: flash-enigma-jffs2fs-1x flash-neutrino-jffs2fs-1x 

flash-all-jffs2fs-2x: flash-enigma-jffs2fs-2x flash-neutrino-jffs2fs-2x 

################################################################
# Legacy combatibility:
# Depreciated, please do not use if possible.
flash-all: flash-all-cramfs-all

flash-neutrino flash-neutrino-all flash-cramfsneutrinoimages: flash-neutrino-cramfs-all

flash-enigma: flash-all-all-all

flash-enigma-all flash-enigma: flash-enigma-cramfs-all

flash-cramfs flash-cramfsimages: flash-all-cramfs-all

flash-squashfs flash-squashfsimages: flash-all-squashfs-all

flash-squashfsneutrinoimages: flash-neutrino-squashfs-all

flash-cramfsenigmaimages: flash-enigma-cramfs-all

flash-squashfsenigmaimages: flash-enigma-squashfs-all

flash-jffs2image: flash-neutrino-jffs2fs-all

flash-dvb-tools flash-ftpd flash-ftpfs flash-lcars flash-lcars-all \
flash-lcdmenu flash-lib flash-plugins flash-ssh flash-sshd rebuild-flash:
	@echo Make target ``$@'' is no longer supported, see doc/README-flash.en
	@false

################################################################

flash-neutrino-cramfs-1x: $(flashprefix)/.neutrino-cramfs.img1x_checked

flash-neutrino-cramfs-2x: $(flashprefix)/.neutrino-cramfs.img2x_checked

flash-neutrino-squashfs-1x: $(flashprefix)/.neutrino-squashfs.img1x_checked

flash-neutrino-squashfs-2x: $(flashprefix)/.neutrino-squashfs.img2x_checked

flash-neutrino-jffs2fs-1x: $(flashprefix)/.neutrino-jffs2fs.img1x_checked

flash-neutrino-jffs2fs-2x: $(flashprefix)/.neutrino-jffs2fs.img2x_checked

flash-enigma-cramfs-1x: $(flashprefix)/.enigma-cramfs.img1x_checked

flash-enigma-cramfs-2x: $(flashprefix)/.enigma-cramfs.img2x_checked

flash-enigma-squashfs-1x: $(flashprefix)/.enigma-squashfs.img1x_checked

flash-enigma-squashfs-2x: $(flashprefix)/.enigma-squashfs.img2x_checked

flash-enigma-jffs2fs-1x: $(flashprefix)/.enigma-jffs2fs.img1x_checked

flash-enigma-jffs2fs-2x: $(flashprefix)/.enigma-jffs2fs.img2x_checked

################################################################
# Check generated images
# For jffs2fs-images, we do not really care for the outcome
# 
$(flashprefix)/.%-jffs2fs.img1x_checked: $(flashprefix)/%-jffs2fs.img1x $(hostappsdir)/checkImage/checkImage
	@echo jffs2fs-1x is cool
	if $(hostappsdir)/checkImage/checkImage $<; then \
		touch $@; \
	else \
		touch $@_bad; \
	fi

$(flashprefix)/.%-jffs2fs.img2x_checked: $(flashprefix)/%-jffs2fs.img2x $(hostappsdir)/checkImage/checkImage
	@echo jffs2fs-2x is cool
	if $(hostappsdir)/checkImage/checkImage $<; then \
		touch $@; \
	else \
		touch $@_bad; \
	fi

$(flashprefix)/.%_checked: $(flashprefix)/% $(hostappsdir)/checkImage/checkImage
	if $(hostappsdir)/checkImage/checkImage $<; then \
		touch $@; \
	else \
		touch $@_bad; \
		mv $< $<.bad; \
	fi

$(hostappsdir)/checkImage/checkImage:
	make -C $(dir $@)

################################################################
# Targets for building user images (*.img*x)
#
# They all depend on two or three $partition-$gui.$fstype, defined in the
# next section.
# Here, `%' matches `1x' or `2x'

# Note the difference between $partition-$gui-$fstype (directory) and 
# $partition-$gui.$fstype (filesystem image of type $fstype).

$(flashprefix)/neutrino-cramfs.img%: $(flashprefix)/cramfs.flfs% \
		$(flashprefix)/root-neutrino.cramfs \
		$(flashprefix)/var-neutrino.jffs2fs
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)

$(flashprefix)/neutrino-squashfs.img%: $(flashprefix)/squashfs.flfs% \
		$(flashprefix)/root-neutrino.squashfs \
		$(flashprefix)/var-neutrino.jffs2fs
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)

$(flashprefix)/neutrino-jffs2fs.img%: $(flashprefix)/jffs2fs.flfs% \
		$(flashprefix)/root-neutrino.jffs2fs
	cat $< $(word 2,$+) > $@

$(flashprefix)/enigma-cramfs.img%: $(flashprefix)/cramfs.flfs% \
		$(flashprefix)/root-enigma.cramfs \
		$(flashprefix)/var-enigma.jffs2fs
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)

$(flashprefix)/enigma-squashfs.img%: $(flashprefix)/squashfs.flfs% \
		$(flashprefix)/root-enigma.squashfs \
		$(flashprefix)/var-enigma.jffs2fs
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)

$(flashprefix)/enigma-jffs2fs.img%: $(flashprefix)/jffs2fs.flfs% \
		$(flashprefix)/root-enigma.jffs2fs
	cat $< $(word 2,$+) > $@

################################################################
#
#### Targets for building $partition-$gui.$fstype
# All depend on directory, defined in the subsequent section

####### var-$gui.jffs2fs
$(flashprefix)/var-%.jffs2fs: $(flashprefix)/var-%
	$(FAKEROOT) $(MKJFFS2) -b -e 131072 -p -r $< -o $@

####### root-$gui.$fstype
$(flashprefix)/root-%.cramfs: $(flashprefix)/root-%-cramfs
	$(FAKEROOT) $(MKCRAMFS) -p -n "0106`date +%Y%m%d%H%M`" $< $@

$(flashprefix)/root-%.squashfs: $(flashprefix)/root-%-squashfs
	rm -f $@
	$(FAKEROOT) $(MKSQUASHFS) $< $@ -be

$(flashprefix)/root-%.jffs2fs: $(flashprefix)/root-%-jffs2fs
	$(FAKEROOT) $(MKJFFS2)  -b -e 0x20000 --pad=0x7c0000 -r $< -o $@

################ $fs-to-boot.flfs*x
$(flashprefix)/cramfs.flfs1x $(flashprefix)/cramfs.flfs2x: $(hostappsdir)/mkflfs/mkflfs
	@if [ -e $(bootdir)/u-boot-config/u-boot.config ]; then \
	    rm $(bootdir)/u-boot-config/u-boot.config; \
	fi 
	ln -s $(bootdir)/u-boot-config/u-boot.cramfs.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	rm -f $(DEPDIR)/u-boot
	rm -f $(bootprefix)/u-boot
	$(MAKE) $(DEPDIR)/u-boot 
	$(hostappsdir)/mkflfs/mkflfs 1x -o $(flashprefix)/cramfs.flfs1x $(bootprefix)/u-boot
	$(hostappsdir)/mkflfs/mkflfs 2x -o $(flashprefix)/cramfs.flfs2x $(bootprefix)/u-boot

$(flashprefix)/squashfs.flfs1x $(flashprefix)/squashfs.flfs2x: $(hostappsdir)/mkflfs/mkflfs
	@if [ -e $(bootdir)/u-boot-config/u-boot.config ]; then \
	    rm $(bootdir)/u-boot-config/u-boot.config; \
	fi 
	ln -s $(bootdir)/u-boot-config/u-boot.squashfs.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	rm -f $(DEPDIR)/u-boot
	rm -f $(bootprefix)/u-boot
	$(MAKE) $(DEPDIR)/u-boot 
	$(hostappsdir)/mkflfs/mkflfs 1x -o $(flashprefix)/squashfs.flfs1x $(bootprefix)/u-boot
	$(hostappsdir)/mkflfs/mkflfs 2x -o $(flashprefix)/squashfs.flfs2x $(bootprefix)/u-boot

$(flashprefix)/jffs2fs.flfs1x $(flashprefix)/jffs2fs.flfs2x: $(hostappsdir)/mkflfs/mkflfs
	@if [ -e $(bootdir)/u-boot-config/u-boot.config ]; then \
	    rm $(bootdir)/u-boot-config/u-boot.config; \
	fi 
	ln -s $(bootdir)/u-boot-config/u-boot.jffs2.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	rm -f $(DEPDIR)/u-boot
	rm -f $(bootprefix)/u-boot
	$(MAKE) $(DEPDIR)/u-boot 
	$(hostappsdir)/mkflfs/mkflfs 1x -o $(flashprefix)/jffs2fs.flfs1x $(bootprefix)/u-boot
	$(hostappsdir)/mkflfs/mkflfs 2x -o $(flashprefix)/jffs2fs.flfs2x $(bootprefix)/u-boot

################################################################
# This section builds directories that can be used to create filesystems
#
# Pattern: $partition-$gui[-$filesystem]

$(flashprefix)/var-neutrino: $(flashprefix)/root-neutrino-cramfs-p
	rm -rf $@
	cp -rd $</var $@
	if [ ! -d $@/tuxbox/boot ] ; then \
		$(INSTALL) -d $@/tuxbox/boot ; \
	fi
	if [ -e $(buildprefix)/defaultlogos/logo-fb -a -e $(buildprefix)/defaultlogos/logo-lcd  ] ; then \
		 cp $(buildprefix)/defaultlogos/logo-fb $(buildprefix)/defaultlogos/logo-lcd $@/tuxbox/boot ; \
	fi
	$(INSTALL) -d $@/etc/init.d
	for i in `find $</etc/init.d/ -name "start*"` ; do \
		cp -rd $$i $@/etc/init.d/ ; \
	done
	cp -rd $</etc/resolv.conf $@/etc/resolv.conf
	if [ -d $</etc/network ] ; then \
		cp -rd $</etc/network $@/etc/network ; \
	fi
	if [ -d $</etc/ssh ] ; then \
		cp -rd $</etc/ssh $@/etc/ssh ; \
	fi
	$(INSTALL) -d $@/plugins
	$(INSTALL) -d $@/tuxbox/plugins
	$(INSTALL) -d $@/bin
	cp -p $</etc/passwd $@/etc/passwd
	cp -p $</bin/camd2 $@/bin/camd2 
	@if [ ! -e $</var/tuxbox/config/scart.conf ]; then \
		cp -rd $(appsdir)/tuxbox/neutrino/daemons/controld/scart.conf $@/tuxbox/config ; \
	fi
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/var-enigma: $(flashprefix)/root-enigma-cramfs-p
	rm -rf $@
	cp -rd $</var $@
	if [ ! -d $@/tuxbox/boot ] ; then \
		$(INSTALL) -d $@/tuxbox/boot ; \
	fi
	if [ -e $(buildprefix)/defaultlogos/logo-fb -a -e $(buildprefix)/defaultlogos/logo-lcd  ] ; then \
		cp $(buildprefix)/defaultlogos/logo-fb $(buildprefix)/defaultlogos/logo-lcd $@/tuxbox/boot ; \
	fi
	$(INSTALL) -d $@/etc/init.d
	for i in `find $</etc/init.d/ -name "start*"` ; do \
		cp -rd $$i $@/etc/init.d/ ; \
	done
	cp -rd $</etc/resolv.conf $@/etc/resolv.conf
	if [ -d $</etc/network ] ; then \
		cp -rd $</etc/network $@/etc/network ; \
	fi
	if [ -d $</etc/ssh ] ; then \
		cp -rd $</etc/ssh $@/etc/ssh ; \
	fi
	$(INSTALL) -d $@/tuxbox/config/enigma
	$(INSTALL) -d $@/plugins
	$(INSTALL) -d $@/tuxbox/plugins
	$(INSTALL) -d $@/bin
	cp -p $</etc/passwd $@/etc/passwd
	cp -p $</bin/camd2 $@/bin/camd2 
	@if [ ! -e $</var/tuxbox/config/scart.conf ]; then \
		cp -rd $(appsdir)/tuxbox/neutrino/daemons/controld/scart.conf $</var/tuxbox/config ; \
	fi
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-%-jffs2fs: $(flashprefix)/root-%-jffs2fs-p $(flashprefix)/root-%-jffs2fs-p/lib/ld.so.1
	rm -rf $@
	cp -rd $< $@
	@if [ -e $(buildprefix)/root/etc/init.d/rcS.insmod ]; then \
		mv $@/etc/init.d/rcS $</etc/init.d/rcS.modprobe && \
		cp $(buildprefix)/root/etc/init.d/rcS.insmod $@/etc/init.d/rcS; \
	fi
	@if [ ! -d $@/var/tuxbox/boot ] ; then \
		mkdir $@/var/tuxbox/boot; \
	fi
	if [ -e $(buildprefix)/defaultlogos/logo-fb -a -e $(buildprefix)/defaultlogos/logo-lcd  ] ; then \
		cp $(buildprefix)/defaultlogos/logo-fb $(buildprefix)/defaultlogos/logo-lcd $@/var/tuxbox/boot ; \
	fi
	@TUXBOX_CUSTOMIZE@

# Read-only-root mods
$(flashprefix)/root-%: $(flashprefix)/root-%-p $(flashprefix)/root-%-p/lib/ld.so.1
	@if [ -d $@ ] ; then \
		rm -rf $@; \
	fi
	cp -dr $< $@
	rm -fr $@/boot
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
	for i in `find $@/etc/init.d/ -name "start*"` ; do \
		rm $$i ; ln -sf ../../var/etc/init.d/`basename $$i` $$i ; \
	done
	rm -f $@/etc/resolv.conf
	ln -sf ../var/etc/resolv.conf $@/etc/resolv.conf
	if [ -d $@/etc/network ] ; then \
		rm -fr $@/etc/network ; \
		ln -sf ../var/etc/network $@/etc/network ; \
	fi
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf ../var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	rm $@/etc/passwd
	ln -sf /var/etc/passwd $@/etc/passwd
	if [ -e $@/bin/camd2 ] ; then \
		rm $@/bin/camd2 ;\
	fi
	ln -sf /var/bin/camd2 $@/bin/camd2
	@if [ -e $(buildprefix)/root/etc/init.d/rcS.insmod ]; then \
		mv $@/etc/init.d/rcS $@/etc/init.d/rcS.modprobe && \
		cp $(buildprefix)/root/etc/init.d/rcS.insmod $@/etc/init.d/rcS; \
	fi
	@TUXBOX_CUSTOMIZE@

%/lib/ld.so.1: %
	find $</lib -maxdepth 1 -type f -o -type l | xargs rm -f
	cp -rd $(targetprefix)/lib/libnss_dns-?.*.so $</lib
	cp -rd $(targetprefix)/lib/libnss_files-?.*.so $</lib
	$(MKLIBS) --target $(target) --ldlib ld.so.1 --libc-extras-dir $(targetprefix)/lib/libc_pic \
		-d $</lib \
		-D -L $(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins \
		--root $< \
		`find $</bin/ -path "*bin/?*"` \
		`find $</lib/ -name "libnss_*"` \
		`find $</lib/tuxbox/ -name "*.so" -type f` \
		`find $</sbin/ -path "*sbin/?*"`
	$(target)-strip --remove-section=.comment --remove-section=.note \
		`find $</bin/ -path "*bin/?*"` \
		`find $</sbin/ -path "*sbin/?*"` 2>/dev/null || /bin/true
	$(target)-strip --remove-section=.comment --remove-section=.note --strip-unneeded \
		`find $</lib/tuxbox -name "*.so"` 2>/dev/null || /bin/true
	$(target)-strip $</lib/* 2>/dev/null || /bin/true
	chmod u+rwX,go+rX -R $</
	if [ -e $</lib/libfx2.so ]; then \
	if [ -e $</lib/tuxbox/plugins/ ]; then \
	rm -f $</lib/tuxbox/plugins/libfx2.so ; \
	ln -s /lib/libfx2.so $</lib/tuxbox/plugins/libfx2.so ; \
	fi ; \
	fi
	if [ -e $</bin/lufsd ]; then \
	cp -rd $(targetprefix)/lib/liblufs-ftpfs* $</lib ; \
	if [ -e $</lib/liblufs-ftpfs.2.0.0 ]; then \
	rm -f $</lib/liblufs-ftpfs ; \
	rm -f $</lib/liblufs-ftpfs.2 ; \
	mv $</lib/liblufs-ftpfs.2.0.0 $</lib/liblufs-ftpfs.so.2.0.0 ; \
	ln -s liblufs-ftpfs.so.2.0.0 $</lib/liblufs-ftpfs.so.2 ; \
	ln -s liblufs-ftpfs.so.2.0.0 $</lib/liblufs-ftpfs.so ; \
	fi ; \
	if [ -e $</lib/liblufs-ftpfs.la ]; then \
	rm -f $</lib/liblufs-ftpfs.la ; \
	fi ; \
	fi

################################################################
$(flashprefix)/root-neutrino-%-p: $(flashprefix)/root-% neutrino
	rm -rf $@
	cp -rd $< $@
	$(INSTALL) -d $@/share/fonts
	$(INSTALL) -d $@/share/iso-codes
	$(INSTALL) -d $@/var/tuxbox/config/lirc
	$(INSTALL) $(targetprefix)/bin/controld $(targetprefix)/bin/neutrino \
		$(targetprefix)/bin/nhttpd $(targetprefix)/bin/timerd \
		$@/bin
	cp -rd $(targetprefix)/share/tuxbox/neutrino $(targetprefix)/share/tuxbox/lcdd \
		$@/share/tuxbox
	$(INSTALL) $(targetprefix)/bin/camd2 $@/bin
	$(INSTALL) $(targetprefix)/bin/sectionsd $@/bin
	$(INSTALL) $(targetprefix)/bin/pzapit $@/bin
	$(INSTALL) $(targetprefix)/bin/satfind $@/bin
	$(INSTALL) $(targetprefix)/bin/zapit $@/bin
	cp $(targetprefix)/etc/init.d/start_neutrino $@/etc/init.d/start_neutrino
	cp -rd $(appsdir)/tuxbox/enigma/data/fonts/bluebold.ttf $@/share/fonts
	cp -rd $(appsdir)/tuxbox/enigma/data/fonts/bluehigh.ttf $@/share/fonts
	cp -rd $(appsdir)/tuxbox/enigma/data/fonts/md_khmurabi_10.ttf $@/share/fonts
	cp -rd $(appsdir)/tuxbox/enigma/data/fonts/pakenham.ttf $@/share/fonts
	cp -rd $(appsdir)/tuxbox/enigma/data/fonts/unmrs.pfa $@/share/fonts
	cp -rd $(targetprefix)/share/fonts/micron*.ttf $@/share/fonts
	cp -rd $(targetprefix)/share/fonts/12.pcf.gz $@/share/fonts
	cp -rd $(targetprefix)/share/fonts/14B.pcf.gz $@/share/fonts
	cp -rd $(targetprefix)/share/fonts/15B.pcf.gz $@/share/fonts
	cp -rd $(targetprefix)/share/iso-codes/iso-639.tab $@/share/iso-codes
	cp -rd $(targetprefix)/var/tuxbox/config/zapit $@/var/tuxbox/config
	cp -p $(targetprefix)/share/tuxbox/*.xml $@/share/tuxbox
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-enigma-%-p: $(flashprefix)/root-% enigma
	rm -rf $@
	cp -rd $< $@
	$(INSTALL) $(targetprefix)/bin/enigma $@/bin
	cp -rd $(targetprefix)/share/tuxbox/enigma $@/share/tuxbox
	$(INSTALL) $(targetprefix)/bin/camd2 $@/bin
	$(INSTALL) -d $@/hdd/movie
	$(INSTALL) -d $@/share/fonts
	cp -rd $(targetprefix)/share/fonts/* $@/share/fonts 
	cp -rd $(targetprefix)/etc/init.d/start_enigma $@/etc/init.d
	$(INSTALL) $(targetprefix)/etc/timezone.xml $@/etc
	cp -rd $(targetprefix)/share/zoneinfo $@/share
	$(INSTALL) -d $@/var/etc
	ln -sf /var/etc/localtime $@/etc
	$(INSTALL) -d $@/share/locale
	cp -rd $(appsdir)/tuxbox/enigma/po/locale.alias.image $@/share/locale/locale.alias
	cd $@/lib && tar xjf $(appsdir)/tuxbox/enigma/po/locale.image.tar.bz2
	cp -rd $(targetprefix)/share/locale/de $@/share/locale/
	cp -rd $(targetprefix)/share/locale/fr $@/share/locale/
	cp -rd $(targetprefix)/share/tuxbox/cables.xml $@/share/tuxbox
	cp -rd $(targetprefix)/share/tuxbox/satellites.xml $@/share/tuxbox
	@TUXBOX_CUSTOMIZE@

################################################################
$(flashprefix)/root-%: $(flashprefix)/root $(flashprefix)/vmlinuz-% $(flashprefix)/root/sbin/in.ftpd $(flashprefix)/root/sbin/streampes $(flashprefix)/root/bin/lufsd $(flashprefix)/root/lib/tuxbox/plugins 
	rm -rf $@
	cp -rd $< $@
	cp $(word 2,$+) $@/vmlinuz
	@TUXBOX_CUSTOMIZE@

################################################################
## flash-ftpd
$(flashprefix)/root/sbin/in.ftpd: $(flashprefix)/root $(DEPDIR)/ftpd
	$(INSTALL) -d $</share/empty
	$(INSTALL) $(targetprefix)/etc/vsftpd.conf $</etc
	$(INSTALL) $(targetprefix)/sbin/in.ftpd $</sbin
	@TUXBOX_CUSTOMIZE@

## flash-dvb-tools
$(flashprefix)/root/sbin/streampes: $(flashprefix)/root $(DEPDIR)/dvb_tools $(DEPDIR)/zapit
	$(INSTALL) $(targetprefix)/sbin/streamsec $</sbin
	$(INSTALL) $(targetprefix)/sbin/streamts $</sbin
	$(INSTALL) $(targetprefix)/sbin/udpstreampes $</sbin
	$(INSTALL) $(targetprefix)/sbin/streampes $</sbin
	@TUXBOX_CUSTOMIZE@

## flash-ftpfs 
$(flashprefix)/root/bin/lufsd: $(flashprefix)/root $(DEPDIR)/lufs
	$(INSTALL) $(targetprefix)/bin/lufsmnt $</bin
	$(INSTALL) $(targetprefix)/bin/lufsd $</bin
	@TUXBOX_CUSTOMIZE@

## flash-plugins
$(flashprefix)/root/lib/tuxbox/plugins: $(flashprefix)/root plugins
	$(INSTALL) -d $</lib/tuxbox/plugins
	$(INSTALL) -d $</var/tuxbox/config/tuxtxt
	$(INSTALL) $(targetprefix)/bin/tuxmaild $</bin
	cp -rd $(targetprefix)/lib/tuxbox/plugins/*.cfg $</lib/tuxbox/plugins/
	cp -rd $(targetprefix)/lib/tuxbox/plugins/*.so $</lib/tuxbox/plugins/
	cp -rd $(targetprefix)/share/fonts/tuxtxt.ttf $</share/fonts/
	cp -rd $(targetprefix)/share/fonts/tuxtxt.otb $</share/fonts/
	cp -rd $(targetprefix)/var/tuxbox/config/games.cfg $</var/tuxbox/config/
	cp -rd $(targetprefix)/var/tuxbox/config/tuxtxt/tuxtxt.conf $</var/tuxbox/config/tuxtxt/
	cp -rd $(targetprefix)/share/tuxbox/sokoban $</share/tuxbox/

$(flashprefix)/root: procps busybox driver tuxbox_tools lirc $(DEPDIR)/rootdirectories
	rm -rf $@
	$(INSTALL) -d $@/bin
	$(INSTALL) -d $@/dev
	$(INSTALL) -d $@/lib/tuxbox
	$(INSTALL) -d $@/mnt
	$(INSTALL) -d $@/proc
	$(INSTALL) -d $@/sbin
	$(INSTALL) -d $@/share/tuxbox
	$(INSTALL) -d $@/share/fonts
	$(INSTALL) -d $@/var/tuxbox/config
	$(INSTALL) -d $@/var/tuxbox/ucodes
	$(INSTALL) -d $@/tmp
	$(MAKE) -C root install targetprefix=$@
	echo "version=0200`date +%Y%m%d%H%M`" > $@/.version
	echo "comment=Created by `id -un`" >> $@/.version
	$(INSTALL) $(targetprefix)/bin/busybox $@/bin
	for i in `find $(targetprefix)/bin/ -lname "*busybox"` ; do cp -rd $$i $@/bin/ ; done
	for i in `find $(targetprefix)/sbin/ -lname "*busybox"` ; do cp -rd $$i $@/sbin/ ; done
	$(INSTALL) $(targetprefix)/bin/switch $@/bin
	$(INSTALL) $(targetprefix)/bin/tuxinfo $@/bin
	$(INSTALL) $(targetprefix)/sbin/lircd $@/sbin
	if [ -e $(targetprefix)/sbin/eraseall ] ; then \
		$(INSTALL) $(targetprefix)/sbin/eraseall $@/sbin ; \
	fi
	rm -f $@/etc/init.d/start_*
	$(INSTALL) -d $@/lib/modules/$(KERNELVERSION)
	cp -rd $(targetprefix)/lib/modules/$(KERNELVERSION)/kernel $(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
		$@/lib/modules/$(KERNELVERSION)
	ln -s /tmp $@/var/run
	ln -s /var $@/root
	@TUXBOX_CUSTOMIZE@

################################################################
# Build different kernels for cramfs, squashfs, and jffs2fs
$(flashprefix)/vmlinuz-cramfs: linuxdir
	rm -f $(DEPDIR)/linuxkernel
	cp maps/dbox2-flash.c linux/drivers/mtd/maps
	$(MAKE) $(DEPDIR)/linuxkernel
	cp $(bootprefix)/kernel-cdk $@

$(flashprefix)/vmlinuz-%: linuxdir $(buildprefix)/Patches/linux-drivers-mtd-maps-dbox2-flash-%.c.diff
	rm -f $(DEPDIR)/linuxkernel
	cp maps/dbox2-flash.c linux/drivers/mtd/maps
	(cd linux/drivers/mtd/maps; patch <  $(word 2,$+))
	$(MAKE) $(DEPDIR)/linuxkernel
	cp $(bootprefix)/kernel-cdk $@

################################################################
$(hostappsdir)/mkflfs/mkflfs:
	cd $(hostappsdir)/mkflfs && \
	gcc -o mkflfs mkflfs.c minilzo.c

################################################################
# Targets, which are not executed by detault

$(flashprefix)/root/bin/ssh: $(flashprefix)/root $(DEPDIR)/ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh $(targetprefix)/bin/scp \
		$(targetprefix)/bin/sftp $(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/ssh/ssh_config $(flashprefix)/root/etc/ssh

$(flashprefix)/root/sbin/sshd: $(flashprefix)/root $(DEPDIR)/ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) -d $(flashprefix)/root/libexec
	$(INSTALL) -d $(flashprefix)/root/share/empty
	$(INSTALL) $(targetprefix)/bin/ssh-keygen $(targetprefix)/bin/scp \
		$(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/ssh/* $(flashprefix)/root/etc/ssh
	cp -rd $(targetprefix)/etc/init.d/start_sshd $(flashprefix)/root/etc/init.d/
	$(INSTALL) $(targetprefix)/libexec/sftp-server $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/sbin/sshd $(flashprefix)/root/sbin

# Dreamdata (doesn't work)
$(flashprefix)/root/bin/mrouted: $(flashprefix)/root plugins mrouted
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/dreamdata.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/dreamdata.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/var/tuxbox/config/dreamdata.xml $(flashprefix)/root/var/tuxbox/config/
	$(INSTALL) $(targetprefix)/bin/mrouted $(flashprefix)/root/bin

$(flashprefix)/root/sbin/dropbear: $(flashprefix)/root dropbear dropbearkey
	$(INSTALL) -d $(flashprefix)/root/etc/dropbear
	$(INSTALL) $(targetprefix)/bin/dropbearmulti $(flashprefix)/root/bin
	rm -f $(flashprefix)/root/sbin/dropbear
	rm -f $(flashprefix)/root/sbin/dbclient
	rm -f $(flashprefix)/root/bin/scp
	ln -s ../bin/dropbearmulti $(flashprefix)/root/sbin/dropbear
	ln -s ../bin/dropbearmulti $(flashprefix)/root/sbin/dbclient
	ln -s ../bin/dropbearmulti $(flashprefix)/root/bin/scp
	cp -rd $(targetprefix)/etc/dropbear/* $(flashprefix)/root/etc/dropbear

$(flashprefix)/root/bin/lcars: $(flashprefix)/root lcars
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	$(INSTALL) $(targetprefix)/bin/lcars $(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/init.d/start_lcars $(flashprefix)/root/etc/init.d/
	cp -rd $(targetprefix)/share/fonts/ds9.ttf $(flashprefix)/root/share/fonts
	cp -rd $(targetprefix)/var/tuxbox/config/lcars $(flashprefix)/root/var/tuxbox/config

$(flashprefix)/root/bin/lcdmenu: $(flashprefix)/root lcd
	$(INSTALL) $(targetprefix)/bin/lcdmenu $(flashprefix)/root/bin
	cp -rd $(targetprefix)/var/tuxbox/config/lcdmenu.conf $(flashprefix)/root/var/tuxbox/config

################################################################ 
# This .PRECIOUS-bizarreness is there to tell Make that these files are not
# just "intermediate products", but are not to be deleted.  For the
# directories, these are not really valuable, however, make tries to
# delete them with rm, and this fails, generating error messages that
# may be ugly or confusing.

.PRECIOUS: \
$(flashprefix)/neutrino-cramfs.img% $(flashprefix)/enigma-cramfs.img% \
$(flashprefix)/neutrino-squashfs.img% $(flashprefix)/enigma-squashfs.img% \
$(flashprefix)/neutrino-jffs2fs.img% $(flashprefix)/enigma-jffs2fs.img% \
$(flashprefix)/root-%-jffs2fs  $(flashprefix)/root-% \
$(flashprefix)/root-neutrino-%-p $(flashprefix)/root-enigma-%-p \
$(flashprefix)/vmlinuz-%
################################################################
# flash-clean deletes everything created with the flash-* commands
# flash-developerclean leaves the flfs-images and the vmlinuz-* files.
# (This is sensible, while these files seldomly changes, and take rather
# long to build.)

# flash-semiclean and flash-developerclean, are "homemade",
# flash-clean and flash-mostlyclean have semantics like in the GNU
# Makefile standards.

flash-semiclean:
	rm -f $(flashprefix)/*.cramfs $(flashprefix)/*.squashfs \
	$(flashprefix)/*.jffs2fs $(flashprefix)/.*-flfs \
	$(flashprefix)/.*_checked* $(flashprefix)/.root-*
	rm -rf $(flashprefix)/root* 
	rm -rf $(flashprefix)/var*

flash-developerclean: flash-semiclean
	rm -f $(flashprefix)/*.img*

flash-mostlyclean: flash-semiclean
	rm -f $(flashprefix)/*.flfs*x $(flashprefix)/vmlinuz*

flash-clean: flash-mostlyclean
	rm -f $(flashprefix)/*.img*
endif ## TARGETRULESET_FLASH

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
Makefile-archive: $(top_srcdir)/rules-archive $(top_srcdir)/rules-archive.pl
	$(top_srcdir)/rules-archive.pl $(top_srcdir)/rules-archive > Makefile-archive
endif

if TARGETRULESET_FLASH
.PHONY: core libs root apps boot devel java copy lib compress \
	flash-clean flash-semiclean
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
