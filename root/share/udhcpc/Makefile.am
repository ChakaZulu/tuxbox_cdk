EXTRA_DIST = \
	default.script

FILES = \
	default.script

all-local: $(FILES)

install-data-local: $(FILES)
	install -d $(targetprefix)/share/udhcpc
	@for i in $(FILES) ; do \
		if [ "$(FORCE)" -o ! -e $(targetprefix)/share/udhcpc/$$i ] ; then \
			echo "install -m755 $$i $(targetprefix)/share/udhcpc" ; \
			install -m755 $$i $(targetprefix)/share/udhcpc ; \
		fi ; \
	done

