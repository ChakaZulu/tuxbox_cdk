# tuxbox/funstuff

$(appsdir)/tuxbox/funstuff/config.status: bootstrap
	cd $(appsdir)/tuxbox/funstuff && $(CONFIGURE)

$(DEPDIR)/funstuff: $(appsdir)/tuxbox/funstuff/config.status
	$(MAKE) -C $(appsdir)/tuxbox/funstuff all install
	touch $@
