
BUSYBOX_M4 = -D$(BOXTYPE)
BUSYBOX_M4 += -Dcustomizationsdir=$(customizationsdir)

if ENABLE_IDEMMC
BUSYBOX_M4 += -Dide
if !ENABLE_FDISK_STANDALONE
BUSYBOX_M4 += -Dfdisk
endif
endif
if ENABLE_EXTFS
BUSYBOX_M4 += -Dextfs
endif
if KERNEL26
BUSYBOX_M4 += -Dkernel26
endif
if ENABLE_FS_CIFS
BUSYBOX_M4 += -Dcifs
endif
# this option is not used for yadd builds, they need nfs for booting
if ENABLE_FS_NFS
BUSYBOX_M4 += -Dnfs
endif

if ENABLE_OPENVPN
BUSYBOX_M4 += -Dopenvpn
endif

# this variable is needed because cdk/rules.pl assumes *.patch can be found in cdk/Patches
#BUSYBOX_PATCHES =

$(DEPDIR)/busybox: bootstrap @DEPENDS_busybox@ $(BUSYBOX_PATCHES) $(busybox_conf)
	@PREPARE_busybox@
	m4 $(BUSYBOX_M4) -Dyadd -DPREFIX=\`\"$(targetprefix)\"\' $(busybox_conf) > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) all install \
			CROSS_COMPILE=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	@CLEANUP_busybox@
	touch $@


if TARGETRULESET_FLASH

flash-busybox: bootstrap $(flashprefix)/root @DEPENDS_busybox@ $(BUSYBOX_PATCHES) $(busybox_conf)
	@PREPARE_busybox@
	m4 $(BUSYBOX_M4) -Dflash -DPREFIX=\`\"$(flashprefix)/root\"\' $(busybox_conf) > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) all install \
			CROSS_COMPILE=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	@CLEANUP_busybox@
	@FLASHROOTDIR_MODIFIED@

endif

.PHONY: flash-busybox
