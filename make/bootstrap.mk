$(DEPDIR):
	$(INSTALL) -d $(DEPDIR)

$(DEPDIR)/bootstrap: $(CCACHE) gcc
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
	$(INSTALL) -d $(targetprefix)/var/tuxbox/boot
	$(INSTALL) -d $(targetprefix)$(UCODEDIR)
if ENABLE_IDE
	$(INSTALL) -d $(targetprefix)/hdd
endif
	$(INSTALL) -d $(hostprefix)/$(target)
	$(INSTALL) -d $(bootprefix)
	-rm -f $(hostprefix)/$(target)/include
	-rm -f $(hostprefix)/$(target)/lib
	-ln -sf $(targetprefix)/include $(hostprefix)/$(target)/include
	-ln -sf $(targetprefix)/lib $(hostprefix)/$(target)/lib
if !KERNEL26
	-ln -sf $(buildprefix)/linux/include/linux $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/asm $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/asm-generic $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/mtd $(hostprefix)/$(target)/include
endif
if TARGETRULESET_FLASH
	$(INSTALL) -d $(flashprefix)
endif
	touch $@

if KERNEL26
KERNEL_DEPENDS = @DEPENDS_linux@
KERNEL_DIR = @DIR_linux@
KERNEL_PREPARE = @PREPARE_linux@
KERNEL_BUILD_FILENAME = @DIR_linux@/arch/ppc/boot/images/uImage
else
KERNEL_DEPENDS = @DEPENDS_linux24@
KERNEL_DIR = @DIR_linux24@
KERNEL_PREPARE = @PREPARE_linux24@
KERNEL_BUILD_FILENAME = @DIR_linux24@/arch/ppc/boot/images/vmlinux.gz
endif

if ENABLE_FS_CIFS
KERNEL_CIFS=Archive/cifs-1.20c-2.4.tar.gz
endif

$(DEPDIR)/linuxdir: $(KERNEL_DEPENDS) $(KERNEL_CIFS) directories
	$(KERNEL_PREPARE)
if KERNEL26
	cp Patches/linux-2.6.26.4-dbox2.config $(KERNEL_DIR)/.config
else
	cp Patches/linux-2.4.35.5-dbox2.config $(KERNEL_DIR)/.config
if ENABLE_FS_LUFS
	cd $(KERNEL_DIR) && patch -p1 -E -i $(buildprefix)/Patches/linux-2.4.33-dbox2-lufs.diff
endif
if ENABLE_FS_CIFS
	gunzip -cd $(buildprefix)/Archive/cifs-1.20c-2.4.tar.gz | TAPE=- tar -x
	cd $(KERNEL_DIR) && patch -p1 -E -i ./cifs_24.patch
endif
endif
	$(MAKE) -C $(KERNEL_DIR) oldconfig \
		ARCH=ppc
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) include/asm \
		ARCH=ppc
endif
	$(MAKE) -C $(KERNEL_DIR) include/linux/version.h \
		ARCH=ppc
	rm $(KERNEL_DIR)/.config
	touch $@


$(DEPDIR)/binutils: @DEPENDS_binutils@ directories 
	@PREPARE_binutils@
	cd @DIR_binutils@ && \
		CC=$(CC) \
		CFLAGS="$(CFLAGS)" \
		@CONFIGURE_binutils@ \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--disable-nls \
			--disable-werror \
			--without-fp && \
		$(MAKE) configure-host && \
		$(MAKE) -j $(J) all && \
		$(MAKE) -j $(J) all-gprof && \
		@INSTALL_binutils@
	@CLEANUP_binutils@
	touch $@

#
# gcc first stage without glibc
#
if ASSUME_KERNELSOURCES_OLD
$(DEPDIR)/bootstrap_gcc: @DEPENDS_bootstrap_gcc@ binutils | linuxdir
else
$(DEPDIR)/bootstrap_gcc: @DEPENDS_bootstrap_gcc@ binutils linuxdir
endif
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
		$(MAKE) -j $(J) all && \
		@INSTALL_bootstrap_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include
	@CLEANUP_bootstrap_gcc@
	touch $@

if TARGETRULESET_UCLIBC
if !TARGETRULESET_FLASH
UCLIBC_DEBUG_SED_CONF=$(foreach param,DODEBUG DODEBUG_PT SUPPORT_LD_DEBUG SUPPORT_LD_DEBUG_EARLY UCLIBC_MALLOC_DEBUGGING,-e s"/^.*$(param)[= ].*/$(param)=y/")
endif

$(DEPDIR)/libc: @DEPENDS_uclibc@ bootstrap_gcc install-linux-headers
if KERNEL26
KHEADERS="$(buildprefix)/$(KERNEL_DIR)/usr/include"
else
KHEADERS="$(buildprefix)/$(KERNEL_DIR)/include"
endif
	@PREPARE_uclibc@
	sed $(XFS_UCLIBC_CONF) $(UCLIBC_DEBUG_SED_CONF) -e 's,^KERNEL_HEADERS=.*,KERNEL_HEADERS=$(KHEADERS),g' Patches/uclibc-0.9.30.config > @DIR_uclibc@/.config
	$(MAKE) -C @DIR_uclibc@ oldconfig ARCH=ppc
	cd @DIR_uclibc@ && \
		$(BUILDENV) \
		$(MAKE) \
		PREFIX= \
		HOSTCC=$(CC) \
		all && \
		@INSTALL_uclibc@
	sed -i -e 's,/lib/,$(targetprefix)/lib/,g' $(targetprefix)/lib/libc.so
	@CLEANUP_uclibc@
	touch $@

else

$(DEPDIR)/libc: @DEPENDS_glibc@ bootstrap_gcc install-linux-headers
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
		$(MAKE) -j $(J) all && \
		@INSTALL_glibc@
	@CLEANUP_glibc@
	sed -e's, /lib/, $(targetprefix)/lib/,g' < $(targetprefix)/lib/libc.so > $(targetprefix)/lib/libc.so.new
	mv $(targetprefix)/lib/libc.so.new $(targetprefix)/lib/libc.so
	sed -e's, /lib/, $(targetprefix)/lib/,g' < $(targetprefix)/lib/libpthread.so > $(targetprefix)/lib/libpthread.so.new
	mv $(targetprefix)/lib/libpthread.so.new $(targetprefix)/lib/libpthread.so
	touch $@

endif

#
# gcc second stage
#
$(DEPDIR)/gcc: @DEPENDS_gcc@ libc
# if we have a symlink inside the libdir (in case gcc has already been built)
# we remove it here
	@if [ -h $(hostprefix)/$(target)/lib/nof ]; then \
		rm -f $(hostprefix)/$(target)/lib/nof; \
	fi
	@PREPARE_gcc@
if TARGETRULESET_UCLIBC
	cd @SOURCEDIR_gcc@ && patch -p1 -E -i $(buildprefix)/Patches/gcc-uclibc.diff
endif
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
		$(MAKE) -j $(J) all && \
		@INSTALL_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include
	for i in `find $(hostprefix)/$(target)/lib/nof` ; do mv $$i $(hostprefix)/$(target)/lib; done
	rm -rf $(hostprefix)/$(target)/lib/nof
	ln -sf $(hostprefix)/$(target)/lib $(hostprefix)/$(target)/lib/nof
	@CLEANUP_gcc@
	touch $@


# This rule script checks if all archives are present at the given address but
# does NOT download them.
#
# It takes some time so it's not useful to include it in a regular
# build

archivecheck:
	@$(buildprefix)/rules-downcheck.pl

.PHONY: archivecheck
