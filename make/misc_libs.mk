# misc/libs

# This file serves as a marker for misc_libs
$(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc:
	$(MAKE) misc_libs

$(appsdir)/misc/libs/config.status: bootstrap libz
	cd $(appsdir)/misc/libs && $(CONFIGURE)

misc_libs: $(appsdir)/misc/libs/config.status
	$(MAKE) -C $(appsdir)/misc/libs all install
