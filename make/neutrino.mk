# tuxbox/neutrino

if ENABLE_MOVIEPLAYER2
CONFIGURE_OPTS_MP2 = \
	--enable-movieplayer2
endif

$(appsdir)/tuxbox/neutrino/config.status: bootstrap $(appsdir)/dvb/zapit/src/zapit libboost libcurl libfreetype @ESOUND@ @NEUTRINO_AUDIOPLAYER_DEPS@ @NEUTRINO_PICTUREVIEWER_DEPS@ $(targetprefix)/lib/pkgconfig/tuxbox-tuxtxt.pc $(targetprefix)/include/tuxbox/plugin.h
	cd $(appsdir)/tuxbox/neutrino && $(CONFIGURE) $(CONFIGURE_OPTS_MP2)

neutrino: $(appsdir)/tuxbox/neutrino/config.status
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install
	$(MAKE) neutrino-additional-fonts

if TARGETRULESET_FLASH
flash-neutrino: $(flashprefix)/root-neutrino

$(flashprefix)/root-neutrino: $(appsdir)/tuxbox/neutrino/config.status
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install prefix=$@
	$(MAKE) -C $(appsdir)/dvb/zapit install prefix=$@
	$(MAKE) neutrino-additional-fonts targetprefix=$@
if ENABLE_ESD
	$(INSTALL) $(targetprefix)/bin/esd $@/bin
endif
	touch $@
	@TUXBOX_CUSTOMIZE@

endif

# This is really an ugly kludge. Neutrino and the plugins should
# install the fonts they need in their own Makefiles.
neutrino-additional-fonts:
	cp $(appsdir)/tuxbox/enigma/data/fonts/bluebold.ttf $(targetprefix)/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/bluehigh.ttf $(targetprefix)/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/pakenham.ttf $(targetprefix)/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/unmrs.pfa    $(targetprefix)/share/fonts
