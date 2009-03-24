all:
	@echo "You probably do not want to build all possible targets."
	@echo "Sensible targets are, e.g. yadd-enigma or flash-neutrino-jffs2-2x."
	@echo "If you REALLY want to build everything, then \"make everything\""

if TARGETRULESET_FLASH
everything: yadd-all flash-all-all-all serversupport extra 
else
everything: yadd-all extra serversupport
endif


if KERNEL26
bare-os: yadd-u-boot kernel-cdk driver yadd-etc busybox module_init_tools \
		tuxbox_hotplug tuxinfo misc_tools
else
bare-os: yadd-u-boot kernel-cdk driver yadd-etc busybox modutils tuxinfo misc_tools
endif
	@TUXBOX_YADD_CUSTOMIZE@

yadd-none: bare-os config tuxbox_tools procps ftpd yadd-ucodes yadd-bootlogos @AUTOMOUNT@ @LIRC@ @CDKVCINFO@ @XFSPROGS@ @NFSSERVER@ @SAMBASERVER@ @LUFS@ @SMBMOUNT@ @CONSOLE_TOOLS@ version defaultlocale
	@TUXBOX_YADD_CUSTOMIZE@

yadd-micro-neutrino: bare-os config yadd-ucodes camd2 switch neutrino
	@TUXBOX_YADD_CUSTOMIZE@

yadd-neutrino: yadd-none neutrino-plugins fx2-plugins neutrino
	@TUXBOX_YADD_CUSTOMIZE@

yadd-enigma: yadd-none enigma-plugins fx2-plugins enigma
	@TUXBOX_YADD_CUSTOMIZE@

yadd-lcars: yadd-none lcars
	@TUXBOX_YADD_CUSTOMIZE@

yadd-radiobox: yadd-none radiobox
	@TUXBOX_YADD_CUSTOMIZE@

yadd-all: yadd-none plugins neutrino enigma lcars
	@TUXBOX_YADD_CUSTOMIZE@

yadd-bootlogos:
	$(INSTALL) -d $(bootprefix)
	if [ -e $(logosdir)/logo-lcd  ] ; then \
		 cp $(logosdir)/logo-lcd $(bootprefix) ; \
	fi
	if [ -e $(logosdir)/logo-fb ] ; then \
		 cp $(logosdir)/logo-fb $(bootprefix) ; \
	fi

extra: libs libs_optional contrib_apps fun dvb_apps root_optional udev devel bash
