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
bare-os: yadd-u-boot kernel-cdk driver busybox module_init_tools \
		tuxbox_hotplug tuxinfo misc_tools
else
bare-os: yadd-u-boot kernel-cdk driver busybox modutils tuxinfo misc_tools
endif
	@TUXBOX_YADD_CUSTOMIZE@

yadd-none: bare-os config tuxbox_tools procps lcd ftpd yadd-ucodes yadd-bootlogos @AUTOMOUNT@ @LIRC@ @CDKVCINFO@ @XFSPROGS@ @NFSSERVER@ @SAMBASERVER@ @LUFS@ @SMBMOUNT@ @REISERFSPROGS@ @CONSOLE_TOOLS@ @OPENVPN@ version defaultlocale
	@TUXBOX_YADD_CUSTOMIZE@

yadd-none-etc: yadd-none yadd-etc
	@TUXBOX_YADD_CUSTOMIZE@

yadd-micro-neutrino: bare-os config yadd-ucodes camd2 switch neutrino
	@TUXBOX_YADD_CUSTOMIZE@

yadd-neutrino: neutrino-plugins yadd-none-etc @FX2PLUGINS@ @ESOUND@ neutrino
	@TUXBOX_YADD_CUSTOMIZE@

yadd-enigma: yadd-none-etc enigma-plugins @FX2PLUGINS@ enigma
	@TUXBOX_YADD_CUSTOMIZE@

yadd-lcars: yadd-none-etc lcars
	@TUXBOX_YADD_CUSTOMIZE@

yadd-radiobox: yadd-none-etc radiobox
	@TUXBOX_YADD_CUSTOMIZE@

yadd-all: yadd-none-etc plugins neutrino enigma lcars @ESOUND@
	@TUXBOX_YADD_CUSTOMIZE@

yadd-bootlogos:
	$(INSTALL) -d $(targetprefix)/var/tuxbox/boot
	if [ -e $(logosdir)/logo-lcd  ] ; then \
		 cp $(logosdir)/logo-lcd $(targetprefix)/var/tuxbox/boot ; \
	fi
	if [ -e $(logosdir)/logo-fb ] ; then \
		 cp $(logosdir)/logo-fb $(targetprefix)/var/tuxbox/boot ; \
	fi

extra: libs libs_optional contrib_apps fun dvb_apps root_optional udev devel devel_optional
