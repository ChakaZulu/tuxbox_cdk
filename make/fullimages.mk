# Name for images/filesystems:
#
# $partition-$gui-$rootfilesystem.$type

# where 
# $type in { cramfs, squashfs, jffs2, img1x, img2x, flfs1x, flfs2x }
# $partition in { root, var } (empty by full images)
# $gui in { neutrino, enigma } 

# Public targets that build one or more images (*.img*x)

################################################################
# Targets for building user images (*.img*x)
#
# They all depend on two or three $partition-$gui.$fstype, defined in the
# partition-images.mk.

# Note the difference between $partition-$gui-$fstype (directory) and 
# $partition-$gui.$fstype (filesystem image of type $fstype).

$(flashprefix)/neutrino-cramfs.img1x $(flashprefix)/neutrino-cramfs.img2x: \
$(flashprefix)/neutrino-cramfs.img%: \
		$(flashprefix)/cramfs.flfs% \
		$(flashprefix)/root-neutrino.cramfs \
		$(flashprefix)/var-neutrino.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--rootsize=$(ROOT_PARTITION_SIZE) \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/neutrino-squashfs.img1x $(flashprefix)/neutrino-squashfs.img2x:\
$(flashprefix)/neutrino-squashfs.img%: \
		$(flashprefix)/squashfs.flfs% \
		$(flashprefix)/root-neutrino.squashfs \
		$(flashprefix)/var-neutrino.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--rootsize=$(ROOT_PARTITION_SIZE) \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/neutrino-jffs2.img1x $(flashprefix)/neutrino-jffs2.img2x: \
$(flashprefix)/neutrino-jffs2.img%: \
		$(flashprefix)/jffs2.flfs% \
		$(flashprefix)/root-neutrino.jffs2 \
		$(hostprefix)/bin/checkImage
	cat $< $(word 2,$+) > $@
	@FILESIZE=$$(stat -c%s $@); \
	if [ $$FILESIZE -gt 8257536 ]; \
		then echo "fatal error: File $@ too large ($$FILESIZE > 8257536)"; \
		rm $@; exit 1; \
	fi
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

######################

$(flashprefix)/radiobox-cramfs.img1x $(flashprefix)/radiobox-cramfs.img2x: \
$(flashprefix)/radiobox-cramfs.img%: \
		$(flashprefix)/cramfs.flfs% \
		$(flashprefix)/root-radiobox.cramfs \
		$(flashprefix)/var-radiobox.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--rootsize=$(ROOT_PARTITION_SIZE) \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/radiobox-squashfs.img1x $(flashprefix)/radiobox-squashfs.img2x:\
$(flashprefix)/radiobox-squashfs.img%: \
		$(flashprefix)/squashfs.flfs% \
		$(flashprefix)/root-radiobox.squashfs \
		$(flashprefix)/var-radiobox.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--rootsize=$(ROOT_PARTITION_SIZE) \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/radiobox-jffs2.img1x $(flashprefix)/radiobox-jffs2.img2x: \
$(flashprefix)/radiobox-jffs2.img%: \
		$(flashprefix)/jffs2.flfs% \
		$(flashprefix)/root-radiobox.jffs2 \
		$(hostprefix)/bin/checkImage
	cat $< $(word 2,$+) > $@
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

################################################################
$(flashprefix)/enigma-cramfs.img1x $(flashprefix)/enigma-cramfs.img2x: \
$(flashprefix)/enigma-cramfs.img%: \
		$(flashprefix)/cramfs.flfs% \
		$(flashprefix)/root-enigma.cramfs \
		$(flashprefix)/var-enigma.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--rootsize=$(ROOT_PARTITION_SIZE) \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/enigma-squashfs.img1x $(flashprefix)/enigma-squashfs.img2x: \
$(flashprefix)/enigma-squashfs.img%: \
		$(flashprefix)/squashfs.flfs% \
		$(flashprefix)/root-enigma.squashfs \
		$(flashprefix)/var-enigma.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--rootsize=$(ROOT_PARTITION_SIZE) \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/enigma-jffs2.img1x $(flashprefix)/enigma-jffs2.img2x: \
$(flashprefix)/enigma-jffs2.img%: \
		$(flashprefix)/jffs2.flfs% \
		$(flashprefix)/root-enigma.jffs2 \
		$(hostprefix)/bin/checkImage
	cat $< $(word 2,$+) > $@
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

################################################################
$(flashprefix)/lcars-jffs2.img1x $(flashprefix)/lcars-jffs2.img2x: \
$(flashprefix)/lcars-jffs2.img%: \
		$(flashprefix)/jffs2.flfs% \
		$(flashprefix)/root-lcars.jffs2 \
		$(hostprefix)/bin/checkImage
	cat $< $(word 2,$+) > $@
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

################################################################
$(flashprefix)/null-jffs2.img1x $(flashprefix)/null-jffs2.img2x: \
$(flashprefix)/null-jffs2.img%: \
		$(flashprefix)/jffs2.flfs% \
		$(flashprefix)/root-null.jffs2 \
		$(hostprefix)/bin/checkImage
	cat $< $(word 2,$+) > $@
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

################################################################
$(flashprefix)/enigma+neutrino-squashfs.img1x $(flashprefix)/enigma+neutrino-squashfs.img2x:\
$(flashprefix)/enigma+neutrino-squashfs.img%: \
		$(flashprefix)/squashfs.flfs% \
		$(flashprefix)/root-enigma+neutrino.squashfs \
		$(flashprefix)/var-enigma+neutrino.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--rootsize=$(ROOT_PARTITION_SIZE) \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@
	@TUXBOX_CUSTOMIZE@

# target yadd-enigma+neutrino makes no sense, use
# make yadd-neutrino yadd-enigma lcd
# instead
enigma+neutrino: neutrino enigma

if TARGETRULESET_FLASH

flash-enigma+neutrino: $(flashprefix)/root-neutrino $(flashprefix)/root-enigma

endif
