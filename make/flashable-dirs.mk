# This section builds directories that can be used to create filesystems
#
# Pattern: $partition-$gui[-$filesystem]

if ENABLE_IDE
HDD_MOUNT_ENTRY=/dev/ide/host0/bus0/target0/lun0/part2	/hdd	$(DEFAULT_FS_FSTAB)	\
defaults	1 2
endif

$(flashprefix)/var-neutrino $(flashprefix)/var-enigma $(flashprefix)/var-radiobox: \
$(flashprefix)/var-%: \
$(flashprefix)/root-% $(flashprefix)/root
	rm -rf $@
	cp -rd $</var $@
	cp -rd $(flashprefix)/root/var/* $@
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$(flashprefix)/.junk flashprefix_rw=$@
	rm -rf $(flashprefix)/.junk
	if [ -d $(flashprefix)/root/etc/ssh ] ; then \
		cp -rd $(flashprefix)/root/etc/ssh $@/etc/ssh ; \
	fi
	if [ -e $(flashprefix)/root/etc/profile.local ]; then \
		cp $(flashprefix)/root/etc/profile.local $@/etc; \
	fi
	$(INSTALL) -d $@/plugins
	$(INSTALL) -d $@/tuxbox/plugins
	$(MAKE) -C $(appsdir)/tuxbox/tools/camd install prefix=$@
	$(target)-strip --remove-section=.comment --remove-section=.note $@/bin/camd2
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/var-enigma+neutrino: \
$(flashprefix)/root-neutrino $(flashprefix)/root-enigma $(flashprefix)/root
	rm -rf $@
	cp -rd $(flashprefix)/root/var $@
	cp -rd $(flashprefix)/root-neutrino/var/* $@
	cp -rd $(flashprefix)/root-enigma/var/* $@
if !BOXTYPE_DREAMBOX
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/tuxbox/boot
endif
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$(flashprefix)/.junk flashprefix_rw=$@
	rm -rf $(flashprefix)/.junk
	if [ -d $(flashprefix)/root/etc/ssh ] ; then \
		cp -rd $(flashprefix)/root/etc/ssh $@/etc/ssh ; \
	fi
	if [ -e $(flashprefix)/root/etc/profile.local ]; then \
		cp $(flashprefix)/root/etc/profile.local $@/etc; \
	fi
	$(INSTALL) -d $@/plugins
	$(INSTALL) -d $@/tuxbox/plugins
	$(MAKE) -C $(appsdir)/tuxbox/tools/camd install prefix=$@
	$(target)-strip --remove-section=.comment --remove-section=.note $@/bin/camd2
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-neutrino-jffs2 $(flashprefix)/root-enigma-jffs2 \
$(flashprefix)/root-lcars-jffs2 \
$(flashprefix)/root-radiobox-jffs2: \
$(flashprefix)/root-%-jffs2: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-jffs2
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-jffs2/* $@
	rm -rf $@/man $@/share/man
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$</lib:$</lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$(flashprefix)/root-jffs2/lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$@
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
if !KERNEL26
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
endif
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
endif
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-neutrino-cramfs $(flashprefix)/root-neutrino-squashfs: \
$(flashprefix)/root-neutrino-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-neutrino
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-neutrino/* $@
	rm -rf $@/man $@/share/man
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-neutrino/lib:$(flashprefix)/root-neutrino/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
# ugly hack: neutrino uses the slightly different satellites.xml format from dbox
	if [ -e $@/bin/neutrino ]; then \
		cp $(flashprefix)/root/share/tuxbox/satellites.xml $@/share/tuxbox/satellites.xml; \
	fi
else
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
endif
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
if !BOXTYPE_DREAMBOX
	ln -sf /var/bin/camd2 $@/bin/camd2
endif
	if [ -e $@/etc/profile.local ]; then \
		rm $@/etc/profile.local; \
		ln -sf /var/etc/profile.local $@/etc/profile.local; \
	fi
	if [ -f $@/lib/libgcc_s_nof.so.1 -a ! -f $@/lib/libgcc_s.so.1 ]; then \
		ln -s libgcc_s_nof.so.1 $@/lib/libgcc_s.so.1; \
	fi
if !KERNEL26
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
endif
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-radiobox-cramfs $(flashprefix)/root-radiobox-squashfs: \
$(flashprefix)/root-radiobox-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-radiobox
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-radiobox/* $@
	rm -rf $@/man $@/share/man
	cp -rd $(flashprefix)/root/lib/tuxbox/plugins/libfx2.so $@/lib/tuxbox/plugins
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-radiobox/lib:$(flashprefix)/root-radiobox/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	cp $(targetprefix)/lib/libstdc++.so.6.0.3 $@/lib/
	ln -sf libstdc++.so.6.0.3 $@/lib/libstdc++.so.6
	ln -sf libstdc++.so.6.0.3 $@/lib/libstdc++.so
	ls -l $@/lib/
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
endif
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/bin/camd2 $@/bin/camd2
	if [ -e $@/etc/profile.local ]; then \
		rm $@/etc/profile.local; \
		ln -sf /var/etc/profile.local $@/etc/profile.local; \
	fi
if !KERNEL26
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
endif
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-enigma-cramfs $(flashprefix)/root-enigma-squashfs: \
$(flashprefix)/root-enigma-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-enigma
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-enigma/* $@
	rm -rf $@/man $@/share/man
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-enigma/lib:$(flashprefix)/root-enigma/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
endif
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/etc/localtime $@/etc/localtime
if !BOXTYPE_DREAMBOX
	ln -sf /var/bin/camd2 $@/bin/camd2
endif
	if [ -e $@/etc/profile.local ]; then \
		rm $@/etc/profile.local; \
		ln -sf /var/etc/profile.local $@/etc/profile.local; \
	fi
if !KERNEL26
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
endif
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-enigma+neutrino-squashfs: \
$(flashprefix)/root-enigma+neutrino-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-neutrino $(flashprefix)/root-enigma flash-lcdmenu
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-neutrino/* $@
	cp -rd $(flashprefix)/root-enigma/* $@
	rm -rf $@/man $@/share/man
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-neutrino/lib:$(flashprefix)/root-neutrino/lib/tuxbox/plugins:$(flashprefix)/root-enigma/lib:$(flashprefix)/root-enigma/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
endif
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/etc/localtime $@/etc/localtime
if !BOXTYPE_DREAMBOX
	ln -sf /var/bin/camd2 $@/bin/camd2
endif
	if [ -e $@/etc/profile.local ]; then \
		rm $@/etc/profile.local; \
		ln -sf /var/etc/profile.local $@/etc/profile.local; \
	fi
	if [ -f $@/lib/libgcc_s_nof.so.1 -a ! -f $@/lib/libgcc_s.so.1 ]; then \
		ln -s libgcc_s_nof.so.1 $@/lib/libgcc_s.so.1; \
	fi
if !KERNEL26
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
endif
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-null-jffs2: $(flashprefix)/root $(flashprefix)/root-jffs2
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $(flashprefix)/root-jffs2/* $@
	rm -rf $@/man $@/share/man
	rm -rf $@/lib/tuxbox/plugins
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root/lib:$(flashprefix)/root-jffs2/lib:$(targetprefix)/lib
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$@
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
	@TUXBOX_CUSTOMIZE@

## "Private"
flash-bootlogos:
	$(INSTALL) -d $(flashbootlogosdir)
	if [ -e $(logosdir)/logo-lcd  ] ; then \
		 cp $(logosdir)/logo-lcd $(flashbootlogosdir) ; \
	fi
	if [ -e $(logosdir)/logo-fb ] ; then \
		 cp $(logosdir)/logo-fb $(flashbootlogosdir) ; \
	fi

if BOXTYPE_DREAMBOX
if BOXMODEL_DM7000
$(flashprefix)/boot: @DEPENDS_dreamdriver_dm7000@ @DEPENDS_dreamfiles@
	@PREPARE_dreamfiles@
	@PREPARE_dreamdriver_dm7000@
endif
if BOXMODEL_DM56x0
$(flashprefix)/boot: @DEPENDS_dreamdriver_dm56x0@ @DEPENDS_dreamfiles@
	@PREPARE_dreamfiles@
	@PREPARE_dreamdriver_dm56x0@
endif
if BOXMODEL_DM500
$(flashprefix)/boot: @DEPENDS_dreamdriver_dm500@ @DEPENDS_dreamfiles@
	@PREPARE_dreamfiles@
	@PREPARE_dreamdriver_dm500@
endif
	@for i in dreamfiles boot mkcramfs-e mksquashfs mklibs.py mksquashfs_lzma_patches.tar.bz2 ; do \
		rm -R $(flashprefix)/$$i 2>/dev/null || /bin/true; \
		mv $$i $(flashprefix) 2>/dev/null || /bin/true; \
	done

flash-dreamfiles: $(dreamfilesrootdir)/dreamfiles/lib/modules/2.6.9/extra/head.ko

$(dreamfilesrootdir)/dreamfiles/lib/modules/2.6.9/extra/head.ko : $(flashprefix)/boot 
	@cp -R $(flashprefix)/dreamfiles/bin/* $(dreamfilesrootdir)
	@cp -R $(flashprefix)/dreamfiles/share/* $(dreamfilesrootdir)
	@if [ -f $(flashprefix)/dreamfiles/.version ] ; then \
		cp $(flashprefix)/dreamfiles/.version $(dreamfilesrootdir); \
	fi
# var_init
	@for i in log mnt mnt/cf mnt/nfs mnt/usb tuxbox/plugins tuxbox/config ; do \
		$(INSTALL) -d $(dreamfilesrootdir)/var_init/$$i; \
	done;
	rm -f  $(dreamfilesrootdir)/var_init/run; ln -s /tmp/run $(dreamfilesrootdir)/var_init/
	for i in tuxtxt enigma/cable enigma/fonts enigma/pictures enigma/resources enigma/skins enigma/terrestrial; do \
		$(INSTALL) -d $(dreamfilesrootdir)/var_init/tuxbox/config/$$i; \
	done;
	$(INSTALL) -d $(dreamfilesrootdir)/var_init/tuxbox/config/zapit;
	@ln -sf /tmp $(dreamfilesrootdir)/var_init/tmp
	@ln -sf /proc/mounts $(dreamfilesrootdir)/var_init/etc/mtab
# lib
	@for i in ar_AE cs_CZ da_DK el_GR es_ES et_EE fi_FI hr_HR \
	hu_HU is_IS it_IT lt_LT nl_NL no_NO pl_PL pt_PT ro_RO ru_RU sk_SK \
	sl_SI sr_YU sv_SE tr_TR ur_IN; do \
		ln -sf de_DE $(dreamfilesrootdir)/lib/locale/$$i; \
	done;
if !TARGETRULESET_UCLIBC
	@for i in ISO8859-1.so ISO8859-2.so ISO8859-7.so UNICODE.so; do \
		cp $(targetprefix)/lib/gconv/$$i $(dreamfilesrootdir)/lib/gconv; \
	done;
	ln -sf libgcc_s_nof.so.1 $(dreamfilesrootdir)/lib/libgcc_s.so.1
endif
if BOXMODEL_DM500
	for i in cables.xml satellites.xml terrestrial.xml; do \
		ln -sf tuxbox/$$i $(dreamfilesrootdir)/share; \
	done;
else
	@ln -sf tuxbox/satellites.xml $(dreamfilesrootdir)/share;
endif
# misc
	@ln -sf /var/mnt $(dreamfilesrootdir)/mnt
if !BOXMODEL_DM7000
	echo "i:/ezap/osd/alpha=00000000" >> $(dreamfilesrootdir)/var_init/tuxbox/config/enigma/config;
	echo "i:/ezap/osd/brightness=00000073" >> $(dreamfilesrootdir)/var_init/tuxbox/config/enigma/config;
	echo "i:/ezap/osd/gamma=00000066" >> $(dreamfilesrootdir)/var_init/tuxbox/config/enigma/config;
endif
if !BOXMODEL_DM56x0
	@for i in skins/small_red*.esml skins/small_red*.info pictures/small-red pictures/triaxlogo-fs8.png ; do \
		rm -Rf $(dreamfilesrootdir)/share/tuxbox/enigma/$$i; done
endif
if !BOXMODEL_DM500
	@for i in cables.xml terrestrial.xml; do \
		if [ -f $(dreamfilesrootdir)/share/tuxbox/$$i ]; then \
			rm $(dreamfilesrootdir)/share/tuxbox/$$i; \
		fi; \
	done;
endif
endif
