################################################################ 
# This .PRECIOUS-bizarreness is there to tell Make that these files are not
# just "intermediate products", but are not to be deleted.

.PRECIOUS: \
$(flashprefix)/neutrino-cramfs.img% $(flashprefix)/enigma-cramfs.img% \
$(flashprefix)/neutrino-squashfs.img% $(flashprefix)/enigma-squashfs.img% \
$(flashprefix)/neutrino-jffs2.img% $(flashprefix)/enigma-jffs2.img% \
$(flashprefix)/neutrino-jffs2_lzma.img% $(flashprefix)/enigma-jffs2_lzma.img% \
$(flashprefix)/neutrino-jffs2_lzma_klzma.img% $(flashprefix)/enigma-jffs2_lzma_klzma.img% \
$(flashprefix)/enigma+neutrino-squashfs.img% \
$(flashprefix)/enigma+neutrino-jffs2_lzma.img% \
$(flashprefix)/enigma+neutrino-jffs2_lzma_klzma.img% \
$(flashprefix)/var-%.jffs2 \
$(flashprefix)/root-%.jffs2 \
$(flashprefix)/root-%.cramfs $(flashprefix)/root-%.squashfs \
%/lib/ld.so.1


# If the actions of a target return nonzero exit status, delete the target.
# Reference: make manual "5.5 Errors in Commands", 
# http://www.gnu.org/software/make/manual/make.html#Errors
# Requires patched make to work with directories.
# See http://savannah.gnu.org/bugs/?func=detailitem&item_id=16372

.DELETE_ON_ERROR:
