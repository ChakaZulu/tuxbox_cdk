#######################
#
#   database
#

if ENABLE_SQLITE
$(DEPDIR)/sqlite: bootstrap @DEPENDS_sqlite@
	@PREPARE_sqlite@
	cd @DIR_sqlite@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_sqlite@
	@CLEANUP_sqlite@
	touch $@

if TARGETRULESET_FLASH
flash-sqlite: $(flashprefix)/root/bin/sqlite3

$(flashprefix)/root/bin/sqlite3: @DEPENDS_sqlite@ | $(flashprefix)/root
	@PREPARE_sqlite@
	cd @DIR_sqlite@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(flashprefix)/root && \
		$(MAKE) all && \
		@INSTALL_sqlite@
	@CLEANUP_sqlite@
	@FLASHROOTDIR_MODIFIED@

endif

endif
