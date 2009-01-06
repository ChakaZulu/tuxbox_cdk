# tuxbox/plugins

$(appsdir)/tuxbox/plugins/config.status: bootstrap libfreetype libcurl libz libsigc libpng $(targetprefix)/lib/pkgconfig/tuxbox.pc $(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc $(targetprefix)/lib/pkgconfig/tuxbox-tuxtxt.pc
	cd $(appsdir)/tuxbox/plugins && $(CONFIGURE)

plugins: neutrino-plugins enigma-plugins fx2-plugins

neutrino-plugins: $(targetprefix)/include/tuxbox/plugin.h tuxmail tuxtxt tuxcom tuxcal vncviewer

fx2-plugins: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/fx2 all install

if TARGETRULESET_UCLIBC
enigma-plugins: libgettext $(appsdir)/tuxbox/plugins/config.status $(targetprefix)/include/tuxbox/plugin.h
else
enigma-plugins: $(appsdir)/tuxbox/plugins/config.status $(targetprefix)/include/tuxbox/plugin.h
endif
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma all install

$(targetprefix)/include/tuxbox/plugin.h \
$(targetprefix)/lib/pkgconfig/tuxbox-plugins.pc: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/include all install
	cp $(appsdir)/tuxbox/plugins/tuxbox-plugins.pc $(targetprefix)/lib/pkgconfig/tuxbox-plugins.pc

tuxmail: libfreetype $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxmail all install

if TARGETRULESET_FLASH
flash-tuxmail: libfreetype $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxmail all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@
endif

pluginx: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/pluginx all install

if TARGETRULESET_FLASH
flash-pluginx: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/pluginx all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@
endif

tuxtxt: $(appsdir)/tuxbox/plugins/config.status $(targetprefix)/include/tuxbox/plugin.h
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxtxt all install

if TARGETRULESET_FLASH
flash-tuxtxt: $(appsdir)/tuxbox/plugins/config.status tuxtxt $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxtxt install  prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@
endif

tuxcom: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxcom all install

if TARGETRULESET_FLASH
flash-tuxcom: $(appsdir)/tuxbox/plugins/config.status $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxcom all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@
endif

tuxcal: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxcal all install

if TARGETRULESET_FLASH
flash-tuxcal: $(appsdir)/tuxbox/plugins/config.status $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxcal all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@
endif

vncviewer: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/vncviewer all install

if TARGETRULESET_FLASH
flash-vncviewer: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/vncviewer all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

# $(appsdir)/tuxbox/plugins/fx2/*/Makefile.am are silly and should be
# rewritten.  In the meantime, use this kludge.
flash-fx2-plugins: fx2-plugins $(flashprefix)/root
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -m 755 $(appsdir)/tuxbox/plugins/fx2/[c-z]*/.libs/*.so $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -m 644 $(appsdir)/tuxbox/plugins/fx2/[c-z]*/*.cfg $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/share/tuxbox/sokoban 
	$(INSTALL) -m 0644 $(appsdir)/tuxbox/plugins/fx2/sokoban/*.xsb $(flashprefix)/root/share/tuxbox/sokoban
	if [ -e $(flashprefix)/root/lib/libfx2.so ]; then \
		if [ -e $(flashprefix)/root/lib/tuxbox/plugins/ ]; then \
			rm -f $(flashprefix)/root/lib/tuxbox/plugins/libfx2.so ; \
			ln -s /lib/libfx2.so $(flashprefix)/root/lib/tuxbox/plugins/libfx2.so; \
		fi ; \
	fi
	@FLASHROOTDIR_MODIFIED@
endif
