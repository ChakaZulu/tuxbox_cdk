if ENABLE_IDE
POSSIBLY_IDE=-Dide
endif
if ENABLE_EXT3
POSSIBLY_EXT3=-Dext3
endif
if KERNEL26
POSSIBLY_KERNEL26=-Dkernel26
endif

$(DEPDIR)/busybox: bootstrap @DEPENDS_busybox@ $(busybox_conf) Patches/busybox.diff
	@PREPARE_busybox@
	m4 -Dyadd $(POSSIBLY_IDE) $(POSSIBLY_EXT3) $(POSSIBLY_KERNEL26) -DPREFIX="\"$(targetprefix)\"" $(busybox_conf) > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) all install \
			CROSS_COMPILE=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	@CLEANUP_busybox@
	touch $@


if TARGETRULESET_FLASH

flash-busybox: bootstrap $(flashprefix)/root @DEPENDS_busybox@ $(busybox_conf) Patches/busybox.diff
	@PREPARE_busybox@
	m4 -Dflash $(POSSIBLY_IDE) $(POSSIBLY_EXT3) $(POSSIBLY_KERNEL26) -DPREFIX="\"$(flashprefix)/root\"" $(busybox_conf) > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) all install \
			CROSS_COMPILE=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)"
	@CLEANUP_busybox@
	@FLASHROOTDIR_MODIFIED@

endif

.PHONY: flash-busybox
