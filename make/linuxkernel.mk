# Kernel
#
# Yes, this depends on $(KERNEL_DIR)/.config, which the Makefile does not have
# as a target.
# This is deliberate, and makes the target "private".

#$(DEPDIR)/linuxkernel: bootstrap linuxdir install-linux-headers $(KERNEL_DIR)/.config
$(KERNEL_BUILD_FILENAME): bootstrap linuxdir install-linux-headers $(KERNEL_DIR)/.config
	$(MAKE) -C $(KERNEL_DIR) oldconfig ARCH=ppc
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) include/asm \
		ARCH=ppc
endif
	$(MAKE) -C $(KERNEL_DIR) include/linux/version.h ARCH=ppc
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) uImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		INSTALL_MOD_PATH=$(targetprefix)
else
	$(MAKE) -C $(KERNEL_DIR) zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
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

$(DEPDIR)/install-linux-headers: linuxdir
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
	touch $@


if ENABLE_LZMA
LZMA_SED_CONF=$(foreach param,CONFIG_SQUASHFS_LZMA,-e s"/^.*$(param)[= ].*/$(param)=y/")
else
LZMA_SED_CONF=$(foreach param,CONFIG_SQUASHFS_LZMA,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
endif

if ENABLE_IDE
IDE_SED_CONF=$(foreach param,CONFIG_IDE CONFIG_BLK_DEV_IDE CONFIG_BLK_DEV_IDEDISK,-e s"/^.*$(param)[= ].*/$(param)=m/")
else
if KERNEL26
IDE_SED_CONF=$(foreach param,CONFIG_IDE CONFIG_BLK_DEV_IDE CONFIG_BLK_DEV_IDEDISK,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
else
IDE_SED_CONF=-e ""
endif
endif

if ENABLE_EXT3
EXT3_SED_CONF=$(foreach param,CONFIG_EXT2_FS CONFIG_EXT3_FS CONFIG_JBD,-e s"/^.*$(param)[= ].*/$(param)=m/")
else
if KERNEL26
EXT3_SED_CONF=$(foreach param,CONFIG_EXT2_FS CONFIG_EXT3_FS CONFIG_JBD,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
else
EXT3_SED_CONF=-e ""
endif
endif

if ENABLE_XFS
XFS_SED_CONF=$(foreach param,CONFIG_XFS_FS,-e s"/^.*$(param)[= ].*/$(param)=m/")
else
if KERNEL26
XFS_SED_CONF=$(foreach param,CONFIG_XFS_FS,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
else
XFS_SED_CONF=-e ""
endif
endif

if ENABLE_NFSSERVER
if KERNEL26
NFSSERVER_SED_CONF=$(foreach param,CONFIG_NFSD CONFIG_EXPORTFS,-e s"/^.*$(param)[= ].*/$(param)=m/")
NFSSERVER_SED_CONF+=$(foreach param,CONFIG_NFSD_V3 CONFIG_NFSD_TCP,-e s"/^.*$(param)[= ].*/$(param)=y/")
else
NFSSERVER_SED_CONF=$(foreach param,CONFIG_NFSD CONFIG_NFSD_V3 CONFIG_NFSD_TCP,-e s"/^.*$(param)[= ].*/$(param)=m/")
endif
else
if KERNEL26
NFSSERVER_SED_CONF=$(foreach param,CONFIG_NFSD CONFIG_NFSD_V3 CONFIG_NFSD_TCP,-e s"/^.*$(param)[= ].*/\# $(param) is not set/")
else
NFSSERVER_SED_CONF=-e ""
endif
endif

kernel-cdk: $(bootprefix)/kernel-cdk

if KERNEL26
$(bootprefix)/kernel-cdk: linuxdir $(hostprefix)/bin/mkimage Patches/linux-$(KERNELVERSION).config Patches/dbox2-flash.c-26.m4
	sed $(IDE_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(NFSSERVER_SED_CONF) Patches/linux-$(KERNELVERSION).config \
		> $(KERNEL_DIR)/.config
	m4 Patches/dbox2-flash.c-26.m4 > linux/drivers/mtd/maps/dbox2-flash.c
else
$(bootprefix)/kernel-cdk: linuxdir $(hostprefix)/bin/mkimage Patches/linux-2.4.35.5-dbox2.config Patches/dbox2-flash.c.m4
	sed $(IDE_SED_CONF) $(EXT3_SED_CONF) $(XFS_SED_CONF) $(NFSSERVER_SED_CONF) Patches/linux-2.4.35.5-dbox2.config \
		> $(KERNEL_DIR)/.config
	m4 Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
endif
	$(MAKE) $(KERNEL_BUILD_FILENAME)
if KERNEL26
# not tested
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $@
else
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 \
		-d $(KERNEL_BUILD_FILENAME) \
		$@
endif
	chmod 644 $@
	$(INSTALL) -m644 $(KERNEL_DIR)/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
	$(INSTALL) -m644 $(KERNEL_DIR)/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)
	$(INSTALL) -d $(targetprefix)/tmp
	$(INSTALL) -d $(targetprefix)/proc
	$(INSTALL) -d $(targetprefix)/var/run

driver: $(KERNEL_BUILD_FILENAME)
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(driverdir) \
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
