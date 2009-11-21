install-data-local:
#	@$(MAKE) install-$(TARGETRULESET)
	@$(MAKE) install-standard

install-standard: $(FILES) $(FILES_EXEC) $(FILES_EXEC_START)
	@files="$(FILES)" ; \
	for i in $$files ; do \
		install -d $(targetprefix)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,.dbox24$$,,' -e 's,-flash$$,,'` ; \
		echo "install -m644 $$i $(targetprefix)$(DIR)/$$file" ; \
		install -m644 $$i $(targetprefix)$(DIR)/$$file ; \
	done
	@files="$(FILES_EXEC)" ; \
	for i in $$files ; do \
		install -d $(targetprefix)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,.dbox24$$,,' -e 's,-flash$$,,'` ; \
		echo "install -m755 $$i $(targetprefix)$(DIR)/$$file" ; \
		install -m755 $$i $(targetprefix)$(DIR)/$$file ; \
	done
	@files="$(FILES_EXEC_START)" ; \
	for i in $$files ; do \
		script_inst=no ; \
		install -d $(targetprefix)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,.dbox24$$,,' -e 's,-flash$$,,'` ; \
		depends=`grep "Tuxbox init script" $$i | sed "s/\# Tuxbox init script for //g"` ; \
		if [ "x$$depends" = "x" ]; then \
			script_inst=yes ; \
		else \
			if [ -f $(targetprefix)/$$depends ]; then \
				script_inst=yes ; \
			fi; \
		fi; \
		if [ "$$script_inst" = "yes" ]; then \
			echo "install -m755 $$i $(targetprefix)$(DIR)/$$file" ; \
			install -m755 $$i $(targetprefix)$(DIR)/$$file ; \
			ln -sf $$file $(targetprefix)$(DIR)/S$$file ; \
			ln -sf $$file $(targetprefix)$(DIR)/K$$file ; \
		fi ; \
	done

install-flash: $(FILES_FLASH_RO) $(FILES_FLASH_RW) $(FILES_FLASH_RO_EXEC) $(FILES_FLASH_RW_EXEC) $(FILES_FLASH_RO_EXEC_START) $(FILES_FLASH_RW_EXEC_START)
	@files="$(FILES_FLASH_RO)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_ro)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,.dbox24$$,,' -e 's,-flash$$,,'` ; \
		echo "install -m644 $$i $(flashprefix_ro)$(DIR)/$$file" ; \
		rm -f $(flashprefix_ro)$(DIR)/$$file ; \
		install -m644 $$i $(flashprefix_ro)$(DIR)/$$file ; \
	done
	@files="$(FILES_FLASH_RW)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_rw)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,.dbox24$$,,' -e 's,-flash$$,,'` ; \
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
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,.dbox24$$,,' -e 's,-flash$$,,'` ; \
		echo "install -m755 $$i $(flashprefix_ro)$(DIR)/$$file" ; \
		rm -f $(flashprefix_ro)$(DIR)/$$file ; \
		install -m755 $$i $(flashprefix_ro)$(DIR)/$$file ; \
	done
	@files="$(FILES_FLASH_RO_EXEC_START)" ; \
	for i in $$files ; do \
		script_inst=no ; \
		install -d $(flashprefix_ro)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,.dbox24$$,,' -e 's,-flash$$,,'` ; \
		depends=`grep "Tuxbox init script" $$file | sed "s/\# Tuxbox init script for //g"` ; \
		if [ "x$$depends" = "x" ]; then \
			script_inst=yes ; \
		else \
			if [ -f $(flashprefix)/$$depends ]; then \
				script_inst=yes ; \
			fi; \
		fi; \
		if [ "$$script_inst" = "yes" ]; then \
			echo "install -m755 $$i $(flashprefix_ro)$(DIR)/$$file" ; \
			rm -f $(flashprefix_ro)$(DIR)/$$file ; \
			install -m755 $$i $(flashprefix_ro)$(DIR)/$$file ; \
			ln -sf $$file $(flashprefix_ro)$(DIR)/S$$file ; \
			ln -sf $$file $(flashprefix_ro)$(DIR)/K$$file ; \
		fi ; \
	done
	@files="$(FILES_FLASH_RW_EXEC)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_rw)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,.dbox24$$,,' -e 's,-flash$$,,'` ; \
		echo "install -m755 $$i $(flashprefix_rw)$(DIR)/$$file" ; \
		rm -f $(flashprefix_rw)$(DIR)/$$file ; \
		install -m755 $$i $(flashprefix_rw)$(DIR)/$$file ; \
		if [ "$(flashprefix_rw)" != "$(flashprefix_ro)" ] ; then \
			echo "Linking $(DIR)/$$file to /var$(DIR)/$$file" ; \
			$(INSTALL) -d $(flashprefix_ro)$(DIR) ; \
			ln -sf /var$(DIR)/$$file $(flashprefix_ro)$(DIR)/$$file ; \
		fi \
	done
	@files="$(FILES_FLASH_RW_EXEC_START)" ; \
	for i in $$files ; do \
		script_inst=no ; \
		install -d $(flashprefix_rw)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,.dbox24$$,,' -e 's,-flash$$,,'` ; \
		depends=`grep "Tuxbox init script" $$file | sed "s/\# Tuxbox init script for //g"` ; \
		if [ "x$$depends" = "x" ]; then \
			script_inst=yes ; \
		else \
			if [ -f $(flashprefix)/$$depends ]; then \
				script_inst=yes ; \
			fi; \
		fi; \
		if [ "$$script_inst" = "yes" ]; then \
			echo "install -m755 $$i $(flashprefix_rw)$(DIR)/$$file" ; \
			rm -f $(flashprefix_rw)$(DIR)/$$file ; \
			install -m755 $$i $(flashprefix_rw)$(DIR)/$$file ; \
			ln -sf $$file $(flashprefix_rw)$(DIR)/S$$file ; \
			ln -sf $$file $(flashprefix_rw)$(DIR)/K$$file ; \
			if [ "$(flashprefix_rw)" != "$(flashprefix_ro)" ] ; then \
				echo "Linking $(DIR)/$$file to /var$(DIR)/$$file" ; \
				$(INSTALL) -d $(flashprefix_ro)$(DIR) ; \
				ln -sf /var$(DIR)/$$file $(flashprefix_ro)$(DIR)/$$file ; \
				ln -sf $$file $(flashprefix_ro)$(DIR)/S$$file ; \
				ln -sf $$file $(flashprefix_ro)$(DIR)/K$$file ; \
			fi; \
		fi; \
	done
	@files="$(FILES_FLASH_RW_LINK)" ; \
	for i in $$files ; do \
		install -d $(flashprefix_rw)$(DIR) ; \
		file=`echo "$$i" | sed -e 's,.$(BOXTYPE)$$,,' -e 's,.dbox24$$,,' -e 's,-flash$$,,'` ; \
		rm -f $(flashprefix_rw)$(DIR)/$$file ; \
		if [ "$(flashprefix_rw)" != "$(flashprefix_ro)" ] ; then \
			echo "Linking $(DIR)/$$file to /var$(DIR)/$$file" ; \
			$(INSTALL) -d $(flashprefix_ro)$(DIR) ; \
			ln -sf /var$(DIR)/$$file $(flashprefix_ro)$(DIR)/$$file ; \
		fi \
	done
	@dirs="$(SUBDIRS)" ; \
	for d in $$dirs ; do \
		$(MAKE) -C $$d $(AM_MAKEFLAGS) install-flash || exit 1 ; \
	done
