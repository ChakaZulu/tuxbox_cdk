# This section builds directories that can be used to create filesystems
#
# Pattern: $partition-$gui[-$filesystem]
 
# ide, hdd, swap mounts #####################################
if ENABLE_IDE
if ENABLE_DRIVE_GUI
HDD_MOUNT_ENTRY = "\# hdd / mmc partitions will be mounted after running setup from gui"
HDD_SWAP_ENTRY = "\# swaps will be mounted after running setup from gui"
else
HDD_MOUNT_ENTRY=/dev/ide/host0/bus0/target0/lun0/part2	/hdd	$(DEFAULT_FS_FSTAB)	\
defaults	1 2
HDD_SWAP_ENTRY=/dev/ide/host0/bus0/target0/lun0/part1 swap swap noauto 0 0
endif
endif

FSTAB_PATH = $(targetprefix)/etc/fstab

MK_FSTAB_IDEMOUNTS = \
	 	echo "$(HDD_SWAP_ENTRY)"	>> $(FSTAB_PATH); \
		echo "$(HDD_MOUNT_ENTRY)"	>> $(FSTAB_PATH)
# ###########################################################


# /var mounts ###############################################

if BOXTYPE_IPBOX
VAR_MOUNT_ENTRY=/dev/mtdblock/1
endif
if BOXTYPE_DBOX2
VAR_MOUNT_ENTRY=/dev/mtdblock/3
endif
 
MK_FSTAB_VARMOUNTS = echo "$(VAR_MOUNT_ENTRY)     /var     jffs2     defaults     0 0" >> $@/etc/fstab
############################################################

# remove man dirs
REMOVE_MANDIRS = rm -rf $@/man $@/share/man

$(flashprefix)/var-neutrino $(flashprefix)/var-enigma $(flashprefix)/var-radiobox: \
$(flashprefix)/var-%: \
$(flashprefix)/root-% $(flashprefix)/root
	rm -rf $@
	cp -rd $</var $@
	cp -rd $(flashprefix)/root/var/* $@
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$(flashprefix)/.junk flashprefix_rw=$@ flashprefix=$(flashprefix)/root
	rm -rf $(flashprefix)/.junk
	if [ -d $(flashprefix)/root/etc/ssh ] ; then \
		cp -rd $(flashprefix)/root/etc/ssh $@/etc/ssh ; \
	fi
	if [ -e $(flashprefix)/root/etc/profile.local ]; then \
		cp $(flashprefix)/root/etc/profile.local $@/etc; \
	fi
	$(INSTALL) -d $@/plugins
	$(INSTALL) -d $@/tuxbox/plugins
if BOXTYPE_DBOX2
	$(MAKE) -C $(appsdir)/tuxbox/tools/camd install prefix=$@
	$(target)-strip --remove-section=.comment --remove-section=.note $@/bin/camd2
endif
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
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$(flashprefix)/.junk flashprefix_rw=$@  flashprefix=$(flashprefix)/root
	rm -rf $(flashprefix)/.junk
	if [ -d $(flashprefix)/root/etc/ssh ] ; then \
		cp -rd $(flashprefix)/root/etc/ssh $@/etc/ssh ; \
	fi
	if [ -e $(flashprefix)/root/etc/profile.local ]; then \
		cp $(flashprefix)/root/etc/profile.local $@/etc; \
	fi
	$(INSTALL) -d $@/plugins
	$(INSTALL) -d $@/tuxbox/plugins
if BOXTYPE_DBOX2
	$(MAKE) -C $(appsdir)/tuxbox/tools/camd install prefix=$@
	$(target)-strip --remove-section=.comment --remove-section=.note $@/bin/camd2
endif
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
	$(REMOVE_MANDIRS)
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$</lib:$</lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$(flashprefix)/root-jffs2/lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$@ flashprefix=$(flashprefix)/root
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$@
endif
	$(MK_FSTAB_IDEMOUNTS)
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-neutrino-jffs2_lzma $(flashprefix)/root-enigma-jffs2_lzma \
$(flashprefix)/root-lcars-jffs2_lzma \
$(flashprefix)/root-radiobox-jffs2_lzma: \
$(flashprefix)/root-%-jffs2_lzma: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-jffs2_lzma
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-jffs2_lzma/* $@
	$(REMOVE_MANDIRS)
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$</lib:$</lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$(flashprefix)/root-jffs2_lzma/lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$@ flashprefix=$(flashprefix)/root
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
endif
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-neutrino-jffs2_lzma_klzma $(flashprefix)/root-enigma-jffs2_lzma_klzma \
$(flashprefix)/root-lcars-jffs2_lzma_klzma \
$(flashprefix)/root-radiobox-jffs2_lzma_klzma: \
$(flashprefix)/root-%-jffs2_lzma_klzma: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-jffs2_lzma_klzma
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-jffs2_lzma_klzma/* $@
	$(REMOVE_MANDIRS)
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$</lib:$</lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$(flashprefix)/root-jffs2_lzma_klzma/lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$@ flashprefix=$(flashprefix)/root
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
endif
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-neutrino-cramfs \
$(flashprefix)/root-neutrino-squashfs \
$(flashprefix)/root-neutrino-squashfs_nolzma: \
$(flashprefix)/root-neutrino-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-neutrino
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-neutrino/* $@
	$(REMOVE_MANDIRS)
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-neutrino/lib:$(flashprefix)/root-neutrino/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk flashprefix=$(flashprefix)/root
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
# ugly hack: neutrino uses the slightly different satellites.xml format from dbox
	if [ -e $@/bin/neutrino ]; then \
		cp $(flashprefix)/root/share/tuxbox/satellites.xml $@/share/tuxbox/satellites.xml; \
	fi
else
	$(MK_FSTAB_VARMOUNTS)
	$(MK_FSTAB_IDEMOUNTS)
endif
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
if BOXTYPE_DBOX2
	ln -sf /var/bin/camd2 $@/bin/camd2
endif
	if [ -e $@/etc/profile.local ]; then \
		rm $@/etc/profile.local; \
		ln -sf /var/etc/profile.local $@/etc/profile.local; \
	fi
	if [ -f $@/lib/libgcc_s_nof.so.1 -a ! -f $@/lib/libgcc_s.so.1 ]; then \
		ln -s libgcc_s_nof.so.1 $@/lib/libgcc_s.so.1; \
	fi
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-radiobox-cramfs \
$(flashprefix)/root-radiobox-squashfs \
$(flashprefix)/root-radiobox-squashfs_nolzma: \
$(flashprefix)/root-radiobox-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-radiobox
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-radiobox/* $@
	$(REMOVE_MANDIRS)
	cp -rd $(flashprefix)/root/lib/tuxbox/plugins/libfx2.so $@/lib/tuxbox/plugins
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-radiobox/lib:$(flashprefix)/root-radiobox/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	cp $(targetprefix)/lib/libstdc++.so.6.0.3 $@/lib/
	ln -sf libstdc++.so.6.0.3 $@/lib/libstdc++.so.6
	ln -sf libstdc++.so.6.0.3 $@/lib/libstdc++.so
	ls -l $@/lib/
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk flashprefix=$(flashprefix)/root
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
	$(MK_FSTAB_VARMOUNTS)
	$(MK_FSTAB_IDEMOUNTS)
endif
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
if BOXTYPE_DBOX2
	ln -sf /var/bin/camd2 $@/bin/camd2
endif
	if [ -e $@/etc/profile.local ]; then \
		rm $@/etc/profile.local; \
		ln -sf /var/etc/profile.local $@/etc/profile.local; \
	fi
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-enigma-cramfs \
$(flashprefix)/root-enigma-squashfs \
$(flashprefix)/root-enigma-squashfs_nolzma: \
$(flashprefix)/root-enigma-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-enigma
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-enigma/* $@
	$(REMOVE_MANDIRS)
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-enigma/lib:$(flashprefix)/root-enigma/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk flashprefix=$(flashprefix)/root
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
	$(MK_FSTAB_VARMOUNTS)
	$(MK_FSTAB_IDEMOUNTS)
endif
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/etc/localtime $@/etc/localtime
if BOXTYPE_DBOX2
	ln -sf /var/bin/camd2 $@/bin/camd2
endif
	if [ -e $@/etc/profile.local ]; then \
		rm $@/etc/profile.local; \
		ln -sf /var/etc/profile.local $@/etc/profile.local; \
	fi
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-enigma+neutrino-squashfs \
$(flashprefix)/root-enigma+neutrino-squashfs_nolzma: \
$(flashprefix)/root-enigma+neutrino-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-neutrino $(flashprefix)/root-enigma flash-lcdmenu
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-neutrino/* $@
	cp -rd $(flashprefix)/root-enigma/* $@
	$(REMOVE_MANDIRS)
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-neutrino/lib:$(flashprefix)/root-neutrino/lib/tuxbox/plugins:$(flashprefix)/root-enigma/lib:$(flashprefix)/root-enigma/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk flashprefix=$(flashprefix)/root
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
	$(MK_FSTAB_VARMOUNTS)
	$(MK_FSTAB_IDEMOUNTS)
endif
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/etc/localtime $@/etc/localtime
if BOXTYPE_DBOX2
	ln -sf /var/bin/camd2 $@/bin/camd2
endif
	if [ -e $@/etc/profile.local ]; then \
		rm $@/etc/profile.local; \
		ln -sf /var/etc/profile.local $@/etc/profile.local; \
	fi
	if [ -f $@/lib/libgcc_s_nof.so.1 -a ! -f $@/lib/libgcc_s.so.1 ]; then \
		ln -s libgcc_s_nof.so.1 $@/lib/libgcc_s.so.1; \
	fi
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-enigma+neutrino-jffs2_lzma \
$(flashprefix)/root-enigma+neutrino-jffs2_lzma_klzma: \
$(flashprefix)/root-enigma+neutrino-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-neutrino $(flashprefix)/root-enigma flash-lcdmenu
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-neutrino/* $@
	cp -rd $(flashprefix)/root-enigma/* $@
	$(REMOVE_MANDIRS)
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-neutrino/lib:$(flashprefix)/root-neutrino/lib/tuxbox/plugins:$(flashprefix)/root-enigma/lib:$(flashprefix)/root-enigma/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$@ flashprefix=$(flashprefix)/root
if BOXTYPE_DREAMBOX
	$(MAKE) flash-dreamfiles dreamfilesrootdir=$@
else
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
endif
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-null-jffs2: $(flashprefix)/root $(flashprefix)/root-jffs2
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $(flashprefix)/root-jffs2/* $@
	$(REMOVE_MANDIRS)
	rm -rf $@/lib/tuxbox/plugins
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root/lib:$(flashprefix)/root-jffs2/lib:$(targetprefix)/lib
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$@ flashprefix=$(flashprefix)/root
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-null-jffs2_lzma: $(flashprefix)/root $(flashprefix)/root-jffs2_lzma
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $(flashprefix)/root-jffs2_lzma/* $@
	$(REMOVE_MANDIRS)
	rm -rf $@/lib/tuxbox/plugins
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root/lib:$(flashprefix)/root-jffs2_lzma/lib_lzma:$(targetprefix)/lib
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$@ flashprefix=$(flashprefix)/root
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-null-jffs2_lzma_klzma: $(flashprefix)/root $(flashprefix)/root-jffs2_lzma_klzma
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $(flashprefix)/root-jffs2_lzma_klzma/* $@
	$(REMOVE_MANDIRS)
	rm -rf $@/lib/tuxbox/plugins
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root/lib:$(flashprefix)/root-jffs2_lzma_klzma/lib:$(targetprefix)/lib
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C ${startscriptdir} install-flash flashprefix_ro=$@ flashprefix_rw=$@ flashprefix=$(flashprefix)/root
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
flash-dreamfiles: @DEPENDS_dreamdriver_dm7000@ @DEPENDS_dreamfiles@
	@PREPARE_dreamdriver_dm7000@
	cp -vR $(buildprefix)/@DIR_dreamdriver_dm7000@/dreamfiles/* $(dreamfilesrootdir)/
endif
if BOXMODEL_DM56x0
flash-dreamfiles: @DEPENDS_dreamdriver_dm56x0@ @DEPENDS_dreamfiles@
	@PREPARE_dreamdriver_dm56x0@
	cp -vR $(buildprefix)/@DIR_dreamdriver_dm56x0@/dreamfiles/* $(dreamfilesrootdir)/
endif
if BOXMODEL_DM500
flash-dreamfiles: @DEPENDS_dreamdriver_dm500@ @DEPENDS_dreamfiles@
	@PREPARE_dreamdriver_dm500@
	cp -vR $(buildprefix)/@DIR_dreamdriver_dm500@/dreamfiles/* $(dreamfilesrootdir)/
endif
	@PREPARE_dreamfiles@
	cp -vR $(buildprefix)/@DIR_dreamfiles@/boot $(flashprefix)
	cp -vR $(buildprefix)/@DIR_dreamfiles@/dreamfiles/bin/* $(dreamfilesrootdir)/bin
	cp -vR $(buildprefix)/@DIR_dreamfiles@/dreamfiles/share/* $(dreamfilesrootdir)/share
	cp -vR $(buildprefix)/@DIR_dreamfiles@/mkcramfs-e $(hostprefix)/bin
	cp -vR $(buildprefix)/@DIR_dreamfiles@/mksquashfs $(hostprefix)/bin/mksquashfs-dream
if !TARGETRULESET_UCLIBC
	$(INSTALL) -d $(dreamfilesrootdir)/lib/gconv
	cp -vR $(buildprefix)/@DIR_dreamfiles@/dreamfiles/lib/gconv/* $(dreamfilesrootdir)/lib/gconv
endif
	@CLEANUP_dreamfiles@
if BOXMODEL_DM7000
	@CLEANUP_dreamdriver_dm7000@
endif
if BOXMODEL_DM56x0
	@CLEANUP_dreamdriver_dm56x0@
endif
if BOXMODEL_DM500
	@CLEANUP_dreamdriver_dm500@
endif
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
if !TARGETRULESET_UCLIBC
	@for i in ISO8859-1.so ISO8859-2.so ISO8859-7.so UNICODE.so; do \
		cp $(targetprefix)/lib/gconv/$$i $(dreamfilesrootdir)/lib/gconv; \
	done;
	$(target)-strip $(dreamfilesrootdir)/lib/gconv/*.so 2>/dev/null || /bin/true
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
if !BOXMODEL_DM500
	@for i in cables.xml terrestrial.xml; do \
		if [ -f $(dreamfilesrootdir)/share/tuxbox/$$i ]; then \
			rm $(dreamfilesrootdir)/share/tuxbox/$$i; \
		fi; \
	done;
endif
if !BOXMODEL_DM56x0
	@for i in skins/small_red*.esml skins/small_red*.info pictures/small-red pictures/triaxlogo-fs8.png ; do \
		rm -Rf $(dreamfilesrootdir)/share/tuxbox/enigma/$$i; done
endif

endif
