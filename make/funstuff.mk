# tuxbox/funstuff

$(appsdir)/tuxbox/funstuff/config.status: bootstrap
	cd $(appsdir)/tuxbox/funstuff && $(CONFIGURE)

$(DEPDIR)/funstuff: $(appsdir)/tuxbox/funstuff/config.status
	$(MAKE) -C $(appsdir)/tuxbox/funstuff all install
	touch $@

if TARGETRULESET_FLASH

lcdsaversfiles = $(basename $(notdir $(wildcard $(appsdir)/tuxbox/funstuff/lcd-savers/*.c)))

$(patsubst %,flash-%,$(lcdsaversfiles)):
	@make $(flashprefix)/root/bin/$(patsubst flash-%,%,$@)

$(patsubst %,$(flashprefix)/root/bin/%,$(lcdsaversfiles)): funstuff | $(flashprefix)/root
	$(INSTALL) -m 755 $(targetprefix)/bin/$(notdir $@) $@

endif
