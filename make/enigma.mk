# tuxbox/enigma
if ENABLE_FREESATEPG
CONFIGURE_OPTS_EPG = \
	--enable-freesatepg
endif

$(appsdir)/tuxbox/enigma/config.status: bootstrap libfreetype libfribidi libmad libid3tag libvorbisidec libpng libsigc libjpeg libungif @LIBGETTEXT@ @SQLITE@ @REISERFSPROGS@ $(targetprefix)/lib/pkgconfig/tuxbox.pc $(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc $(targetprefix)/include/tuxbox/plugin.h
	cd $(appsdir)/tuxbox/enigma && $(CONFIGURE) \
		  --with-webif=$(WEBIF) \
		  --with-epg=$(EPG) \
		  --with-flashtool=$(FLASHTOOL) \
		  --with-ext-flashtool=$(EXTFLASHTOOL) \
		  --with-enigma-debug=$(ENIGMA_DEBUG) \
		  --with-reiserfs=$(ENIGMA_REISERFS) \
		  --with-mhw-epg=$(MHW_EPG) \
		  $(CONFIGURE_OPTS_EPG)

enigma: $(appsdir)/tuxbox/enigma/config.status | tuxbox_tools
	$(MAKE) -C $(appsdir)/tuxbox/enigma all install

if TARGETRULESET_FLASH

# $(targetprefix)/share/locale/*/LC_MESSAGES/libc.mo and
# $(targetprefix)/share/zoneinfo are from the glibc installation

flash-enigma: $(flashprefix)/root-enigma

$(flashprefix)/root-enigma: $(appsdir)/tuxbox/enigma/config.status
	$(MAKE) -C $(appsdir)/tuxbox/enigma all install prefix=$@
	$(INSTALL) $(appsdir)/dvb/zapit/src/scart.conf $@/var/tuxbox/config
	cp $(appsdir)/tuxbox/neutrino/data/fonts/*.pcf.gz $@/share/fonts
	cp $(appsdir)/tuxbox/neutrino/data/fonts/micron*.ttf $@/share/fonts
if BOXTYPE_DREAMBOX
	$(INSTALL) -d $@/share/locale
	@for i in `find $(targetprefix)/share/locale -name "tuxbox-enigma.mo"` ; \
		do cp -pa $${i%%/LC_MESSAGES/tuxbox-enigma.mo} $@/share/locale; done
	@rm -rf $@/share/locale/LC_MESSAGES
	@find $@/share/locale -name libc.mo -o -name nano.mo | xargs rm -f
	$(INSTALL) $(appsdir)/tuxbox/enigma/po/locale.alias $@/share/locale
	mkdir $@/lib
	tar -C $@/lib -xjvf $(appsdir)/tuxbox/enigma/po/locale.image.tar.bz2
	$(INSTALL) -d $@/share/tuxbox/enigma
	$(INSTALL) -d $@/var_init/tuxbox/config/enigma

	@for i in `find $@/share/tuxbox/enigma/htdocs` ; do \
		case $$i in \
		*/rc_dbox2.jpg | */rc_dbox2_small.jpg | */topbalk?.png | */topbalk?_small.png) \
			rm $$i;; \
		esac; \
	done;
if BOXMODEL_DM7000
	@for i in `find $@/share/tuxbox/enigma/resources -type f` ; do \
		case $$i in \
		/*keymappings.xml | */rcdboxold.xml | \
		*/rcdm7000.xml | */rcdreambox_keyboard.xml ) ;; \
		*) rm $$i;; \
		esac; \
	done;
else
	CURRENT_PATH=`pwd` && \
	cd $@/share/tuxbox/enigma/skins && \
	patch -p0 < $$CURRENT_PATH/Patches/default_lc.esml.diff
	@for i in `find $@/share/tuxbox/enigma/resources -type f` ; do \
		case $$i in \
		/*keymappings.xml | */rcdboxold.xml | \
		*/rcdm5xxx.xml | */rcdreambox_keyboard.xml ) ;; \
		*) rm $$i;; \
		esac; \
	done;
endif
	rm -f $@/share/zoneinfo/*tab
if !TARGETRULESET_UCLIBC
	ln -sf /var/etc/localtime $@/etc
endif
	@for i in ar_AE cs_CZ da_DK el_GR es_ES et_EE fi_FI hr_HR \
	hu_HU is_IS it_IT lt_LT nl_NL no_NO pl_PL pt_PT ro_RO ru_RU sk_SK \
	sl_SI sr_YU sv_SE tr_TR ur_IN; do \
		ln -sf de_DE $@/lib/locale/$$i; \
	done;
if !BOXMODEL_DM7000
	echo "i:/ezap/osd/alpha=00000000" >> $@/var_init/tuxbox/config/enigma/config;
	echo "i:/ezap/osd/brightness=00000073" >> $@/var_init/tuxbox/config/enigma/config;
	echo "i:/ezap/osd/gamma=00000066" >> $@/var_init/tuxbox/config/enigma/config;
endif
if !BOXMODEL_DM56x0
	@for i in skins/small_red*.esml skins/small_red*.info pictures/small-red pictures/triaxlogo-fs8.png ; do \
		rm -Rf $@/share/tuxbox/enigma/$$i; done
endif

else
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
endif


	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/dbswitch all install prefix=$@
#	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/demo all install prefix=$@
if BOXTYPE_DREAMBOX
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/dreamdata all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/dreamflash all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/movieplayer all install prefix=$@
endif
#	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/dslconnect all install prefix=$@
#	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/dsldisconnect all install prefix=$@
#	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/getset all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/ngrabstart all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/ngrabstop all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/rss all install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/script all install prefix=$@
#	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma/weather all install prefix=$@
	@TUXBOX_CUSTOMIZE@

endif
