EXTRA_DIST = \
	interfaces

FILES = \
	interfaces

all-local: $(FILES)

install-data-local: $(FILES)
	install -d $(targetprefix)/etc/network
	@for i in $(FILES) ; do \
		if [ "$(FORCE)" -o ! -e $(targetprefix)/etc/network/$$i ] ; then \
			echo "install -m644 $$i $(targetprefix)/etc/network" ; \
			install -m644 $$i $(targetprefix)/etc/network ; \
		fi ; \
	done

