if ENABLE_DRIVE_GUI
FSTAB_RW = \
	chmod -fv 666 $(targetprefix)/etc/fstab
endif

yadd-etc: $(targetprefix)/etc/init.d/rcS
 
$(targetprefix)/etc/init.d/rcS:
	$(MAKE) -C root install
if ENABLE_IDE
	$(MK_FSTAB_IDEMOUNTS)
endif
	$(FSTAB_RW)





