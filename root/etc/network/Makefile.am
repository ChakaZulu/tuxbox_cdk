EXTRA_DIST = \
	interfaces

FILES = \
	interfaces

all-local: $(FILES)

install-data-local: $(FILES)
	install -d $(targetprefix)/etc/network
	@for i in $(FILES) ; do \
		install -m644 $$i $(targetprefix)/etc/network ; \
	done

