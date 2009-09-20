# Bootloader: u-boot
#
# This target builds a u-boot, assuming that u-boot.config has been 
# setup correctly.
# Therefore, it depends on $(bootdir)/u-boot-config/u-boot.config, which the 
# Makefile does not have as an explicit target.
# This is deliberate, and makes the target sort-of "private".

@DIR_uboot@/u-boot.stripped: bootstrap_gcc @DEPENDS_uboot@ $(bootdir)/u-boot-config/u-boot.config
	@PREPARE_uboot@
	cp -pR $(bootdir)/u-boot-tuxbox/* @DIR_uboot@
	cd @DIR_uboot@ && patch -p1 -E -i ../Patches/u-boot-2009.08.diff
	cp -p $(bootdir)/u-boot-config/u-boot.config @DIR_uboot@/include/configs/dbox2.h
	$(MAKE) -C @DIR_uboot@ dbox2_config
	$(MAKE) -C @DIR_uboot@ CROSS_COMPILE=$(target)- u-boot.stripped
	$(INSTALL) @DIR_uboot@/tools/mkimage $(hostprefix)/bin

yadd-u-boot: $(bootprefix)/u-boot $(bootprefix)/README.u-boot
yadd-u-boot-bootmanager: $(bootprefix)/u-boot-yadd

$(bootprefix)/u-boot $(hostprefix)/bin/mkimage: @DEPENDS_uboot@
if KERNEL26
	m4 --define=uboottype=cdk26 config/u-boot.dbox2.h.m4 > $(bootdir)/u-boot-config/u-boot.config
else
	m4 --define=uboottype=cdk config/u-boot.dbox2.h.m4 > $(bootdir)/u-boot-config/u-boot.config
endif
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(INSTALL) -d $(bootprefix)
	$(INSTALL) -m644 @DIR_uboot@/u-boot.stripped $(bootprefix)/u-boot
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

$(bootprefix)/u-boot-yadd: @DEPENDS_uboot@
	m4 --define=uboottype=yadd config/u-boot.dbox2.h.m4 > $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(INSTALL) -d $(bootprefix)
	$(INSTALL) -m644 @DIR_uboot@/u-boot.stripped $@
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

ide-u-boot: $(flashprefix)/ide.flfs1x $(flashprefix)/ide.flfs2x

$(flashprefix)/ide.flfs1x $(flashprefix)/ide.flfs2x: \
$(hostprefix)/bin/mkflfs config/u-boot.dbox2.h.m4  \
| $(flashprefix)
	m4 --define=uboottype=ide config/u-boot.dbox2.h.m4 > $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 1x -o $(flashprefix)/ide.flfs1x @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 2x -o $(flashprefix)/ide.flfs2x @DIR_uboot@/u-boot.stripped
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

$(bootprefix)/README.u-boot:
	@echo "The default u-boot relies on a DHCP-server (a bootp server will not"	 > $@
	@echo "do) to tell the name of the kernel file, and the location of the"	>> $@
	@echo "NFS-root. Sometimes this is not available, for example when using the"	>> $@
	@echo "Windows dBox manager. For these cases, an alternate u-boot can be built"	>> $@
	@echo "by make yadd-u-boot-bootmanager, which will be named u-boot-yadd. This"	>> $@
	@echo "offers less flexibility, having most file names/paths compiled in. Using">> $@
	@echo "this u-boot for booting, the file name of the kernel is \"kernel-yadd",\"	>> $@
	@echo "and the NFS root will be \"yaddroot\"."					>> $@
