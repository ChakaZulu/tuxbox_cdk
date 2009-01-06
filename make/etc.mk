yadd-etc: $(targetprefix)/etc/init.d/rcS

$(targetprefix)/etc/init.d/rcS: root/etc/init.d/rcS.m4
	$(MAKE) -C root install
if ENABLE_IDE
	echo $(HDD_MOUNT_ENTRY)	>> $(targetprefix)/etc/fstab
endif
