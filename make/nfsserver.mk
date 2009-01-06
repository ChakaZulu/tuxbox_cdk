if ENABLE_NFSSERVER

nfsserver: portmap nfs-utils

# nfs-utils
# needed for nfs server.

$(DEPDIR)/nfs-utils: bootstrap @DEPENDS_nfs_utils@
	@PREPARE_nfs_utils@
	chmod +x @DIR_nfs_utils@/autogen.sh
	cd @DIR_nfs_utils@  && \
		$(CONFIGURE) \
		CC_FOR_BUILD=$(target)-gcc \
		--disable-gss \
		--disable-nfsv4 \
		--prefix= \
		--without-tcp-wrappers \
		--disable-uuid && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(targetprefix)
	rm -rf @DIR_nfs_utils@
	@touch $@

if TARGETRULESET_FLASH
flash-nfsserver: flash-portmap flash-nfs-utils

# nfs-utils
# needed for nfs server.

flash-nfs-utils: $(flashprefix)/root/sbin/rpc.nfsd

$(flashprefix)/root/sbin/rpc.nfsd: bootstrap @DEPENDS_nfs_utils@ | $(flashprefix)/root
	@PREPARE_nfs_utils@
	chmod +x @DIR_nfs_utils@/autogen.sh
	cd @DIR_nfs_utils@  && \
		$(CONFIGURE) \
		CC_FOR_BUILD=$(target)-gcc \
		--disable-gss \
		--disable-nfsv4 \
		--prefix= \
		--without-tcp-wrappers \
		--disable-uuid && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(flashprefix)/root SUBDIRS= && \
		$(MAKE) -C utils/exportfs DESTDIR=$(flashprefix)/root install && \
		$(MAKE) -C utils/mountd DESTDIR=$(flashprefix)/root install   && \
		$(MAKE) -C utils/nfsd DESTDIR=$(flashprefix)/root install
	rm -rf @DIR_nfs_utils@
	@FLASHROOTDIR_MODIFIED@

endif

endif
