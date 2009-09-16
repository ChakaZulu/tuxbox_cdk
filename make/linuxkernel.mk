# Kernel
#
# Yes, this depends on $(KERNEL_DIR)/.config, which the Makefile does not have
# as a target.
# This is deliberate, and makes the target "private".

$(KERNEL_BUILD_FILENAME): bootstrap_gcc linuxdir install-linux-headers $(KERNEL_DIR)/.config
if BOXTYPE_DREAMBOX
	$(MAKE) -j $(J) -C $(KERNEL_DIR) zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
else
	$(MAKE) -C $(KERNEL_DIR) oldconfig ARCH=ppc
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) include/asm \
		ARCH=ppc
endif
	$(MAKE) -C $(KERNEL_DIR) include/linux/version.h ARCH=ppc
if BOXTYPE_IPBOX
	$(MAKE) -j $(J) -C $(KERNEL_DIR) vmlinux modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
else
if KERNEL26
	$(MAKE) -j $(J) -C $(KERNEL_DIR) uImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		INSTALL_MOD_PATH=$(targetprefix)
else
	$(MAKE) -j $(J) -C $(KERNEL_DIR) zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
endif
endif
endif
# if KERNEL26
# 	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $(bootprefix)/kernel-cdk
# else
#	$(hostprefix)/bin/mkimage \
#		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
#		-a 00000000 -e 00000000 \
#		-d $(KERNEL_DIR)/arch/ppc/boot/images/vmlinux.gz \
#		$(bootprefix)/kernel-cdk
# endif
#	$(INSTALL) -m644 $(KERNEL_DIR)/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
#	$(INSTALL) -m644 $(KERNEL_DIR)/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)
#	touch $@

if BOXTYPE_DREAMBOX
$(DEPDIR)/install-linux-headers: linuxdir @DEPENDS_linux_dream_kernel_headers@
else
if BOXTYPE_IPBOX
$(DEPDIR)/install-linux-headers: linuxdir @DEPENDS_linux_ipbox_kernel_headers@
else
$(DEPDIR)/install-linux-headers: linuxdir
endif
endif
if BOXTYPE_DREAMBOX
	@PREPARE_linux_dream_kernel_headers@
	mv $(buildprefix)/@DIR_linux_dream_kernel_headers@/include/asm-ppc $(buildprefix)/@DIR_linux_dream_kernel_headers@/include/asm
	for i in linux asm asm_generic; do \
		rm -R $(hostprefix)/$(target)/include/$$i 2> /dev/null || /bin/true; \
		if [ $$i != asm_generic ] ; then \
			mv $(buildprefix)/@DIR_linux_dream_kernel_headers@/include/$$i $(hostprefix)/$(target)/include; \
		fi; \
	done;
	for i in config.h autoconf.h; do \
		ln -sf $(buildprefix)/linux/include/linux/$$i $(hostprefix)/$(target)/include/linux; \
	done;
	@CLEANUP_linux_dream_kernel_headers@
else
if BOXTYPE_IPBOX
	@PREPARE_linux_ipbox_kernel_headers@
	mv $(buildprefix)/@DIR_linux_ipbox_kernel_headers@/include/asm-powerpc $(buildprefix)/@DIR_linux_ipbox_kernel_headers@/include/asm
	for i in linux asm asm-generic mtd scsi; do \
		rm -R $(hostprefix)/$(target)/include/$$i 2> /dev/null || /bin/true; \
		mv $(buildprefix)/@DIR_linux_ipbox_kernel_headers@/include/$$i $(hostprefix)/$(target)/include; \
	done;
	for i in config.h autoconf.h; do \
		ln -sf $(buildprefix)/linux/include/linux/$$i $(hostprefix)/$(target)/include/linux; \
	done;
	echo "/* empty */" > $(hostprefix)/$(target)/include/linux/compiler.h
	@CLEANUP_linux_ipbox_kernel_headers@
else
if KERNEL26
# Kernels after 2.6.18 offer a special "headers_install" target to generate
# "userspace-blessed" heades. This will create an include directory in
# $(KERNEL_DIR)/usr

# It would be more correct to copy all directories, but some files seem to also
# be provided by the glibc (e.g. scsi) so the directory exists and we simply use
# those directories that are necessary. This is a rule of its own since glibc
# needs the linux headers to build. For 2.4 this does nothing. Note that we cheat
# here and declare the target powerpc since ppc will be gone in a not too distant
# future and the headers are slowly being removed.
	@if [ `echo $(KERNELVERSION) | sed -e 's/\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\).*/\3/g'` -lt 18 ]; then \
		ln -sf $(buildprefix)/linux/include/linux $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/include/asm $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/include/asm-generic $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/include/mtd $(hostprefix)/$(target)/include; \
	else \
		$(MAKE) -C $(KERNEL_DIR) headers_install ARCH=powerpc; \
		ln -sf $(buildprefix)/linux/usr/include/linux $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/usr/include/asm $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/usr/include/asm-generic $(hostprefix)/$(target)/include; \
		ln -sf $(buildprefix)/linux/usr/include/mtd $(hostprefix)/$(target)/include; \
	fi
endif
endif
endif
	touch $@

KERNEL_M4 = -D$(BOXTYPE)

if BOXTYPE_DREAMBOX
KERNEL_M4 += -D$(BOXMODEL)
endif
if BOXTYPE_IPBOX
KERNEL_M4 += -D$(BOXMODEL)
endif

if ENABLE_IDE
KERNEL_M4 += -Dide
endif
if ENABLE_EXT2
KERNEL_M4 += -Dext2 -Dextfs
endif
if ENABLE_EXT3
KERNEL_M4 += -Dext3 -Dextfs
endif
if ENABLE_XFS
KERNEL_M4 += -Dxfs
UCLIBC_M4 += -Dxfs
endif
if ENABLE_REISERFS
KERNEL_M4 += -Dreiserfs
endif
if ENABLE_VFAT
KERNEL_M4 += -Dvfat -Dnls
endif
if ENABLE_FS_CIFS
KERNEL_M4 += -Dcifs -Dnls
endif
if ENABLE_FS_SMBFS
KERNEL_M4 += -Dsmbfs -Dnls
endif
if ENABLE_AUTOMOUNT
KERNEL_M4 += -Dautofs
endif
if ENABLE_OPENVPN
KERNEL_M4 += -Dtun
endif
if ENABLE_NFSSERVER
KERNEL_M4 += -Dnfsd
endif
if ENABLE_FS_NFS
KERNEL_M4 += -Dnfs
endif

if DREAMBOX_ENABLE_SERIAL_CONSOLE
DREAMBOX_SERIAL_SED=-e "s/console=null/console=ttyS0,115200/"
else
DREAMBOX_SERIAL_SED=-e ""
endif

kernel-cdk: $(bootprefix)/kernel-cdk

if BOXTYPE_DBOX2
if KERNEL26
$(bootprefix)/kernel-cdk: linuxdir $(MKIMAGE) $(kernel_conf) Patches/dbox2-flash.c-26.m4
	m4 --define=rootfs=$(FLASH_FS_TYPE) --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
else
$(bootprefix)/kernel-cdk: linuxdir $(MKIMAGE) $(kernel_conf) Patches/dbox2-flash.c.m4
	m4 --define=rootfs=$(FLASH_FS_TYPE) --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
endif
	m4 -Dyadd -Dsquashfs -Dsquashfslzma -Djffs2 -Djffs2lzma $(KERNEL_M4) -Dnfs $(kernel_conf) > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME)
if KERNEL26
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $@
else
	$(hostprefix)/bin/mkimage \
		-n 'Linux-$(KERNELVERSION)' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 \
		-d $(KERNEL_BUILD_FILENAME) \
		$@
endif
	chmod 644 $@
	$(INSTALL) -m644 $(KERNEL_DIR)/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
	$(INSTALL) -m644 $(KERNEL_DIR)/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)
	$(INSTALL) -d $(targetprefix)/tmp
	$(INSTALL) -d $(targetprefix)/proc
	ln -sf /tmp $(targetprefix)/var/run
endif

if ENABLE_MMC
DRIVER_MMC=yes
endif

driver: $(KERNEL_BUILD_FILENAME)
	$(MAKE) -C $(driverdir) \
		DRIVER_MMC=$(DRIVER_MMC) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(driverdir) \
		DRIVER_MMC=$(DRIVER_MMC) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)- \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix) \
		install

driver-clean:
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		distclean
#	-rm $(DEPDIR)/driver

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

.PHONY: driver-clean
