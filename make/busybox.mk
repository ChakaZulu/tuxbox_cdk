
BUSYBOX_M4 = -D$(BOXTYPE)
BUSYBOX_M4 += -Dcustomizationsdir=$(customizationsdir)

# the following if-statements look silly, but:
# http://www.gnu.org/software/automake/manual/html_node/Conditionals.html#Conditionals
# "You may only test a single variable in an if statement"
if ENABLE_IDE
BUSYBOX_M4 += -Dide
endif
if ENABLE_MMC
BUSYBOX_M4 += -Dide
endif

if ENABLE_EXT3
BUSYBOX_M4 += -Dextfs
endif
if ENABLE_EXT2
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

$(DEPDIR)/busybox: bootstrap @DEPENDS_busybox@ $(busybox_conf)
	@PREPARE_busybox@
	m4 $(BUSYBOX_M4) -Dyadd $(busybox_conf) | m4 -DPREFIX="\"$(targetprefix)\"" > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) all install \
			CROSS_COMPILE=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	@CLEANUP_busybox@
	touch $@


if TARGETRULESET_FLASH

flash-busybox: bootstrap $(flashprefix)/root @DEPENDS_busybox@ $(busybox_conf)
	@PREPARE_busybox@
	m4 $(BUSYBOX_M4) -Dflash $(busybox_conf) | m4 -DPREFIX="\"$(flashprefix)/root\"" > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) all install \
			CROSS_COMPILE=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	@CLEANUP_busybox@
	@FLASHROOTDIR_MODIFIED@

endif

.PHONY: flash-busybox
