install-data-local:
	@$(MAKE) install-$(TARGETRULESET)

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
		file=`echo "$$i" | sed -e 's,-flash$$,,'` ; \
		echo "install -m644 $$i $(flashprefix_ro)$(DIR)/$$file" ; \
		install -m644 $$i $(flashprefix_ro)$(DIR)/$$file ; \
	done
	@files="$(FILES_FLASH_RW)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_rw)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,-flash$$,,'` ; \
		echo "install -m644 $$i $(flashprefix_rw)$(DIR)/$$file" ; \
		install -m644 $$i $(flashprefix_rw)$(DIR)/$$file ; \
	done
	@files="$(FILES_FLASH_RO_EXEC)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_ro)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,-flash$$,,'` ; \
		echo "install -m755 $$i $(flashprefix_ro)$(DIR)/$$file" ; \
		install -m755 $$i $(flashprefix_ro)$(DIR)/$$file ; \
	done
	@files="$(FILES_FLASH_RW_EXEC)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_rw)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,-flash$$,,'` ; \
		echo "install -m755 $$i $(flashprefix_rw)$(DIR)/$$file" ; \
		install -m755 $$i $(flashprefix_rw)$(DIR)/$$file ; \
	done

