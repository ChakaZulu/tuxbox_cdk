cramfs.list: $(flashprefix)/cramfs.list

$(flashprefix)/cramfs.list: $(shell echo $(flashprefix)/*.cramfs)
	rm -f $@
	cd $(flashprefix) && \
	for f in $(notdir $^) ; do \
	echo $(updatehttpprefix)$$f \
		`md5sum -b <$$f |sed -e s/\*-//` \
		`grep version $(flashprefix)/root/.version |sed -e s/version=//` \
		$$f >> $@; \
	done
	@TUXBOX_CUSTOMIZE@

squashfs.list: $(flashprefix)/squashfs.list

$(flashprefix)/squashfs.list: $(shell echo $(flashprefix)/*.squashfs)
	rm -f $@
	cd $(flashprefix) && \
	for f in $(notdir $^) ; do \
	echo $(updatehttpprefix)$$f \
		`md5sum -b <$$f |sed -e s/\*-//` \
		`grep version $(flashprefix)/root/.version |sed -e s/version=//` \
		$$f >> $@; \
	done
	@TUXBOX_CUSTOMIZE@

img.list: $(flashprefix)/img.list

$(flashprefix)/img.list: $(shell echo $(flashprefix)/*.img*x)
	rm -f $@
	cd $(flashprefix) && \
	for f in $(notdir $^) ; do \
	echo $(updatehttpprefix)$$f \
		`md5sum -b <$$f |sed -e s/\*-//` \
		`grep version $(flashprefix)/root/.version |sed -e s/version=//` \
		$$f >> $@; \
	done
	@TUXBOX_CUSTOMIZE@

allimages.list: $(flashprefix)/allimages.list

$(flashprefix)/allimages.list: $(flashprefix)/img.list $(flashprefix)/squashfs.list $(flashprefix)/cramfs.list
	cat $^ > $@
	@TUXBOX_CUSTOMIZE@

# Experimental target
update.list: $(flashprefix)/update.list

$(flashprefix)/update.list: $(shell $(customizationsdir)/ls-distributionfiles $(flashprefix) $(buildprefix) 2>/dev/null ||  echo $(flashprefix)/*.img*x $(flashprefix)/root-*.*fs )
	@echo $^
	rm -f $@
	cd $(flashprefix) && \
	for f in $^ ; do \
	echo $(updatehttpprefix)`basename $$f` \
		`md5sum -b <$$f |sed -e s/\*-//` \
		`grep version $(flashprefix)/root/.version |sed -e s/version=//` \
		`basename $$f` >> $@; \
	done
	@TUXBOX_CUSTOMIZE@
