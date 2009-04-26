# Bootloader: u-boot
#
# This target builds a u-boot, assuming that u-boot.config has been 
# setup correctly.
# Therefore, it depends on $(bootdir)/u-boot-config/u-boot.config, which the 
# Makefile does not have as an explicit target.
# This is deliberate, and makes the target sort-of "private".

@DIR_uboot@/u-boot.stripped: bootstrap @DEPENDS_uboot@ $(bootdir)/u-boot-config/u-boot.config
	@PREPARE_uboot@
	cp -pR $(bootdir)/u-boot-tuxbox/* @DIR_uboot@
	cd @DIR_uboot@ && patch -p1 -E -i ../Patches/u-boot-1.2.0.diff
	cp -p $(bootdir)/u-boot-config/u-boot.config @DIR_uboot@/include/configs/dbox2.h
	$(MAKE) -C @DIR_uboot@ dbox2_config
	$(MAKE) -C @DIR_uboot@ CROSS_COMPILE=$(target)- u-boot.stripped
	$(INSTALL) @DIR_uboot@/tools/mkimage $(hostprefix)/bin
#	@CLEANUP_uboot@
#	touch $@

if BOXTYPE_IPBOX
@DIR_uboot@/u-boot.ipbox: bootstrap @DEPENDS_uboot@ $(bootdir)/u-boot-config/u-boot.config
	@PREPARE_uboot@
	cp -pR $(bootdir)/u-boot-tuxbox/* @DIR_uboot@
	cd @DIR_uboot@ && patch -p1 -E -i ../Patches/u-boot-1.2.0-ipbox.diff
	cp -p $(bootdir)/u-boot-config/u-boot.config u-boot-1.2.0/include/configs/$(UBOOT_TEMPLATE)
if BOXMODEL_IP200
	$(MAKE) -C u-boot-1.2.0 relook100s_config
endif
if BOXMODEL_IP250
	$(MAKE) -C u-boot-1.2.0 relook200s_config
endif
if BOXMODEL_IP350
	$(MAKE) -C u-boot-1.2.0 relook210_config
endif
	$(MAKE) -C u-boot-1.2.0 CROSS_COMPILE=$(target)-
#	@CLEANUP_uboot@
#	touch $@
endif

yadd-u-boot: $(bootprefix)/u-boot $(bootprefix)/u-boot-yadd

if KERNEL26
$(bootprefix)/u-boot \
$(hostprefix)/bin/mkimage: @DEPENDS_uboot@ $(bootdir)/u-boot-config/u-boot.cdk.2_6.dbox2.h
	ln -sf ./u-boot.cdk.2_6.dbox2.h $(bootdir)/u-boot-config/u-boot.config
else 
$(bootprefix)/u-boot \
$(hostprefix)/bin/mkimage: @DEPENDS_uboot@ $(bootdir)/u-boot-config/u-boot.cdk.dbox2.h
	ln -sf ./u-boot.cdk.dbox2.h $(bootdir)/u-boot-config/u-boot.config
endif
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(INSTALL) -d $(bootprefix)
	$(INSTALL) -m644 @DIR_uboot@/u-boot.stripped $(bootprefix)/u-boot
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

$(bootprefix)/u-boot-yadd: @DEPENDS_uboot@ $(bootdir)/u-boot-config/u-boot.yadd.dbox2.h $(bootprefix)/README.u-boot
	ln -sf ./u-boot.yadd.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(INSTALL) -d $(bootprefix)
	$(INSTALL) -m644 @DIR_uboot@/u-boot.stripped $@
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

$(bootprefix)/README.u-boot:
	@echo "The default u-boot relies on a DHCP-server (a bootp server will not"	 > $@
	@echo "do) to tell the name of the kernel file, and the location of the"	>> $@
	@echo "NFS-root. Sometimes this is not available, for example when using the"	>> $@
	@echo "Windows dBox manager. For these cases, an alternate u-boot is"		>> $@
	@echo "provided, which, out-of-the-box, has the file name u-boot-yadd. This"	>> $@
	@echo "offers less flexibility, having most file names/paths compiled in. Using">> $@
	@echo "this u-boot for booting, the file name of the kernel is \"kernel-yadd",\"	>> $@
	@echo "and the NFS root will be \"yaddroot\"."					>> $@
