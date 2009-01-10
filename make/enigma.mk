# tuxbox/enigma

if TARGETRULESET_UCLIBC
ENIGMA_GETTEXT=libgettext
endif

if ENABLE_SQLITE
ENIGMA_SQLITE=sqlite
endif

$(appsdir)/tuxbox/enigma/config.status: bootstrap libfreetype libfribidi libmad libid3tag libvorbisidec libpng libsigc libjpeg libungif $(ENIGMA_GETTEXT) $(ENIGMA_SQLITE) $(targetprefix)/lib/pkgconfig/tuxbox.pc $(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc $(targetprefix)/include/tuxbox/plugin.h
	cd $(appsdir)/tuxbox/enigma && $(CONFIGURE)

enigma: $(appsdir)/tuxbox/enigma/config.status | tuxbox_tools
	$(MAKE) -C $(appsdir)/tuxbox/enigma all install

if TARGETRULESET_FLASH

# $(targetprefix)/share/locale/*/LC_MESSAGES/libc.mo and
# $(targetprefix)/share/zoneinfo are from the glibc installation

flash-enigma: $(flashprefix)/root-enigma

$(flashprefix)/root-enigma: $(appsdir)/tuxbox/enigma/config.status
	$(MAKE) -C $(appsdir)/tuxbox/enigma all install prefix=$@
	$(INSTALL) $(appsdir)/tuxbox/neutrino/daemons/controld/scart.conf $@/var/tuxbox/config
	cp $(appsdir)/tuxbox/neutrino/data/fonts/*.pcf.gz $@/share/fonts
	cp $(appsdir)/tuxbox/neutrino/data/fonts/micron*.ttf $@/share/fonts
	cp -pa $(appsdir)/tuxbox/enigma/po/locale.alias.image $@/share/locale/locale.alias
	mkdir $@/lib
	tar -C $@/lib -xjvf $(appsdir)/tuxbox/enigma/po/locale.image.tar.bz2
if !TARGETRULESET_UCLIBC
	cp -rd $(targetprefix)/share/zoneinfo $@/share
	cp -rd $(targetprefix)/share/locale/de/LC_MESSAGES/libc.mo $@/share/locale/de/LC_MESSAGES
	cp -rd $(targetprefix)/share/locale/fr/LC_MESSAGES/libc.mo $@/share/locale/fr/LC_MESSAGES
endif
	rm -rf $@/share/locale/[a-c]* $@/share/locale/da $@/share/locale/e* $@/share/locale/fi $@/share/locale/[g-t]* $@/share/locale/[m-z]*
	cp $(appsdir)/tuxbox/enigma/po/locale.alias.image $@/share/locale/locale.alias
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/dbswitch all install prefix=$@
#	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/demo all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/dreamdata all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/dreamflash all install prefix=$@
#	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/dslconnect all install prefix=$@
#	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/dsldisconnect all install prefix=$@
#	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/getset all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/movieplayer all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/ngrabstart all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/ngrabstop all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/rss all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/script all install prefix=$@
#	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/weather all install prefix=$@
	@TUXBOX_CUSTOMIZE@

endif
