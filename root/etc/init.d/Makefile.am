EXTRA_DIST = \
	rcS start start_lcars start_neutrino

install-data-local:
	install -d $(targetprefix)/etc/init.d
	@for i in $(EXTRA_DIST:%.in=%) ; do \
		install -m755 $$i $(targetprefix)/etc/init.d ; \
	done
