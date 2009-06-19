install-data-local:
#	@$(MAKE) install-$(TARGETRULESET)
	@$(MAKE) install-standard

install-standard: $(FILES) $(FILES_EXEC)
	@files="$(FILES)" ; \
	for i in $$files ; do \
		install -d $(targetprefix)$(DIR) ; \
		echo "install -m644 $$i $(targetprefix)$(DIR)" ; \
		install -m644 $$i $(targetprefix)$(DIR) ; \
	done
	@files="$(FILES_EXEC)" ; \
	for i in $$files ; do \
		install -d $(targetprefix)$(DIR) ; \
		echo "install -m755 $$i $(targetprefix)$(DIR)" ; \
		install -m755 $$i $(targetprefix)$(DIR) ; \
	done

install-flash: $(FILES_FLASH_RO) $(FILES_FLASH_RW) $(FILES_FLASH_RO_EXEC) $(FILES_FLASH_RW_EXEC)
	@files="$(FILES_FLASH_RO)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_ro)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,-flash$$,,'` ; \
		echo "install -m644 $$i $(flashprefix_ro)$(DIR)/$$file" ; \
		rm -f $(flashprefix_ro)$(DIR)/$$file ; \
		install -m644 $$i $(flashprefix_ro)$(DIR)/$$file ; \
	done
	@files="$(FILES_FLASH_RW)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_rw)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,-flash$$,,'` ; \
		echo "install -m644 $$i $(flashprefix_rw)$(DIR)/$$file" ; \
		rm -f $(flashprefix_rw)$(DIR)/$$file ; \
		install -m644 $$i $(flashprefix_rw)$(DIR)/$$file ; \
		if [ "$(flashprefix_rw)" != "$(flashprefix_ro)" ] ; then \
			echo "Linking $(DIR)/$$file to /var$(DIR)/$$file" ; \
			$(INSTALL) -d $(flashprefix_ro)$(DIR) ; \
			ln -sf /var$(DIR)/$$file $(flashprefix_ro)$(DIR)/$$file ; \
		fi \
	done
if KERNEL26
	if [ -e $(flashprefix_rw)/etc/modules.conf ]; then \
		mv -f $(flashprefix_rw)/etc/modules.conf $(flashprefix_rw)/etc/modules.conf.example ; \
		touch $(flashprefix_rw)/etc/modules.conf ; \
	fi
endif
	@files="$(FILES_FLASH_RO_EXEC)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_ro)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,-flash$$,,'` ; \
		echo "install -m755 $$i $(flashprefix_ro)$(DIR)/$$file" ; \
		rm -f $(flashprefix_ro)$(DIR)/$$file ; \
		install -m755 $$i $(flashprefix_ro)$(DIR)/$$file ; \
	done
	@files="$(FILES_FLASH_RW_EXEC)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_rw)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,-flash$$,,'` ; \
		echo "install -m755 $$i $(flashprefix_rw)$(DIR)/$$file" ; \
		rm -f $(flashprefix_rw)$(DIR)/$$file ; \
		install -m755 $$i $(flashprefix_rw)$(DIR)/$$file ; \
		if [ "$(flashprefix_rw)" != "$(flashprefix_ro)" ] ; then \
			echo "Linking $(DIR)/$$file to /var$(DIR)/$$file" ; \
			$(INSTALL) -d $(flashprefix_ro)$(DIR) ; \
			ln -sf /var$(DIR)/$$file $(flashprefix_ro)$(DIR)/$$file ; \
		fi \
	done
	@files="$(FILES_FLASH_RW_LINK)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_rw)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,-flash$$,,'` ; \
		rm -f $(flashprefix_rw)$(DIR)/$$file ; \
		if [ "$(flashprefix_rw)" != "$(flashprefix_ro)" ] ; then \
			echo "Linking $(DIR)/$$file to /var$(DIR)/$$file" ; \
			$(INSTALL) -d $(flashprefix_ro)$(DIR) ; \
			ln -sf /var$(DIR)/$$file $(flashprefix_ro)$(DIR)/$$file ; \
		fi \
	done
	@dirs="$(SUBDIRS)" ; \
	for d in $$dirs ; do \
		$(MAKE) -C $$d $(AM_MAKEFLAGS) install-flash ; \
	done
