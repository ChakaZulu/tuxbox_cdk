# the following if-statements look silly, but:
# http://www.gnu.org/software/automake/manual/html_node/Conditionals.html#Conditionals
# "You may only test a single variable in an if statement"
if ENABLE_IDE
BB_IDE=-Dide
endif
if ENABLE_MMC
BB_IDE=-Dide
endif

if ENABLE_EXT3
BB_EXT3=-Dextfs
endif
if ENABLE_EXT2
BB_EXT3=-Dextfs
endif

if KERNEL26
BB_KERNEL26=-Dkernel26
endif
if ENABLE_FS_CIFS
BB_CIFS=-Dcifs
endif
# this option is not used for yadd builds, they need nfs for booting
if ENABLE_FS_NFS
BB_NFS=-Dnfs
endif

$(DEPDIR)/busybox: bootstrap @DEPENDS_busybox@ $(busybox_conf) Patches/busybox.diff
	@PREPARE_busybox@
	m4 -Dyadd $(BB_IDE) $(BB_EXT3) $(BB_KERNEL26) $(BB_CIFS) $(BB_NFS) -DPREFIX="\"$(targetprefix)\"" -Dcustomizationsdir=$(customizationsdir) $(busybox_conf) > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) all install \
			CROSS_COMPILE=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	@CLEANUP_busybox@
	touch $@


if TARGETRULESET_FLASH

flash-busybox: bootstrap $(flashprefix)/root @DEPENDS_busybox@ $(busybox_conf) Patches/busybox.diff
	@PREPARE_busybox@
	m4 -Dflash $(BB_IDE) $(BB_EXT3) $(BB_KERNEL26) $(BB_CIFS) $(BB_NFS) -DPREFIX="\"$(flashprefix)/root\"" -Dcustomizationsdir=$(customizationsdir) $(busybox_conf) > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) all install \
			CROSS_COMPILE=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	@CLEANUP_busybox@
	@FLASHROOTDIR_MODIFIED@

endif

.PHONY: flash-busybox
