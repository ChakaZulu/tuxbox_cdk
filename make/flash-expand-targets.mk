# Public flash targets
#
# flash-$gui-$rootfs-$chips
#

flash-all-all-all: flash-neutrino-all-all flash-enigma-all-all flash-enigma+neutrino-all-all

flash-all-cramfs-all: flash-neutrino-cramfs-all flash-enigma-cramfs-all

flash-all-squashfs-all: flash-neutrino-squashfs-all flash-enigma-squashfs-all flash-enigma+neutrino-squashfs-all

flash-all-jffs2-all: flash-neutrino-jffs2-all flash-enigma-jffs2-all


flash-all-all-1x: flash-neutrino-all-1x flash-enigma-all-1x flash-enigma+neutrino-all-1x

flash-all-all-2x: flash-neutrino-all-2x flash-enigma-all-2x flash-enigma+neutrino-all-2x

flash-neutrino-all-1x: flash-neutrino-cramfs-1x flash-neutrino-squashfs-1x flash-neutrino-jffs2-1x

flash-radiobox-all-1x: flash-radiobox-cramfs-1x flash-radiobox-squashfs-1x flash-radiobox-jffs2-1x

flash-enigma-all-1x: flash-enigma-cramfs-1x flash-enigma-squashfs-1x flash-enigma-jffs2-1x


flash-neutrino-all-2x: flash-neutrino-cramfs-2x flash-neutrino-squashfs-2x flash-neutrino-jffs2-2x

flash-radiobox-all-2x: flash-radiobox-cramfs-2x flash-radiobox-squashfs-2x flash-radiobox-jffs2-2x

flash-enigma-all-2x: flash-enigma-cramfs-2x flash-enigma-squashfs-2x flash-enigma-jffs2-2x

flash-neutrino-all-all: flash-neutrino-cramfs-all flash-neutrino-squashfs-all flash-neutrino-jffs2-all 

flash-neutrino-cramfs-all: flash-neutrino-cramfs-1x flash-neutrino-cramfs-2x

flash-neutrino-squashfs-all: flash-neutrino-squashfs-1x flash-neutrino-squashfs-2x

flash-neutrino-jffs2-all: flash-neutrino-jffs2-1x flash-neutrino-jffs2-2x

#

flash-radiobox-all-all: flash-radiobox-cramfs-all flash-radiobox-squashfs-all flash-radiobox-jffs2-all

flash-radiobox-cramfs-all: flash-radiobox-cramfs-1x flash-radiobox-cramfs-2x

flash-radiobox-squashfs-all: flash-radiobox-squashfs-1x flash-radiobox-squashfs-2x

flash-radiobox-jffs2-all: flash-radiobox-jffs2-1x flash-radiobox-jffs2-2x


#

flash-enigma-all-all: flash-enigma-cramfs-all flash-enigma-squashfs-all flash-enigma-jffs2-all 

flash-enigma-cramfs-all: flash-enigma-cramfs-1x flash-enigma-cramfs-2x

flash-enigma-squashfs-all: flash-enigma-squashfs-1x flash-enigma-squashfs-2x

flash-enigma-jffs2-all: flash-enigma-jffs2-1x flash-enigma-jffs2-2x

flash-all-cramfs-1x: flash-enigma-cramfs-1x flash-neutrino-cramfs-1x 

flash-all-cramfs-2x: flash-enigma-cramfs-2x flash-neutrino-cramfs-2x 

flash-all-squashfs-1x: flash-enigma-squashfs-1x flash-neutrino-squashfs-1x 

flash-all-squashfs-2x: flash-enigma-squashfs-2x flash-neutrino-squashfs-2x 

flash-all-jffs2-1x: flash-enigma-jffs2-1x flash-neutrino-jffs2-1x 

flash-all-jffs2-2x: flash-enigma-jffs2-2x flash-neutrino-jffs2-2x 

flash-null-jffs2-all: flash-null-jffs2-2x flash-null-jffs2-1x 

flash-lcars-jffs2-all: flash-lcars-jffs2-2x flash-lcars-jffs2-1x 
################################################################

flash-neutrino-cramfs-1x: $(flashprefix)/neutrino-cramfs.img1x

flash-neutrino-cramfs-2x: $(flashprefix)/neutrino-cramfs.img2x

flash-neutrino-squashfs-1x: $(flashprefix)/neutrino-squashfs.img1x

flash-neutrino-squashfs-2x: $(flashprefix)/neutrino-squashfs.img2x

flash-neutrino-jffs2-1x: $(flashprefix)/neutrino-jffs2.img1x

flash-neutrino-jffs2-2x: $(flashprefix)/neutrino-jffs2.img2x

#

flash-radiobox-cramfs-1x: $(flashprefix)/radiobox-cramfs.img1x

flash-radiobox-cramfs-2x: $(flashprefix)/radiobox-cramfs.img2x

flash-radiobox-squashfs-1x: $(flashprefix)/radiobox-squashfs.img1x

flash-radiobox-squashfs-2x: $(flashprefix)/radiobox-squashfs.img2x

flash-radiobox-jffs2-1x: $(flashprefix)/radiobox-jffs2.img1x

flash-radiobox-jffs2-2x: $(flashprefix)/radiobox-jffs2.img2x

#

flash-enigma-cramfs-1x: $(flashprefix)/enigma-cramfs.img1x

flash-enigma-cramfs-2x: $(flashprefix)/enigma-cramfs.img2x

flash-enigma-squashfs-1x: $(flashprefix)/enigma-squashfs.img1x

flash-enigma-squashfs-2x: $(flashprefix)/enigma-squashfs.img2x

flash-enigma-jffs2-1x: $(flashprefix)/enigma-jffs2.img1x

flash-enigma-jffs2-2x: $(flashprefix)/enigma-jffs2.img2x

#

flash-enigma+neutrino-all-all: flash-enigma+neutrino-squashfs-all

flash-enigma+neutrino-squashfs-all: flash-enigma+neutrino-squashfs-1x flash-enigma+neutrino-squashfs-2x

flash-enigma+neutrino-all-1x: flash-enigma+neutrino-squashfs-1x
flash-enigma+neutrino-all-2x: flash-enigma+neutrino-squashfs-2x

flash-enigma+neutrino-squashfs-1x: $(flashprefix)/enigma+neutrino-squashfs.img1x
flash-enigma+neutrino-squashfs-2x: $(flashprefix)/enigma+neutrino-squashfs.img2x

#

flash-null-jffs2-1x: $(flashprefix)/null-jffs2.img1x

flash-null-jffs2-2x: $(flashprefix)/null-jffs2.img2x

flash-lcars-jffs2-1x: $(flashprefix)/lcars-jffs2.img1x

flash-lcars-jffs2-2x: $(flashprefix)/lcars-jffs2.img2x
