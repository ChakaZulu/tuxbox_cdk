$(hostappsdir)/config.status:
	cd $(hostappsdir) && \
	./autogen.sh && \
	./configure --prefix=$(hostprefix)

hostapps: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)
#	touch $@

if TARGETRULESET_FLASH

$(hostprefix)/bin/mkflfs: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)/mkflfs install

$(hostprefix)/bin/checkImage: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)/checkImage install INSTALLDIR=$(hostprefix)/bin

$(DEPDIR)/liblzma465: @DEPENDS_liblzma465@ directories
	@PREPARE_liblzma465@
	cd @DIR_liblzma465@/C && \
		$(CC) -c $(CFLAGS) -o LzmaDec.o LzmaDec.c && \
		$(CC) -c $(CFLAGS) -o LzmaEnc.o LzmaEnc.c && \
		$(CC) -c $(CFLAGS) -o LzFind.o LzFind.c && \
		$(AR) rcs liblzma.a LzmaDec.o LzmaEnc.o LzFind.o && \
		ranlib liblzma.a && \
		$(INSTALL) -D liblzma.a $(hostprefix)/lib/liblzma465.a && \
		$(INSTALL) -d $(hostprefix)/include/lzma465 && \
		$(INSTALL) LzmaDec.h $(hostprefix)/include/lzma465/ && \
		$(INSTALL) LzmaEnc.h $(hostprefix)/include/lzma465/ && \
		$(INSTALL) Types.h $(hostprefix)/include/lzma465/
	@CLEANUP_liblzma465@
	touch $@

$(hostprefix)/bin/mkfs.jffs2: liblzma465 $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)/mkfs.jffs2 install INSTALLDIR=$(hostprefix)/bin

$(hostprefix)/bin/mkcramfs: @DEPENDS_cramfs@
	@PREPARE_cramfs@
	cd @DIR_cramfs@ && \
	$(MAKE) mkcramfs && \
	$(INSTALL) mkcramfs $@
	rm -rf @DIR_cramfs@

#######################
#
# mksquashfs with or without LZMA support
#
$(hostprefix)/bin/mksquashfs-lzma: directories @DEPENDS_squashfs@
	rm -rf @DIR_squashfs@
	mkdir -p @DIR_squashfs@
	cd @DIR_squashfs@ && \
	gunzip -cd ../Archive/squashfs3.0.tar.gz | TAPE=- tar -x
	cd @DIR_squashfs@ && \
	bunzip2 -cd ../Archive/lzma442.tar.bz2 | TAPE=- tar -x && \
	patch -p1 < ../Patches/lzma_zlib-stream.diff && \
	patch -p0 < ../Patches/mksquashfs_lzma.diff
	$(MAKE) -C @DIR_squashfs@/C/7zip/Compress/LZMA_Lib
	$(MAKE) -C @DIR_squashfs@/squashfs3.0/squashfs-tools
	$(INSTALL) -m755 @DIR_squashfs@/squashfs3.0/squashfs-tools/mksquashfs $@
	rm -rf @DIR_squashfs@

$(hostprefix)/bin/mksquashfs-nolzma: directories @DEPENDS_squashfs@
	rm -rf @DIR_squashfs@
	mkdir -p @DIR_squashfs@
	cd @DIR_squashfs@ && \
	gunzip -cd ../Archive/squashfs3.0.tar.gz | TAPE=- tar -x
	$(MAKE) -C @DIR_squashfs@/squashfs3.0/squashfs-tools
	$(INSTALL) -m755 @DIR_squashfs@/squashfs3.0/squashfs-tools/mksquashfs $@
	rm -rf @DIR_squashfs@

endif

# if we cannot use the host's depmod for whatever reason, use this one.
$(DEPDIR)/host_module_init_tools: $(hostprefix)/bin/depmod
$(hostprefix)/bin/depmod:
	@PREPARE_module_init_tools@
	cd @DIR_module_init_tools@ && \
		./configure \
			--prefix= && \
		$(MAKE)
	$(INSTALL) -m755 @DIR_module_init_tools@/depmod $@
	@CLEANUP_module_init_tools@

.PHONY: $(hostappsdir)/config.status
