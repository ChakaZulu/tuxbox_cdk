if ENABLE_SAMBASERVER

$(DEPDIR)/sambaserver: bootstrap @DEPENDS_samba@
	@PREPARE_samba@
if TARGETRULESET_UCLIBC
	sed -i "/#include <rpcsvc\/ypclnt.h>/d" @DIR_samba@/source/includes.h
	sed -i  -e "s/-DNETGROUP//g" \
		-e "s/powerpc-tuxbox-linux-gnu-gcc/powerpc-tuxbox-linux-uclibc-gcc/g" \
	@DIR_samba@/source/Makefile
endif
	cd @DIR_samba@ && \
		$(INSTALL) -m 644 examples/dbox/smb.conf.dbox $(targetprefix)/var/etc && \
		cd source && \
		$(MAKE) make_smbcodepage CC=$(CC) && \
		$(INSTALL) -d $(targetprefix)/lib/codepages && \
		./make_smbcodepage c 850 codepage_def.850 \
			$(targetprefix)/lib/codepages/codepage.850 && \
		$(MAKE) clean && \
		for i in smbd nmbd smbclient smbmount smbmnt smbpasswd; do \
			$(MAKE) $$i; \
			$(INSTALL) $$i $(targetprefix)/bin; \
		done 
	@CLEANUP_samba@
	touch $@

if TARGETRULESET_FLASH
flash-sambaserver: $(flashprefix)/root/sbin/smbd

$(flashprefix)/root/sbin/smbd: bootstrap @DEPENDS_samba@ | $(flashprefix)/root
	@PREPARE_samba@
if TARGETRULESET_UCLIBC
	sed -i "/#include <rpcsvc\/ypclnt.h>/d" @DIR_samba@/source/includes.h
	sed -i  -e "s/-DNETGROUP//g" \
		-e "s/powerpc-tuxbox-linux-gnu-gcc/powerpc-tuxbox-linux-uclibc-gcc/g" \
	@DIR_samba@/source/Makefile
endif
	cd @DIR_samba@ && \
		$(INSTALL) -m 644 examples/dbox/smb.conf.dbox $(flashprefix)/root/var/etc && \
		cd source && \
		$(MAKE) make_smbcodepage CC=$(CC) && \
		$(INSTALL) -d $(flashprefix)/root/lib/codepages && \
		./make_smbcodepage c 850 codepage_def.850 \
			$(flashprefix)/root/lib/codepages/codepage.850 && \
		$(MAKE) clean && \
		for i in smbd nmbd smbpasswd; do \
			$(MAKE) $$i; \
			$(INSTALL) $$i $(flashprefix)/root/bin; \
		done
	@CLEANUP_samba@
	@FLASHROOTDIR_MODIFIED@

endif

endif
