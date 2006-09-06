defaultlocale: $(targetprefix)/var/tuxbox/config/defaultlocale

$(targetprefix)/var/tuxbox/config/defaultlocale:
	echo $(DEFAULTLOCALE) > $@

if TARGETRULESET_FLASH

flash-defaultlocale: $(flashprefix)/root/var/tuxbox/config/defaultlocale

$(flashprefix)/root/var/tuxbox/config/defaultlocale: | $(flashprefix)/root
	echo $(DEFAULTLOCALE) > $@
	@FLASHROOTDIR_MODIFIED@

endif
