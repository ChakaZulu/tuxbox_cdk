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
	ln -sf /tmp $(targetprefix)/var/run
	$(INSTALL) -d $(targetprefix)/var/tuxbox/boot
	$(INSTALL) -d $(targetprefix)$(UCODEDIR)
if ENABLE_IDE
	$(INSTALL) -d $(targetprefix)/hdd
endif
	$(INSTALL) -d $(hostprefix)/$(target)
	$(INSTALL) -d $(hostprefix)/bin
	$(INSTALL) -d $(bootprefix)
	-rm -f $(hostprefix)/$(target)/include
	-rm -f $(hostprefix)/$(target)/lib
	-ln -sf $(targetprefix)/include $(hostprefix)/$(target)/include
	-ln -sf $(targetprefix)/lib $(hostprefix)/$(target)/lib
if BOXTYPE_DREAMBOX
	@for i in linux asm-generic asm mtd ; do \
		rm -rf $(hostprefix)/$(target)/include/$$i 2> /dev/null || /bin/true; \
		ln -sf $(buildprefix)/linux/include/$$i $(hostprefix)/$(target)/include; \
	done;
else
if !KERNEL26
	-ln -sf $(buildprefix)/linux/include/linux $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/asm $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/asm-generic $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/mtd $(hostprefix)/$(target)/include
endif
endif
if TARGETRULESET_FLASH
	$(INSTALL) -d $(flashprefix)
endif
	touch $@

if BOXTYPE_DREAMBOX
KERNEL_DEPENDS = @DEPENDS_linux_dream@
KERNEL_DIR = @DIR_linux_dream@
KERNEL_PREPARE = @PREPARE_linux_dream@
KERNEL_BUILD_FILENAME = @DIR_linux_dream@/arch/ppc/boot/images/zImage.treeboot
else
if BOXTYPE_IPBOX
KERNEL_DEPENDS = @DEPENDS_linux_ipbox@
KERNEL_DIR = @DIR_linux_ipbox@
KERNEL_PREPARE = @PREPARE_linux_ipbox@
KERNEL_BUILD_FILENAME = @DIR_linux_ipbox@/vmlinux
if BOXMODEL_IP200
IPBOX_UBOOT_TARGET = relook100s
IPBOX_FLASH_MAP = $(buildprefix)/config/flash_map.mutant200s
IPBOX_DRIVER = dgstationdriver_mutant200s
IPBOX_DRIVER_MODDIR = $(flashprefix)/root-squashfs/lib/modules/@VERSION_linux_ipbox@-mutant200s
IPBOX_DRIVER_DEPENDS = @DEPENDS_dgstationdriver_mutant200s@
IPBOX_DRIVER_DIR = @DIR_dgstationdriver_mutant200s@
IPBOX_DRIVER_PREPARE = @PREPARE_dgstationdriver_mutant200s@
endif
if BOXMODEL_IP250
IPBOX_UBOOT_TARGET = relook200s
IPBOX_FLASH_MAP = $(buildprefix)/config/flash_map.relook200s
IPBOX_DRIVER = dgstationdriver_cubecafe
IPBOX_DRIVER_MODDIR = $(flashprefix)/root-squashfs/lib/modules/@VERSION_linux_ipbox@-cubecafe
IPBOX_DRIVER_DEPENDS = @DEPENDS_dgstationdriver_cubecafe@
IPBOX_DRIVER_DIR = @DIR_dgstationdriver_cubecafe@
IPBOX_DRIVER_PREPARE = @PREPARE_dgstationdriver_cubecafe@
endif
if BOXMODEL_IP350
IPBOX_UBOOT_TARGET = relook210
IPBOX_FLASH_MAP = $(buildprefix)/config/flash_map.relook210
IPBOX_DRIVER = dgstationdriver_prime
IPBOX_DRIVER_MODDIR = $(flashprefix)/root-squashfs/lib/modules/@VERSION_linux_ipbox@-cubecafe-prime
IPBOX_DRIVER_DEPENDS = @DEPENDS_dgstationdriver_prime@
IPBOX_DRIVER_DIR = @DIR_dgstationdriver_prime@
IPBOX_DRIVER_PREPARE = @PREPARE_dgstationdriver_prime@
endif
if BOXMODEL_IP400
IPBOX_UBOOT_TARGET = relook400s
IPBOX_FLASH_MAP = $(buildprefix)/config/flash_map.relook400s
IPBOX_DRIVER_MODDIR = $(flashprefix)/root-squashfs/lib/modules/@VERSION_linux_ipbox@-relook400
IPBOX_DRIVER_DEPENDS = @DEPENDS_dgstationdriver_relook400s@
IPBOX_DRIVER_DIR = @DIR_dgstationdriver_relook400s@
IPBOX_DRIVER_PREPARE = @PREPARE_dgstationdriver_relook400s@
endif
else
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
endif
endif

if ENABLE_FS_CIFS
KERNEL_DEPENDS += Archive/cifs-1.20c-2.4.tar.gz
endif

if ENABLE_AUTOMOUNT
KERNEL_DEPENDS += Archive/autofs4-2.4-module-20050404.tar.gz
endif

$(DEPDIR)/linuxdir: $(KERNEL_DEPENDS) @DEPENDS_liblzma465@ directories
	$(KERNEL_PREPARE)
	@PREPARE_liblzma465@
if KERNEL26
if BOXTYPE_DREAMBOX
	cp $(KERNEL_DIR)/arch/ppc/configs/$(BOXMODEL)_defconfig $(KERNEL_DIR)/.config
else
if BOXTYPE_IPBOX
	m4 $(IPBOX_M4_KERNEL) $(flash_kernel_conf) > $(KERNEL_DIR)/.config
else
	cp Patches/linux-2.6.26.4-dbox2.config $(KERNEL_DIR)/.config
endif
endif
	$(INSTALL) -d $(KERNEL_DIR)/lib/lzma/
	$(INSTALL) -d $(KERNEL_DIR)/include/linux/lzma/
	mv @DIR_liblzma465@/C/Lz*.c $(KERNEL_DIR)/lib/lzma/
	mv @DIR_liblzma465@/C/*.h $(KERNEL_DIR)/include/linux/lzma/
	cd $(KERNEL_DIR) && patch -p1 -E -i $(buildprefix)/Patches/linux-2.6-jffs2_lzma.diff
else
	cp Patches/linux-2.4.35.5-dbox2.config $(KERNEL_DIR)/.config
if ENABLE_FS_LUFS
	cd $(KERNEL_DIR) && patch -p1 -E -i $(buildprefix)/Patches/linux-2.4.33-dbox2-lufs.diff
endif
if ENABLE_FS_CIFS
	gunzip -cd $(buildprefix)/Archive/cifs-1.20c-2.4.tar.gz | TAPE=- tar -x
	cd $(KERNEL_DIR) && patch -p1 -E -i ./cifs_24.patch
endif
if ENABLE_AUTOMOUNT
	cd $(KERNEL_DIR) && gunzip -cd $(buildprefix)/Archive/autofs4-2.4-module-20050404.tar.gz | TAPE=- tar -x
	cd $(KERNEL_DIR) && patch -p1 -E -i ./autofs4-2.4/module-patches/autofs4-2.4.29.patch
endif
	mv @DIR_liblzma465@/C/Lz* $(KERNEL_DIR)/fs/jffs2/
	mv @DIR_liblzma465@/C/Types.h $(KERNEL_DIR)/fs/jffs2/
	cd $(KERNEL_DIR) && patch -p1 -E -i $(buildprefix)/Patches/linux-2.4-jffs2_lzma.diff
endif
	@CLEANUP_liblzma465@
	$(MAKE) -C $(KERNEL_DIR) oldconfig \
		ARCH=ppc
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) include/asm \
		ARCH=ppc
endif
	$(MAKE) -C $(KERNEL_DIR) include/linux/version.h \
		ARCH=ppc
if !BOXTYPE_DREAMBOX
	rm $(KERNEL_DIR)/.config
endif
	touch $@

if !USE_FOREIGN_TOOLCHAIN
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
endif

if TARGETRULESET_UCLIBC
if !TARGETRULESET_FLASH
UCLIBC_DEBUG_SED_CONF=$(foreach param,DODEBUG DODEBUG_PT SUPPORT_LD_DEBUG SUPPORT_LD_DEBUG_EARLY UCLIBC_MALLOC_DEBUGGING,-e s"/^.*$(param)[= ].*/$(param)=y/")
endif

if ASSUME_KERNELSOURCES_OLD
$(DEPDIR)/libc: @DEPENDS_uclibc@ bootstrap_gcc | install-linux-headers
else
$(DEPDIR)/libc: @DEPENDS_uclibc@ bootstrap_gcc install-linux-headers
endif
if BOXTYPE_DBOX2
if KERNEL26
KHEADERS="$(buildprefix)/$(KERNEL_DIR)/usr/include"
else
KHEADERS="$(buildprefix)/$(KERNEL_DIR)/include"
endif
else
KHEADERS="$(hostprefix)/$(target)/include"
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
if USE_FOREIGN_TOOLCHAIN
$(DEPDIR)/libc: directories
	cp -a $(TOOLCHAIN_PATH)/$(target)/lib $(targetprefix)/
	touch $@
else

if ASSUME_KERNELSOURCES_OLD
$(DEPDIR)/libc: @DEPENDS_glibc@ bootstrap_gcc | install-linux-headers
else
$(DEPDIR)/libc: @DEPENDS_glibc@ bootstrap_gcc install-linux-headers
endif
	@PREPARE_glibc@
	touch @DIR_glibc@/config.cache
	@if [ $(GLIBC_PTHREADS) = "nptl" ]; then \
		cp @SOURCEDIR_glibc@/nptl/sysdeps/pthread/pthread.h @DIR_glibc@ && \
		cp @SOURCEDIR_glibc@/nptl/sysdeps/unix/sysv/linux/powerpc/bits/pthreadtypes.h @DIR_glibc@ && \
		echo "libc_cv_forced_unwind=yes" > @DIR_glibc@/config.cache && \
		echo "libc_cv_c_cleanup=yes" >> @DIR_glibc@/config.cache; \
	fi
if CPUMODEL_405
	rm @SOURCEDIR_glibc@/sysdeps/powerpc/powerpc32/strncmp.S
	cd @SOURCEDIR_glibc@ && patch -p1 -E -i ../Patches/glibc_ppc4xx_ibmstropt.diff
	cd @SOURCEDIR_glibc@ && patch -p1 -E -i ../Patches/glibc-ibmppc4xx_fp_perflib.diff
endif
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
endif

#
# gcc second stage
#
if USE_FOREIGN_TOOLCHAIN
$(DEPDIR)/gcc: libc linuxdir
	touch $@
else
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
if CPUMODEL_405
	cd @SOURCEDIR_gcc@ && patch -p1 -E -i ../Patches/gcc-g++-ppc4xx.diff
	cd @SOURCEDIR_gcc@ && patch -p1 -E -i ../Patches/gcc-ibmppc4xx_fp_perflib.diff
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
endif

# This rule script checks if all archives are present at the given address but
# does NOT download them.
#
# It takes some time so it's not useful to include it in a regular
# build

archivecheck:
	@$(buildprefix)/rules-downcheck.pl

.PHONY: archivecheck
