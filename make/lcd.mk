# tuxbox/lcd

$(appsdir)/tuxbox/lcd/config.status: bootstrap libfreetype $(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc $(targetprefix)/lib/pkgconfig/tuxbox-tuxtxt.pc
	cd $(appsdir)/tuxbox/lcd && $(CONFIGURE)

lcd: $(appsdir)/tuxbox/lcd/config.status
	$(MAKE) -C $(appsdir)/tuxbox/lcd all install

if TARGETRULESET_FLASH
flash-lcdmenu: lcd $(flashprefix)/root
	$(INSTALL) $(targetprefix)/bin/lcdmenu $(flashprefix)/root/bin
	cp -rd $(targetprefix)/var/tuxbox/config/lcdmenu.conf $(flashprefix)/root/var/tuxbox/config
	@FLASHROOTDIR_MODIFIED@

flash-lcdip: lcd $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/lcd/lcdip install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-lcdcmd: lcd $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/lcd/lcdcmd install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

endif
