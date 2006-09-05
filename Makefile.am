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
if KERNEL26
	$(INSTALL) -d $(targetprefix)/sys
endif
	$(INSTALL) -d $(targetprefix)/tmp
	$(INSTALL) -d $(targetprefix)/var
	$(INSTALL) -d $(targetprefix)/var/etc
	$(INSTALL) -d $(targetprefix)/var/run
	$(INSTALL) -d $(targetprefix)$(UCODEDIR)
	$(INSTALL) -d $(hostprefix)/$(target)
	$(INSTALL) -d $(bootprefix)
	-rm -f $(hostprefix)/$(target)/include
	-rm -f $(hostprefix)/$(target)/lib
	-ln -sf $(targetprefix)/include $(hostprefix)/$(target)/include
	-ln -sf $(targetprefix)/lib $(hostprefix)/$(target)/lib
if KERNEL26
	-ln -sf $(buildprefix)/linux/include/asm-powerpc $(hostprefix)/$(target)/include/asm
else
	-ln -sf $(buildprefix)/linux/include/asm $(hostprefix)/$(target)/include
endif
	-ln -sf $(buildprefix)/linux/include/asm-generic $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/linux $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/mtd $(hostprefix)/$(target)/include
if TARGETRULESET_FLASH
	$(INSTALL) -d $(flashprefix)
endif
	touch $@


if KERNEL26
KERNEL_DEPENDS = @DEPENDS_linux@
KERNEL_DIR = @DIR_linux@
KERNEL_PREPARE = @PREPARE_linux@
else
KERNEL_DEPENDS = @DEPENDS_linux24@
KERNEL_DIR = @DIR_linux24@
KERNEL_PREPARE = @PREPARE_linux24@
endif

$(DEPDIR)/linuxdir: $(KERNEL_DEPENDS)
	@if [ ! -d $(targetprefix)/bin ]; then \
		$(MAKE) directories; \
	fi
	$(KERNEL_PREPARE)
if TARGETRULESET_FLASH
	cat Patches/linux-$(KERNELVERSION).config-flash > $(KERNEL_DIR)/.config
else
	cat Patches/linux-$(KERNELVERSION).config > $(KERNEL_DIR)/.config
endif
	$(MAKE) -C $(KERNEL_DIR) oldconfig \
		ARCH=ppc
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) include/asm \
		ARCH=ppc
endif
	$(MAKE) -C $(KERNEL_DIR) include/linux/version.h \
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
			--without-fp && \
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
			--without-fp && \
		$(MAKE) all && \
		@INSTALL_bootstrap_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include
	@CLEANUP_bootstrap_gcc@


$(DEPDIR)/glibc: @DEPENDS_glibc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so -a ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) bootstrap_gcc; \
	elif [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) gcc; \
	fi
	@PREPARE_glibc@
	touch @DIR_glibc@/config.cache
	@if [ $(GLIBC_PTHREADS) = "nptl" ]; then \
		cp @SOURCEDIR_glibc@/nptl/sysdeps/pthread/pthread.h @DIR_glibc@ && \
		cp @SOURCEDIR_glibc@/nptl/sysdeps/unix/sysv/linux/powerpc/bits/pthreadtypes.h @DIR_glibc@ && \
		echo "libc_cv_forced_unwind=yes" > @DIR_glibc@/config.cache && \
		echo "libc_cv_c_cleanup=yes" >> @DIR_glibc@/config.cache; \
	fi
	cd @DIR_glibc@ && \
		$(BUILDENV) \
		@CONFIGURE_glibc@ \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-headers=$(targetprefix)/include \
			--disable-profile \
			--disable-debug  \
			--enable-shared \
			--without-gd \
			--with-tls \
			--with-__thread \
			--enable-add-ons=$(GLIBC_PTHREADS) \
			--enable-clocale=gnu \
			--without-fp \
			--cache-file=config.cache \
			$(GLIBC_EXTRA_FLAGS) && \
		$(MAKE) all && \
		@INSTALL_glibc@
	@CLEANUP_glibc@
	sed -e's, /lib/, $(targetprefix)/lib/,g' < $(targetprefix)/lib/libc.so > $(targetprefix)/lib/libc.so.new
	mv $(targetprefix)/lib/libc.so.new $(targetprefix)/lib/libc.so
	sed -e's, /lib/, $(targetprefix)/lib/,g' < $(targetprefix)/lib/libpthread.so > $(targetprefix)/lib/libpthread.so.new
	mv $(targetprefix)/lib/libpthread.so.new $(targetprefix)/lib/libpthread.so
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
# gcc second stage
#
$(DEPDIR)/gcc: @DEPENDS_gcc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so ]; then \
		$(MAKE) glibc; \
	fi
# if we have a symlink inside the libdir (in case gcc has already been built)
# we remove it here
	@if [ -h $(hostprefix)/$(target)/lib/nof ]; then \
		rm -f $(hostprefix)/$(target)/lib/nof; \
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
			--without-fp && \
		$(MAKE) all && \
		@INSTALL_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include
	for i in `find $(hostprefix)/$(target)/lib/nof` ; do mv $$i $(hostprefix)/$(target)/lib; done
	rm -rf $(hostprefix)/$(target)/lib/nof
	ln -sf $(hostprefix)/$(target)/lib $(hostprefix)/$(target)/lib/nof
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
if  KERNEL26
root: \
	rootdirectories busybox ftpd module_init_tools tuxbox_hotplug \
	procps watchdog
else
root: \
	rootdirectories busybox ftpd modutils \
	procps watchdog
endif
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

$(DEPDIR)/libdirectfb: bootstrap libfreetype libjpeg libpng libz @DEPENDS_libdirectfb@
	@PREPARE_libdirectfb@
	cd @DIR_libdirectfb@ && \
		$(BUILDENV) \
		LDFLAGS=-L$(targetprefix)/lib \
		CPPFLAGS="-I$(buildprefix)/linux/arch/ppc" \
		CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
		./configure \
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
		./configure \
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
		./configure \
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
		./autogen.sh && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all $(BUILDENV) && \
		$(MAKE) install && $(target)-ar cru $(targetprefix)/lib/libpng12_pic.a *.o
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
	echo "ac_cv_func_posix_getpwuid_r=yes" > @DIR_libglib@/config.cache
	echo "glib_cv_stack_grows=no" >> @DIR_libglib@/config.cache
	echo "glib_cv_uscore=no" >> @DIR_libglib@/config.cache
	cd @DIR_libglib@ && \
		$(BUILDENV) \
		./configure \
			--cache-file=config.cache \
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

$(DEPDIR)/libiconv: bootstrap @DEPENDS_libiconv@
	@PREPARE_libiconv@
	cd @DIR_libiconv@ && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
		$(MAKE) && \
		@INSTALL_libiconv@
	@CLEANUP_libiconv@
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
		$(MAKE) PROGRAMS="dropbear dropbearkey scp" MULTI=1 && \
		mkdir -p $(targetprefix)/var/etc/dropbear && \
		mkdir -p $(targetprefix)/var/.ssh && \
		@INSTALL_dropbear@ && \
		$(target)-strip --strip-all $(targetprefix)/sbin/dropbearmulti
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
			--exec_prefix=$(targetprefix) \
			--disable-kernel-support && \
		$(MAKE) all && \
		@INSTALL_lufs@
	@CLEANUP_lufs@
	touch $@

$(DEPDIR)/kermit: bootstrap @DEPENDS_kermit@ libcrypto
	@echo "Kermit is licensed differently from other software (more restrictively),"
	@echo "see http://www.columbia.edu/kermit/licensing.html"
	@PREPARE_kermit@
	cd @DIR_kermit@ && \
		$(BUILDENV) \
		$(MAKE) tuxbox && \
		@INSTALL_kermit@
	ln -sf ./kermit $(targetprefix)/bin/kermit-sshsub
	[ -d $(targetprefix)/var/lock ] ||  mkdir $(targetprefix)/var/lock
	@CLEANUP_kermit@
	touch $@


#######################
#
#   ide apps
#

ide_apps: hdparm utillinux e2fsprogs parted

$(DEPDIR)/hdparm: bootstrap @DEPENDS_hdparm@
	@PREPARE_hdparm@
	cd @DIR_hdparm@ && \
		$(BUILDENV) \
		$(MAKE) all && \
		@INSTALL_hdparm@
	@CLEANUP_hdparm@
	touch $@

$(DEPDIR)/utillinux: bootstrap @DEPENDS_utillinux@
	@PREPARE_utillinux@
	cd @DIR_utillinux@ && \
		CC=$(target)-gcc \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure && \
		$(MAKE) ARCH=ppc all && \
		@INSTALL_utillinux@
	@CLEANUP_utillinux@
	touch $@

# "install-libs" target is necessary to install the
# headers for parted, not sure why they do not
# get installed otherwise
$(DEPDIR)/e2fsprogs: bootstrap @DEPENDS_e2fsprogs@
	@PREPARE_e2fsprogs@
	cd @DIR_e2fsprogs@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) \
			--with-cc=$(target)-gcc \
			--with-linker=$(target)-ld \
			--disable-evms \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-swapfs \
			--disable-debugfs \
			--disable-image \
			--enable-resizer \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			--disable-nls && \
		$(MAKE) libs progs && \
		$(MAKE) install-libs && \
		@INSTALL_e2fsprogs@
	@CLEANUP_e2fsprogs@
	touch $@

$(DEPDIR)/parted: bootstrap e2fsprogs libreadline @DEPENDS_parted@
	@PREPARE_parted@
	cd @DIR_parted@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		$(MAKE) all && \
		@INSTALL_parted@
	@CLEANUP_parted@
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

$(DEPDIR)/python: bootstrap @DEPENDS_python@
	@PREPARE_python@
	cd @DIR_python@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=\
			--enable-shared &&\
		$(MAKE) python && \
		@INSTALL_python@
	@CLEANUP_python@
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

$(DEPDIR)/scummvm: bootstrap libreadline libsdl libmad @DEPENDS_scummvm@
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

$(DEPDIR)/tinygl: bootstrap @DEPENDS_tinygl@
	@PREPARE_tinygl@
	cp -p $(appsdir)/tuxbox/tools/graphics/fbgl.c @DIR_tinygl@/examples
	cd @DIR_tinygl@ && \
		$(MAKE) all
		for prog in gears mech spin texobj; do \
			 $(INSTALL) @DIR_tinygl@/examples/$$prog $(targetprefix)/bin; \
		done
		$(INSTALL) -m 644 @DIR_tinygl@/lib/libTinyGL.a $(targetprefix)/lib
	@CLEANUP_tinygl@
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

if KERNEL26
UBOOT_CONFIG_FILE:="./u-boot.cdk.2_6.dbox2.h"
else
UBOOT_CONFIG_FILE:="./u-boot.cdk.dbox2.h"
endif

$(DEPDIR)/u-boot: bootstrap @DEPENDS_uboot@
	@PREPARE_uboot@
	@if [ ! -e $(bootdir)/u-boot-config/u-boot.config ]; then \
	    ln -sf $(UBOOT_CONFIG_FILE) $(bootdir)/u-boot-config/u-boot.config; \
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
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) uImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
else
	$(MAKE) -C $(KERNEL_DIR) zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
endif
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
if KERNEL26
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $(bootprefix)/kernel-cdk
else
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 \
		-d $(KERNEL_DIR)/arch/ppc/boot/images/vmlinux.gz \
		$(bootprefix)/kernel-cdk
endif
	chmod 644 $(bootprefix)/kernel-cdk
	$(INSTALL) -m644 $(KERNEL_DIR)/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
	$(INSTALL) -m644 $(KERNEL_DIR)/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)
if MAINTAINER_MODE
else
	$(MAKE) -C $(KERNEL_DIR) clean
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

# tuxbox/radiobox

$(appsdir)/tuxbox/radiobox/config.status: bootstrap libboost libcurl libfreetype libmad libid3tag libvorbisidec libtuxbox misc_libs tuxbox_libs misc_tools lufs
	cd $(appsdir)/tuxbox/radiobox && $(CONFIGURE)

$(DEPDIR)/radiobox: $(appsdir)/tuxbox/radiobox/config.status
	$(MAKE) -C $(appsdir)/tuxbox/radiobox all install
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

$(appsdir)/tuxbox/tools/hotplug/config.status: bootstrap
	cd $(appsdir)/tuxbox/tools/hotplug && $(CONFIGURE)

$(DEPDIR)/tuxbox_hotplug: $(appsdir)/tuxbox/tools/hotplug/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/hotplug all install
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

flash-neutrino-all: flash-neutrino flash-lcdmenu flash-plugins flash-ftpd flash-dvb-tools flash-ftpfs flash-lib

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
	if [ -e $(targetprefix)/sbin/eraseall ] ; then \
		$(INSTALL) $(targetprefix)/sbin/eraseall $(flashprefix)/root/sbin ; \
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

flash-dropbear:	$(flashprefix)/.part_dropbear

$(flashprefix)/.part_dropbear: $(flashprefix)/.flash $(DEPDIR)/dropbear
	$(INSTALL) $(targetprefix)/sbin/dropbearmulti $(flashprefix)/root/sbin
	for i in dropbear scp dropbearkey; do \
		ln -sf dropbearmulti $(flashprefix)/root/sbin/$$i; done;
	mkdir -p $(flashprefix)/root/var/.ssh
	mkdir -p $(flashprefix)/root/var/etc/dropbear
	ln -sf /var/.ssh $(flashprefix)/root/.ssh
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

flash-plugin_dreamdata: $(flashprefix)/.part_plugin_dreamdata

$(flashprefix)/.part_plugin_dreamdata: $(flashprefix)/.flash plugins mrouted
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/dreamdata.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/dreamdata.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/var/tuxbox/config/dreamdata.xml $(flashprefix)/root/var/tuxbox/config/
	$(INSTALL) $(targetprefix)/bin/mrouted $(flashprefix)/root/bin
	@touch $@

flash-dvb-tools: $(flashprefix)/.part_dvb_tools

$(flashprefix)/.part_dvb_tools: $(flashprefix)/.flash dvb_tools
	$(INSTALL) $(targetprefix)/sbin/streampes $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/streamsec $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/streamts $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/udpstreampes $(flashprefix)/root/sbin
	@touch $@

flash-ftpfs: $(flashprefix)/.part_ftpfs

$(flashprefix)/.part_ftpfs: $(flashprefix)/.flash lufs
	$(INSTALL) $(targetprefix)/bin/lufsd $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/lufsmnt $(flashprefix)/root/bin
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
	cp -pa $(appsdir)/tuxbox/enigma/data/fonts/bluebold.ttf $(flashprefix)/root/share/fonts
	cp -pa $(appsdir)/tuxbox/enigma/data/fonts/bluehigh.ttf $(flashprefix)/root/share/fonts
	cp -pa $(appsdir)/tuxbox/enigma/data/fonts/md_khmurabi_10.ttf $(flashprefix)/root/share/fonts
	cp -pa $(appsdir)/tuxbox/enigma/data/fonts/pakenham.ttf $(flashprefix)/root/share/fonts
	cp -pa $(appsdir)/tuxbox/enigma/data/fonts/unmrs.pfa $(flashprefix)/root/share/fonts
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
	$(INSTALL) -d $(flashprefix)/root/hdd/movie
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/share/fonts/* $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/etc/init.d/start_enigma $(flashprefix)/root/etc/init.d
	$(INSTALL) $(targetprefix)/etc/timezone.xml $(flashprefix)/root/etc
	cp -pa $(targetprefix)/share/zoneinfo $(flashprefix)/root/share
	ln -sf /var/etc/localtime $(flashprefix)/root/etc
	$(INSTALL) -d $(flashprefix)/root/share/locale
	cp -pa $(appsdir)/tuxbox/enigma/po/locale.alias.image $(flashprefix)/root/share/locale/locale.alias
	cd $(flashprefix)/root/lib && tar xjvf $(appsdir)/tuxbox/enigma/po/locale.image.tar.bz2
	cp -pa $(targetprefix)/share/locale/de $(flashprefix)/root/share/locale/
	cp -pa $(targetprefix)/share/locale/fr $(flashprefix)/root/share/locale/
	find $(flashprefix)/root/share/locale -name libc.mo -o -name nano.mo | xargs rm -f
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
	$(INSTALL) -d $(flashprefix)/root/share/fonts/
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config/tuxtxt
	$(INSTALL) $(targetprefix)/bin/tuxmaild $(flashprefix)/root/bin
	cp -pa $(targetprefix)/lib/tuxbox/plugins/*.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	cp -pa $(targetprefix)/lib/tuxbox/plugins/*.so $(flashprefix)/root/lib/tuxbox/plugins/
	cp -pa $(targetprefix)/share/fonts/tuxtxt.ttf $(flashprefix)/root/share/fonts/
	cp -pa $(targetprefix)/share/fonts/tuxtxt.otb $(flashprefix)/root/share/fonts/
	cp -pa $(targetprefix)/var/tuxbox/config/games.cfg $(flashprefix)/root/var/tuxbox/config/
	cp -pa $(targetprefix)/var/tuxbox/config/tuxtxt/tuxtxt.conf $(flashprefix)/root/var/tuxbox/config/tuxtxt/
	cp -pa $(targetprefix)/share/tuxbox/sokoban $(flashprefix)/root/share/tuxbox/
	@touch $@

flash-fstools: $(flashprefix)/.part_fstools
$(flashprefix)/.part_fstools: $(flashprefix)/.flash e2fsprogs utillinux
	$(INSTALL) -d $(flashprefix)/root/sbin
	@for i in e2fsck mke2fs ; do \
		$(INSTALL) $(targetprefix)/sbin/$$i $(flashprefix)/root/sbin; done;
	ln -sf /proc/mounts $(flashprefix)/root/etc/mtab 
	cd $(flashprefix)/root/sbin && \
	    ln -sf mke2fs mkfs.ext3 && \
	    ln -sf mke2fs mkfs.ext2 && \
	    ln -sf e2fsck fsck.ext2 && \
	    ln -sf e2fsck fsck.ext3
	@touch $@

flash-utillinux: $(flashprefix)/.part_utillinux
$(flashprefix)/.part_utillinux: $(flashprefix)/.flash utillinux
	$(INSTALL) -d $(flashprefix)/root/sbin
	@for i in sfdisk ; do \
		$(INSTALL) $(targetprefix)/sbin/$$i $(flashprefix)/root/sbin; done;
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
	if [ -e $(flashprefix)/root/bin/lufsd ]; then \
	cp -pa $(targetprefix)/lib/liblufs-ftpfs* $(flashprefix)/root/lib ; \
	if [ -e $(flashprefix)/root/lib/liblufs-ftpfs.2.0.0 ]; then \
	rm -f $(flashprefix)/root/lib/liblufs-ftpfs ; \
	rm -f $(flashprefix)/root/lib/liblufs-ftpfs.2 ; \
	mv $(flashprefix)/root/lib/liblufs-ftpfs.2.0.0 $(flashprefix)/root/lib/liblufs-ftpfs.so.2.0.0 ; \
	ln -s liblufs-ftpfs.so.2.0.0 $(flashprefix)/root/lib/liblufs-ftpfs.so.2 ; \
	ln -s liblufs-ftpfs.so.2.0.0 $(flashprefix)/root/lib/liblufs-ftpfs.so ; \
	fi ; \
	if [ -e $(flashprefix)/root/lib/liblufs-ftpfs.la ]; then \
	rm -f $(flashprefix)/root/lib/liblufs-ftpfs.la ; \
	fi ; \
	fi
	@touch $@

flash-clean:
	@if [ -e $(flashprefix)/root-cramfs.img ]; then \
	     rm $(flashprefix)/root-cramfs.img; \
	fi
	@if [ -e $(flashprefix)/root-squashfs.img ]; then \
	     rm $(flashprefix)/root-squashfs.img; \
	fi
	@if [ -e $(flashprefix)/root ]; then \
	     rm -rf $(flashprefix)/root; \
	fi
	@if [ -e $(flashprefix)/.flash ]; then \
	     rm $(flashprefix)/.flash; \
	fi
	@if [ -e $(flashprefix)/.lib ]; then \
	     rm $(flashprefix)/.lib; \
	fi
	@if [ -e $(flashprefix)/.part_ftpd ]; then \
	     rm $(flashprefix)/.part_ftpd; \
	fi
	@if [ -e $(flashprefix)/.part_neutrino ]; then \
	     rm $(flashprefix)/.part_neutrino; \
	fi
	@if [ -e $(flashprefix)/.part_enigma ]; then \
	     rm $(flashprefix)/.part_enigma; \
	fi
	@if [ -e $(flashprefix)/.rojffs2neutrino ]; then \
	     rm $(flashprefix)/.rojffs2neutrino; \
	fi
	@if [ -e $(flashprefix)/.rojffs2enigma ]; then \
	     rm $(flashprefix)/.rojffs2enigma; \
	fi
	@if [ -e $(flashprefix)/.root-roimg ]; then \
	     rm $(flashprefix)/.root-roimg; \
	fi

flash-cramfs: $(flashprefix)/root-cramfs-neutrino.img
	$(MAKE) flash-clean
	$(MAKE) $(flashprefix)/root-cramfs-enigma.img

flash-squashfs: $(flashprefix)/root-squashfs-neutrino.img
	$(MAKE) flash-clean
	$(MAKE) $(flashprefix)/root-squashfs-enigma.img

flash-cramfsimages: flash-cramfsneutrinoimages
	$(MAKE) flash-clean
	$(MAKE) flash-cramfsenigmaimages

flash-squashfsimages: flash-squashfsneutrinoimages
	$(MAKE) flash-clean
	$(MAKE) flash-squashfsenigmaimages

flash-cramfsneutrinoimages: $(flashprefix)/cramfsjffs2neutrino_1x.img $(flashprefix)/cramfsjffs2neutrino_2x.img

flash-squashfsneutrinoimages: $(flashprefix)/squashfsjffs2neutrino_1x.img $(flashprefix)/squashfsjffs2neutrino_2x.img

flash-cramfsenigmaimages: $(flashprefix)/cramfsjffs2enigma_1x.img $(flashprefix)/cramfsjffs2enigma_2x.img

flash-squashfsenigmaimages: $(flashprefix)/squashfsjffs2enigma_1x.img $(flashprefix)/squashfsjffs2enigma_2x.img

flash-var-jffs2: $(flashprefix)/var-jffs2.img

flash-root-jffs2: $(flashprefix)/root-jffs2.img

flash-jffs2image: $(flashprefix)/jffs2only.img

$(flashprefix)/root-cramfs-neutrino.img: $(flashprefix)/.flash-roneutrinoroot
	$(MAKE) flash-cramfsroot
	mv $(flashprefix)/root-cramfs.img $(flashprefix)/root-cramfs-neutrino.img

$(flashprefix)/root-squashfs-neutrino.img: $(flashprefix)/.flash-roneutrinoroot
	$(MAKE) flash-squashfsroot
	mv $(flashprefix)/root-squashfs.img $(flashprefix)/root-squashfs-neutrino.img

$(flashprefix)/root-cramfs-enigma.img: $(flashprefix)/.flash-roenigmaroot
	$(MAKE) flash-cramfsroot
	mv $(flashprefix)/root-cramfs.img $(flashprefix)/root-cramfs-enigma.img

$(flashprefix)/root-squashfs-enigma.img: $(flashprefix)/.flash-roenigmaroot
	$(MAKE) flash-squashfsroot
	mv $(flashprefix)/root-squashfs.img $(flashprefix)/root-squashfs-enigma.img

$(flashprefix)/cramfsjffs2neutrino_1x.img: $(flashprefix)/root-cramfs-neutrino.img \
		$(flashprefix)/var-jffs2.img $(flashprefix)/.cramfs-flfs
	$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/cramfsjffs2neutrino_1x.img -o build \
		--part ppcboot=$(flashprefix)/cramfs-flfs1x.img \
		--part root=$(flashprefix)/root-cramfs-neutrino.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/squashfsjffs2neutrino_1x.img: $(flashprefix)/root-squashfs-neutrino.img \
		$(flashprefix)/var-jffs2.img $(flashprefix)/.squashfs-flfs
	$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/squashfsjffs2neutrino_1x.img -o build \
		--part ppcboot=$(flashprefix)/squashfs-flfs1x.img \
		--part root=$(flashprefix)/root-squashfs-neutrino.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/cramfsjffs2neutrino_2x.img: $(flashprefix)/root-cramfs-neutrino.img \
		$(flashprefix)/var-jffs2.img $(flashprefix)/.cramfs-flfs
	$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/cramfsjffs2neutrino_2x.img -o build \
		--part ppcboot=$(flashprefix)/cramfs-flfs2x.img \
		--part root=$(flashprefix)/root-cramfs-neutrino.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/squashfsjffs2neutrino_2x.img: $(flashprefix)/root-squashfs-neutrino.img \
		$(flashprefix)/var-jffs2.img $(flashprefix)/.squashfs-flfs
	$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/squashfsjffs2neutrino_2x.img -o build \
		--part ppcboot=$(flashprefix)/squashfs-flfs2x.img \
		--part root=$(flashprefix)/root-squashfs-neutrino.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/cramfsjffs2enigma_1x.img: $(flashprefix)/root-cramfs-enigma.img \
		$(flashprefix)/var-jffs2.img $(flashprefix)/.cramfs-flfs
	$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/cramfsjffs2enigma_1x.img -o build \
		--part ppcboot=$(flashprefix)/cramfs-flfs1x.img \
		--part root=$(flashprefix)/root-cramfs-enigma.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/squashfsjffs2enigma_1x.img: $(flashprefix)/root-squashfs-enigma.img \
		$(flashprefix)/var-jffs2.img $(flashprefix)/.squashfs-flfs
	$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/squashfsjffs2enigma_1x.img -o build \
		--part ppcboot=$(flashprefix)/squashfs-flfs1x.img \
		--part root=$(flashprefix)/root-squashfs-enigma.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/cramfsjffs2enigma_2x.img: $(flashprefix)/root-cramfs-enigma.img \
		$(flashprefix)/var-jffs2.img $(flashprefix)/.cramfs-flfs
	$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/cramfsjffs2enigma_2x.img -o build \
		--part ppcboot=$(flashprefix)/cramfs-flfs2x.img \
		--part root=$(flashprefix)/root-cramfs-enigma.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/squashfsjffs2enigma_2x.img: $(flashprefix)/root-squashfs-enigma.img \
		$(flashprefix)/var-jffs2.img $(flashprefix)/.squashfs-flfs
	$(hostappsdir)/flash/flashmanage.pl -i $(flashprefix)/squashfsjffs2enigma_2x.img -o build \
		--part ppcboot=$(flashprefix)/squashfs-flfs2x.img \
		--part root=$(flashprefix)/root-squashfs-enigma.img \
		--part var=$(flashprefix)/var-jffs2.img

$(flashprefix)/.flash-roneutrinoroot: $(flashprefix)/.flash-rochanges flash-neutrino flash-apps

$(flashprefix)/.flash-roenigmaroot: $(flashprefix)/.flash-rochanges flash-enigma flash-apps

flash-apps: $(flashprefix)/.part_apps

$(flashprefix)/.part_apps: flash-ftpd flash-plugins flash-dvb-tools flash-ftpfs
	@touch $@

$(flashprefix)/.flash-rochanges:
	@if [ -e $(buildprefix)/root/etc/init.d/rcS.insmod ]; then \
	    mv $(buildprefix)/root/etc/init.d/rcS $(buildprefix)/root/etc/init.d/rcS.modprobe && \
	    mv $(buildprefix)/root/etc/init.d/rcS.insmod $(buildprefix)/root/etc/init.d/rcS; \
	fi

flash-cramfsroot: $(flashprefix)/.lib
	$(MAKE) $(flashprefix)/.cramfs
	$(FAKEROOT) $(MKCRAMFS) -p -n "0106`date +%Y%m%d%H%M`" $(flashprefix)/cramfs/ $(flashprefix)/root-cramfs.img
	rm -fr $(flashprefix)/cramfs
	rm $(flashprefix)/.cramfs

flash-squashfsroot: $(flashprefix)/.lib
	$(MAKE) $(flashprefix)/.cramfs
	$(FAKEROOT) $(MKSQUASHFS) $(flashprefix)/cramfs/ $(flashprefix)/root-squashfs.img -be
	rm -fr $(flashprefix)/cramfs
	rm $(flashprefix)/.cramfs

$(flashprefix)/.cramfs:
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
	ln -sf /var/etc/issue.net $(flashprefix)/cramfs/etc/issue.net
	cp -p $(targetprefix)/share/tuxbox/*.xml $(flashprefix)/cramfs/share/tuxbox
	rm $(flashprefix)/cramfs/etc/passwd
	ln -sf /var/etc/passwd $(flashprefix)/cramfs/etc/passwd
	rm $(flashprefix)/cramfs/bin/camd2
	ln -sf /var/bin/camd2 $(flashprefix)/cramfs/bin/camd2
	@touch $@

$(flashprefix)/var-jffs2.img: $(flashprefix)/.lib
	rm -rf $(flashprefix)/jffs2
	cp -pa $(flashprefix)/root/var $(flashprefix)/jffs2
	if [ ! -d $(flashprefix)/jffs2/tuxbox/boot ] ; then \
		$(INSTALL) -d $(flashprefix)/jffs2/tuxbox/boot ; \
	fi
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
	$(INSTALL) -d $(flashprefix)/jffs2/tuxbox/config/enigma
	$(INSTALL) -d $(flashprefix)/jffs2/plugins
	$(INSTALL) -d $(flashprefix)/jffs2/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/jffs2/bin
	cp -p $(flashprefix)/root/etc/passwd $(flashprefix)/jffs2/etc/passwd
	cp -p $(flashprefix)/root/bin/camd2 $(flashprefix)/jffs2/bin/camd2
	@if [ ! -e $(flashprefix)/root/var/tuxbox/config/scart.conf ]; then \
		cp -pa $(appsdir)/tuxbox/neutrino/daemons/controld/scart.conf $(flashprefix)/root/var/tuxbox/config ; \
	fi
	$(FAKEROOT) $(MKJFFS2) -b -e 131072 -p -r $(flashprefix)/jffs2/ -o $(flashprefix)/var-jffs2.img
	rm -rf $(flashprefix)/jffs2

$(flashprefix)/root-jffs2.img: $(flashprefix)/.lib
	$(FAKEROOT) $(MKJFFS2) -b -e 0x20000 --pad=0x7c0000 -r $(flashprefix)/root/ -o $(flashprefix)/root-jffs2.img

$(flashprefix)/jffs2only.img: $(flashprefix)/.lib $(flashprefix)/jffs2-flfs.img
	$(FAKEROOT) $(MKJFFS2) -b -e 0x20000 --pad=0x7c0000 -r $(flashprefix)/root/ -o $(flashprefix)/root-jffs2.tmp
	cat $(flashprefix)/jffs2-flfs.img > $(flashprefix)/jffs2only.img
	cat $(flashprefix)/root-jffs2.tmp >> $(flashprefix)/jffs2only.img
	rm -f  $(flashprefix)/root-jffs2.tmp

$(flashprefix)/.cramfs-flfs: $(flashprefix)/.mkflfs
	@if [ -e $(bootdir)/u-boot-config/u-boot.config ]; then \
	    rm $(bootdir)/u-boot-config/u-boot.config; \
	fi
	ln -s $(bootdir)/u-boot-config/u-boot.cramfs.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	rm -f $(DEPDIR)/u-boot
	rm -f $(bootprefix)/u-boot
	$(MAKE) $(DEPDIR)/u-boot
	$(hostappsdir)/mkflfs/mkflfs 1x -o $(flashprefix)/cramfs-flfs1x.img $(bootprefix)/u-boot
	$(hostappsdir)/mkflfs/mkflfs 2x -o $(flashprefix)/cramfs-flfs2x.img $(bootprefix)/u-boot
	@touch $@

$(flashprefix)/.squashfs-flfs: $(flashprefix)/.mkflfs
	@if [ -e $(bootdir)/u-boot-config/u-boot.config ]; then \
	    rm $(bootdir)/u-boot-config/u-boot.config; \
	fi
	ln -s $(bootdir)/u-boot-config/u-boot.squashfs.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	rm -f $(DEPDIR)/u-boot
	rm -f $(bootprefix)/u-boot
	$(MAKE) $(DEPDIR)/u-boot
	$(hostappsdir)/mkflfs/mkflfs 1x -o $(flashprefix)/squashfs-flfs1x.img $(bootprefix)/u-boot
	$(hostappsdir)/mkflfs/mkflfs 2x -o $(flashprefix)/squashfs-flfs2x.img $(bootprefix)/u-boot
	@touch $@

$(flashprefix)/.mkflfs:
	cd $(hostappsdir)/mkflfs && \
	gcc -o mkflfs mkflfs.c minilzo.c
	@touch $@

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
	-$(MAKE) -C $(appsdir)/tuxbox/tools/hotplug distclean
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
