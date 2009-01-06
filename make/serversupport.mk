################ Server Support ################

serversupport: dboxflasher dhcp.conf exports tftp hosts

dhcp.conf: $(serversupport)/etc/dhcpd.conf

$(serversupport)/etc:
	$(INSTALL) -d $@

$(serversupport)/etc/dhcpd.conf: $(serversupport)/etc Makefile
	@echo "Creating $@"
	@echo "# This is a template for dhcp.conf" 			> $@
	@echo "# Copy to the appropriate location for your server,"	>> $@
	@echo "# typically /etc/dhcp.conf." 				>> $@
	@echo "# You may have to modify this file manually."		>> $@
	@echo "# Please see the documentation for your server and for dhcpd."	>> $@
	@echo "" 							>> $@
	@echo "ddns-update-style none;"					>> $@
	@echo "subnet $(DBOX_SUBNET) netmask $(DBOX_SUBNETMASK) {"	>> $@
	@echo "}"							>> $@
	@echo ""							>> $@
	@echo "host dbox {"						>> $@
	@echo "	fixed-address $(DBOX_IP);"				>> $@
	@echo "	hardware ethernet $(DBOX_MAC);"				>> $@
	@echo "	allow bootp;"						>> $@
	@echo "	server-name \"`uname -n`\";"				>> $@
	@echo "	next-server \"`uname -n`\";"				>> $@
	@echo "	option root-path \"$(targetprefix)\";"			>> $@
	@echo "	if exists vendor-class-identifier {"			>> $@
	@echo "		filename \"kernel-cdk\";"			>> $@
	@echo "	} else {"						>> $@
	@echo "		filename \"u-boot\";"				>> $@
	@echo "	}"							>> $@
	@echo "}"							>> $@

exports: $(serversupport)/etc/exports

$(serversupport)/etc/exports: $(serversupport)/etc Makefile
	@echo "Creating $@"
	@echo "# On a Linux system, this file may be appended to /etc/exports in order to"	> $@
	@echo "# export the appropriate filesystem to the dbox,"	>> $@
	@echo "# which is assumed to have the IP-name \`dbox'."		>> $@
	@echo "$(targetprefix)	dbox(rw,sync,no_root_squash)"		>> $@

tftp: $(serversupport)/etc/README.tftp

$(serversupport)/etc/README.tftp: Makefile
	@echo "Creating $@"
	@echo "# Make sure that you turn on the tftp-service, using "	> $@
	@echo "# $(bootprefix) as its root directory (this is most"	>> $@
	@echo "# likely not the default for your server)."		>> $@
	@echo ""							>> $@
	@echo "# See http://wiki.tuxbox.org/CDK_booten"			>> $@
	@echo "# This file MAY work as /etc/xinetd.d/tftp"		>> $@
	@echo ""							>> $@
	@echo "service tftp"						>> $@
	@echo "{"							>> $@
	@echo "	disable = no"						>> $@
	@echo "	socket_type = dgram"					>> $@
	@echo "	wait = yes"						>> $@
	@echo "	user = nobody"						>> $@
	@echo "	log_on_success += USERID"				>> $@
	@echo "	log_on_failure += USERID"				>> $@
	@echo "	server = /usr/sbin/in.tftpd"				>> $@
	@echo "	server_args = -s " $(bootprefix)			>> $@
	@echo "}"							>> $@

hosts: $(serversupport)/etc/hosts

$(serversupport)/etc/hosts: Makefile
	@echo "Creating $@"
	@echo "# If appropriate, append this to /etc/exports"		> $@
	@echo ""							>> $@
	@echo "# See http://wiki.tuxbox.org/CDK_booten"			>> $@
	@echo $(DBOX_IP)	dbox					>> $@

dboxflasher: $(bootprefix)/dboxflasher

$(bootprefix)/dboxflasher: $(bootdir)/u-boot-config/u-boot.flasher.dbox2.h
	ln -sf $(bootdir)/u-boot-config/u-boot.flasher.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(INSTALL) -d $(bootprefix)
	$(INSTALL) -m644 @DIR_uboot@/u-boot.stripped $@
	if [ -e $(logosdir)/dboxflasher-fb ] ; then \
		$(INSTALL) -m644 $(logosdir)/dboxflasher-fb $(bootprefix); \
	fi
	if [ -e $(logosdir)/dboxflasher-lcd ] ; then \
		$(INSTALL) -m644 $(logosdir)/dboxflasher-lcd $(bootprefix); \
	fi
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

.PHONY: serversupport dboxflasher dhcp.conf exports tftp hosts
