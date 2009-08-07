# Public flash targets
#
# flash-$gui-$rootfs-$chips
#

flash-all-all-all: flash-neutrino-all-all flash-enigma-all-all flash-enigma+neutrino-all-all

flash-all-cramfs-all: flash-neutrino-cramfs-all flash-enigma-cramfs-all

flash-all-squashfs-all: flash-neutrino-squashfs-all flash-enigma-squashfs-all flash-enigma+neutrino-squashfs-all

flash-all-squashfs_nolzma-all: flash-neutrino-squashfs_nolzma-all flash-enigma-squashfs_nolzma-all flash-enigma+neutrino-squashfs_nolzma-all

flash-all-jffs2-all: flash-neutrino-jffs2-all flash-enigma-jffs2-all

flash-all-jffs2_lzma-all: flash-neutrino-jffs2_lzma-all flash-enigma-jffs2_lzma-all flash-enigma+neutrino-jffs2_lzma-all

flash-all-jffs2_lzma_klzma-all: flash-neutrino-jffs2_lzma_klzma-all flash-enigma-jffs2_lzma_klzma-all flash-enigma+neutrino-jffs2_lzma_klzma-all


flash-all-all-1x: flash-neutrino-all-1x flash-enigma-all-1x flash-enigma+neutrino-all-1x

flash-all-all-2x: flash-neutrino-all-2x flash-enigma-all-2x flash-enigma+neutrino-all-2x

flash-neutrino-all-1x: flash-neutrino-squashfs-1x flash-neutrino-squashfs_nolzma-1x flash-neutrino-jffs2-1x flash-neutrino-jffs2_lzma-1x flash-neutrino-jffs2_lzma_klzma-1x

flash-radiobox-all-1x: flash-radiobox-squashfs-1x flash-radiobox-jffs2-1x flash-radiobox-jffs2_lzma-1x flash-radiobox-jffs2_lzma_klzma-1x

flash-enigma-all-1x: flash-enigma-squashfs-1x flash-enigma-squashfs_nolzma-1x flash-enigma-jffs2-1x flash-enigma-jffs2_lzma-1x flash-enigma-jffs2_lzma_klzma-1x


flash-neutrino-all-2x: flash-neutrino-squashfs-2x flash-neutrino-squashfs_nolzma-2x flash-neutrino-jffs2-2x flash-neutrino-jffs2_lzma-2x flash-neutrino-jffs2_lzma_klzma-2x

flash-radiobox-all-2x: flash-radiobox-squashfs-2x flash-radiobox-squashfs_nolzma-2x flash-radiobox-jffs2-2x flash-radiobox-jffs2_lzma-2x flash-radiobox-jffs2_lzma_klzma-2x

flash-enigma-all-2x: flash-enigma-squashfs-2x flash-enigma-squashfs_nolzma-2x flash-enigma-jffs2-2x flash-enigma-jffs2_lzma-2x flash-enigma-jffs2_lzma_klzma-2x

flash-neutrino-all-all: flash-neutrino-squashfs-all flash-neutrino-squashfs_nolzma-all flash-neutrino-jffs2-all flash-neutrino-jffs2_lzma-all flash-neutrino-jffs2_lzma_klzma-all

flash-neutrino-cramfs-all: flash-neutrino-cramfs-1x flash-neutrino-cramfs-2x

if BOXTYPE_DREAMBOX
flash-neutrino-squashfs: $(flashprefix)/neutrino-squashfs.dream
else
if BOXTYPE_IPBOX
flash-neutrino-squashfs: ipbox_flash_imgs_neutrino ipbox_serial_imgs_neutrino ipbox_usb_imgs_neutrino
else
flash-neutrino-squashfs-all: flash-neutrino-squashfs-1x flash-neutrino-squashfs-2x
flash-neutrino-squashfs_nolzma-all: flash-neutrino-squashfs_nolzma-1x flash-neutrino-squashfs_nolzma-2x
endif
endif

flash-neutrino-jffs2-all: flash-neutrino-jffs2-1x flash-neutrino-jffs2-2x

flash-neutrino-jffs2_lzma-all: flash-neutrino-jffs2_lzma-1x flash-neutrino-jffs2_lzma-2x

flash-neutrino-jffs2_lzma_klzma-all: flash-neutrino-jffs2_lzma_klzma-1x flash-neutrino-jffs2_lzma_klzma-2x


#

flash-radiobox-all-all: flash-radiobox-squashfs-all flash-radiobox-jffs2-all flash-radiobox-jffs2_lzma-all flash-radiobox-jffs2_lzma_klzma-all

flash-radiobox-cramfs-all: flash-radiobox-cramfs-1x flash-radiobox-cramfs-2x

flash-radiobox-squashfs-all: flash-radiobox-squashfs-1x flash-radiobox-squashfs-2x

flash-radiobox-squashfs_nolzma-all: flash-radiobox-squashfs_nolzma-1x flash-radiobox-squashfs_nolzma-2x

flash-radiobox-jffs2-all: flash-radiobox-jffs2-1x flash-radiobox-jffs2-2x

flash-radiobox-jffs2_lzma-all: flash-radiobox-jffs2_lzma-1x flash-radiobox-jffs2_lzma-2x

flash-radiobox-jffs2_lzma_klzma-all: flash-radiobox-jffs2_lzma_klzma-1x flash-radiobox-jffs2_lzma_klzma-2x

#

flash-enigma-all-all: flash-enigma-squashfs-all flash-enigma-squashfs_nolzma-all flash-enigma-jffs2-all flash-enigma-jffs2_lzma-all flash-enigma-jffs2_lzma_klzma-all

flash-enigma-cramfs-all: flash-enigma-cramfs-1x flash-enigma-cramfs-2x

if BOXTYPE_DREAMBOX
flash-enigma-squashfs: $(flashprefix)/enigma-squashfs.dream
else
if BOXTYPE_IPBOX
flash-enigma-squashfs: ipbox_flash_imgs_enigma ipbox_serial_imgs_enigma ipbox_usb_imgs_enigma
else
flash-enigma-squashfs-all: flash-enigma-squashfs-1x flash-enigma-squashfs-2x
flash-enigma-squashfs_nolzma-all: flash-enigma-squashfs_nolzma-1x flash-enigma-squashfs_nolzma-2x
endif
endif

flash-enigma-jffs2-all: flash-enigma-jffs2-1x flash-enigma-jffs2-2x

flash-enigma-jffs2_lzma-all: flash-enigma-jffs2_lzma-1x flash-enigma-jffs2_lzma-2x

flash-enigma-jffs2_lzma_klzma-all: flash-enigma-jffs2_lzma_klzma-1x flash-enigma-jffs2_lzma_klzma-2x

flash-all-cramfs-1x: flash-enigma-cramfs-1x flash-neutrino-cramfs-1x 

flash-all-cramfs-2x: flash-enigma-cramfs-2x flash-neutrino-cramfs-2x 

flash-all-squashfs-1x: flash-enigma-squashfs-1x flash-neutrino-squashfs-1x 

flash-all-squashfs-2x: flash-enigma-squashfs-2x flash-neutrino-squashfs-2x 

flash-all-squashfs_nolzma-1x: flash-enigma-squashfs_nolzma-1x flash-neutrino-squashfs_nolzma-1x

flash-all-squashfs_nolzma-2x: flash-enigma-squashfs_nolzma-2x flash-neutrino-squashfs_nolzma-2x

flash-all-jffs2-1x: flash-enigma-jffs2-1x flash-neutrino-jffs2-1x 

flash-all-jffs2-2x: flash-enigma-jffs2-2x flash-neutrino-jffs2-2x 

flash-all-jffs2_lzma-1x: flash-enigma-jffs2_lzma-1x flash-neutrino-jffs2_lzma-1x flash-enigma+neutrino-jffs2_lzma-1x

flash-all-jffs2_lzma-2x: flash-enigma-jffs2_lzma-2x flash-neutrino-jffs2_lzma-2x flash-enigma+neutrino-jffs2_lzma-2x

flash-all-jffs2_lzma_klzma-1x: flash-enigma-jffs2_lzma_klzma-1x flash-neutrino-jffs2_lzma_klzma-1x flash-enigma+neutrino-jffs2_lzma_klzma-1x

flash-all-jffs2_lzma_klzma-2x: flash-enigma-jffs2_lzma_klzma-2x flash-neutrino-jffs2_lzma_klzma-2x flash-enigma+neutrino-jffs2_lzma_klzma-2x

flash-null-jffs2-all: flash-null-jffs2-2x flash-null-jffs2-1x 

flash-null-jffs2_lzma-all: flash-null-jffs2_lzma-2x flash-null-jffs2_lzma-1x

flash-null-jffs2_lzma_klzma-all: flash-null-jffs2_lzma_klzma-2x flash-null-jffs2_lzma_klzma-1x

flash-lcars-jffs2-all: flash-lcars-jffs2-2x flash-lcars-jffs2-1x 
################################################################

flash-neutrino-cramfs-1x: $(flashprefix)/neutrino-cramfs.img1x

flash-neutrino-cramfs-2x: $(flashprefix)/neutrino-cramfs.img2x

flash-neutrino-squashfs-1x: $(flashprefix)/neutrino-squashfs.img1x

flash-neutrino-squashfs-2x: $(flashprefix)/neutrino-squashfs.img2x

flash-neutrino-squashfs_nolzma-1x: $(flashprefix)/neutrino-squashfs_nolzma.img1x

flash-neutrino-squashfs_nolzma-2x: $(flashprefix)/neutrino-squashfs_nolzma.img2x

flash-neutrino-jffs2-1x: $(flashprefix)/neutrino-jffs2.img1x

flash-neutrino-jffs2-2x: $(flashprefix)/neutrino-jffs2.img2x

flash-neutrino-jffs2_lzma-1x: $(flashprefix)/neutrino-jffs2_lzma.img1x

flash-neutrino-jffs2_lzma-2x: $(flashprefix)/neutrino-jffs2_lzma.img2x

flash-neutrino-jffs2_lzma_klzma-1x: $(flashprefix)/neutrino-jffs2_lzma_klzma.img1x

flash-neutrino-jffs2_lzma_klzma-2x: $(flashprefix)/neutrino-jffs2_lzma_klzma.img2x

#

flash-radiobox-cramfs-1x: $(flashprefix)/radiobox-cramfs.img1x

flash-radiobox-cramfs-2x: $(flashprefix)/radiobox-cramfs.img2x

flash-radiobox-squashfs-1x: $(flashprefix)/radiobox-squashfs.img1x

flash-radiobox-squashfs-2x: $(flashprefix)/radiobox-squashfs.img2x

flash-radiobox-squashfs_nolzma-1x: $(flashprefix)/radiobox-squashfs_nolzma.img1x

flash-radiobox-squashfs_nolzma-2x: $(flashprefix)/radiobox-squashfs_nolzma.img2x

flash-radiobox-jffs2-1x: $(flashprefix)/radiobox-jffs2.img1x

flash-radiobox-jffs2-2x: $(flashprefix)/radiobox-jffs2.img2x

flash-radiobox-jffs2_lzma-1x: $(flashprefix)/radiobox-jffs2_lzma.img1x

flash-radiobox-jffs2_lzma-2x: $(flashprefix)/radiobox-jffs2_lzma.img2x

flash-radiobox-jffs2_lzma_klzma-1x: $(flashprefix)/radiobox-jffs2_lzma_klzma.img1x

flash-radiobox-jffs2_lzma_klzma-2x: $(flashprefix)/radiobox-jffs2_lzma_klzma.img2x

#

flash-enigma-cramfs-1x: $(flashprefix)/enigma-cramfs.img1x

flash-enigma-cramfs-2x: $(flashprefix)/enigma-cramfs.img2x

flash-enigma-squashfs-1x: $(flashprefix)/enigma-squashfs.img1x

flash-enigma-squashfs-2x: $(flashprefix)/enigma-squashfs.img2x

flash-enigma-squashfs_nolzma-1x: $(flashprefix)/enigma-squashfs_nolzma.img1x

flash-enigma-squashfs_nolzma-2x: $(flashprefix)/enigma-squashfs_nolzma.img2x

flash-enigma-jffs2-1x: $(flashprefix)/enigma-jffs2.img1x

flash-enigma-jffs2-2x: $(flashprefix)/enigma-jffs2.img2x

flash-enigma-jffs2_lzma-1x: $(flashprefix)/enigma-jffs2_lzma.img1x

flash-enigma-jffs2_lzma-2x: $(flashprefix)/enigma-jffs2_lzma.img2x

flash-enigma-jffs2_lzma_klzma-1x: $(flashprefix)/enigma-jffs2_lzma_klzma.img1x

flash-enigma-jffs2_lzma_klzma-2x: $(flashprefix)/enigma-jffs2_lzma_klzma.img2x

#

flash-enigma+neutrino-all-all: flash-enigma+neutrino-squashfs-all flash-enigma+neutrino-squashfs_nolzma-all flash-enigma+neutrino-jffs2_lzma-all flash-enigma+neutrino-jffs2_lzma_klzma-all
flash-enigma+neutrino-all-1x: flash-enigma+neutrino-squashfs-1x flash-enigma+neutrino-squashfs_nolzma-1x flash-enigma+neutrino-jffs2_lzma-1x flash-enigma+neutrino-jffs2_lzma_klzma-1x
flash-enigma+neutrino-all-2x: flash-enigma+neutrino-squashfs-2x flash-enigma+neutrino-squashfs_nolzma-2x flash-enigma+neutrino-jffs2_lzma-2x flash-enigma+neutrino-jffs2_lzma_klzma-2x

flash-enigma+neutrino-squashfs-all: flash-enigma+neutrino-squashfs-1x flash-enigma+neutrino-squashfs-2x
flash-enigma+neutrino-squashfs-1x: $(flashprefix)/enigma+neutrino-squashfs.img1x
flash-enigma+neutrino-squashfs-2x: $(flashprefix)/enigma+neutrino-squashfs.img2x

flash-enigma+neutrino-squashfs_nolzma-all: flash-enigma+neutrino-squashfs_nolzma-1x flash-enigma+neutrino-squashfs_nolzma-2x
flash-enigma+neutrino-squashfs_nolzma-1x: $(flashprefix)/enigma+neutrino-squashfs_nolzma.img1x
flash-enigma+neutrino-squashfs_nolzma-2x: $(flashprefix)/enigma+neutrino-squashfs_nolzma.img2x

flash-enigma+neutrino-jffs2_lzma-all: flash-enigma+neutrino-jffs2_lzma-1x flash-enigma+neutrino-jffs2_lzma-2x
flash-enigma+neutrino-jffs2_lzma-1x: $(flashprefix)/enigma+neutrino-jffs2_lzma.img1x
flash-enigma+neutrino-jffs2_lzma-2x: $(flashprefix)/enigma+neutrino-jffs2_lzma.img2x

flash-enigma+neutrino-jffs2_lzma_klzma-all: flash-enigma+neutrino-jffs2_lzma_klzma-1x flash-enigma+neutrino-jffs2_lzma_klzma-2x
flash-enigma+neutrino-jffs2_lzma_klzma-1x: $(flashprefix)/enigma+neutrino-jffs2_lzma_klzma.img1x
flash-enigma+neutrino-jffs2_lzma_klzma-2x: $(flashprefix)/enigma+neutrino-jffs2_lzma_klzma.img2x

#

flash-null-jffs2-1x: $(flashprefix)/null-jffs2.img1x

flash-null-jffs2-2x: $(flashprefix)/null-jffs2.img2x

flash-null-jffs2_lzma-1x: $(flashprefix)/null-jffs2_lzma.img1x

flash-null-jffs2_lzma-2x: $(flashprefix)/null-jffs2_lzma.img2x

flash-null-jffs2_lzma_klzma-1x: $(flashprefix)/null-jffs2_lzma_klzma.img1x

flash-null-jffs2_lzma_klzma-2x: $(flashprefix)/null-jffs2_lzma_klzma.img2x

flash-lcars-jffs2-1x: $(flashprefix)/lcars-jffs2.img1x

flash-lcars-jffs2-2x: $(flashprefix)/lcars-jffs2.img2x
