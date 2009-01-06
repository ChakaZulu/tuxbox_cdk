yadd-ucodes ucodes:
	$(INSTALL) -d $(targetprefix)/var/tuxbox/ucodes
	if [ -d $(ucodesdir) ] ; then \
		rm -f $(targetprefix)/var/tuxbox/ucodes/*; \
		cp -dp $(ucodesdir)/* $(targetprefix)/var/tuxbox/ucodes; \
	fi || true

if TARGETRULESET_FLASH
flash-ucodes:
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/ucodes
	if [ -d $(ucodesdir) ] ; then \
		rm -f $(flashprefix)/root/var/tuxbox/ucodes/*; \
		cp -dp $(ucodesdir)/* $(flashprefix)/root/var/tuxbox/ucodes; \
	fi || true
	@FLASHROOTDIR_MODIFIED@

endif

.PHONY: yadd-ucodes ucodes flash-ucodes
