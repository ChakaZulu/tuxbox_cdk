if KERNEL26
# this contains the fuse library and tools and the fuse kernelmodule if kernel 2.6 is enabled
$(DEPDIR)/fuse: bootstrap @DEPENDS_fuse@
	@PREPARE_fuse@
	cd @DIR_fuse@ && \
	$(BUILDENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --with-kernel=$(buildprefix)/$(KERNEL_DIR) \
	   --prefix= && \
	$(MAKE) all && \
	@INSTALL_fuse@
	@CLEANUP_fuse@
	touch $@
else
# this contains the fuse library and tools if kernel 2.4 is enabled
$(DEPDIR)/fuse: bootstrap $(DEPDIR)/fusekernel @DEPENDS_fuse@
	@PREPARE_fuse@
	cd @DIR_fuse@ && \
	$(BUILDENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --disable-kernel-module \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(targetprefix)
	@CLEANUP_fuse@
	touch $@
endif

# this contains the fuse kernelmodule for linux-2.4.x, fuse-2.6.x does only support kernel 2.6.x
$(DEPDIR)/fusekernel: bootstrap @DEPENDS_fusekernel@
	@PREPARE_fusekernel@
	cd @DIR_fusekernel@ && \
	$(BUILDENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --with-kernel=$(buildprefix)/$(KERNEL_DIR) \
	   --disable-lib \
	   --disable-util \
	   --disable-example \
	   --prefix= && \
	$(MAKE) all && \
	@INSTALL_fusekernel@
	@CLEANUP_fusekernel@
	touch $@

$(DEPDIR)/djmount: bootstrap fuse @DEPENDS_djmount@
	@PREPARE_djmount@
	cd @DIR_djmount@ && \
	$(BUILDENV) \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(targetprefix)
	@CLEANUP_djmount@
	touch $@

if TARGETRULESET_FLASH

flash-upnp: flash-fuse flash-djmount

if KERNEL26
# this contains the fuse library and tools and the fuse kernelmodule if kernel 2.6 is enabled
flash-fuse: bootstrap @DEPENDS_fuse@
	@PREPARE_fuse@
	cd @DIR_fuse@ && \
	$(BUILDENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --with-kernel=$(buildprefix)/$(KERNEL_DIR) \
	   --prefix= && \
	$(MAKE) all && \
	@INSTALL_fuse@
	@CLEANUP_fuse@
	@FLASHROOTDIR_MODIFIED@
else
# this contains the fuse library and tools if kernel 2.4 is enabled
flash-fuse: bootstrap $(DEPDIR)/fusekernel flash-fusekernel @DEPENDS_fuse@
	@PREPARE_fuse@
	cd @DIR_fuse@ && \
	$(BUILDENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --disable-kernel-module \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install-exec DESTDIR=$(flashprefix)/root
	rm -f $(flashprefix)/root/lib/libfuse.a $(flashprefix)/root/lib/libfuse.la
	rm -f $(flashprefix)/root/lib/libulockmgr.a $(flashprefix)/root/lib/libulockmgr.la
	@CLEANUP_fuse@
	@FLASHROOTDIR_MODIFIED@
endif

# this contains the fuse kernelmodule for linux-2.4.x, fuse-2.6.x does only support kernel 2.6.x
flash-fusekernel: bootstrap @DEPENDS_fusekernel@
	@PREPARE_fusekernel@
	cd @DIR_fusekernel@ && \
	$(BUILDENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --with-kernel=$(buildprefix)/$(KERNEL_DIR) \
	   --disable-lib \
	   --disable-util \
	   --disable-example \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) -C kernel install DESTDIR=$(flashprefix)/root
	@CLEANUP_fusekernel@
	@FLASHROOTDIR_MODIFIED@

flash-djmount: bootstrap flash-fuse @DEPENDS_djmount@
	@PREPARE_djmount@
	cd @DIR_djmount@ && \
	$(BUILDENV) \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(flashprefix)/root
	@CLEANUP_djmount@
	@FLASHROOTDIR_MODIFIED@

endif

.PHONY: flash-upnp flash-fuse flash-djmount
