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
	$(MAKE) -C root install-flash flashprefix_ro=$(flashprefix)/.junk flashprefix_rw=$@
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
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/tuxbox/boot
	$(MAKE) -C root install-flash flashprefix_ro=$(flashprefix)/.junk flashprefix_rw=$@
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
	rm -rf $@/man
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$</lib:$</lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$(flashprefix)/root-jffs2/lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$@
if !KERNEL26
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
endif
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-neutrino-cramfs $(flashprefix)/root-neutrino-squashfs: \
$(flashprefix)/root-neutrino-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-neutrino
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-neutrino/* $@
	rm -rf $@/man
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-neutrino/lib:$(flashprefix)/root-neutrino/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
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
	rm -rf $@/man
	cp -rd $(flashprefix)/root/lib/tuxbox/plugins/libfx2.so $@/lib/tuxbox/plugins
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-radiobox/lib:$(flashprefix)/root-radiobox/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	cp $(targetprefix)/lib/libstdc++.so.6.0.3 $@/lib/
	ln -sf libstdc++.so.6.0.3 $@/lib/libstdc++.so.6
	ln -sf libstdc++.so.6.0.3 $@/lib/libstdc++.so
	ls -l $@/lib/
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
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
	rm -rf $@/man
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-enigma/lib:$(flashprefix)/root-enigma/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/etc/localtime $@/etc/localtime
	ln -sf /var/bin/camd2 $@/bin/camd2
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
	rm -rf $@/man
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-neutrino/lib:$(flashprefix)/root-neutrino/lib/tuxbox/plugins:$(flashprefix)/root-enigma/lib:$(flashprefix)/root-enigma/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $@/etc/fstab
endif
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/etc/localtime $@/etc/localtime
	ln -sf /var/bin/camd2 $@/bin/camd2
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
	rm -rf $@/man
	rm -rf $@/lib/tuxbox/plugins
	$(MAKE) --assume-old=$@ $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root/lib:$(flashprefix)/root-jffs2/lib:$(targetprefix)/lib
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$@
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
