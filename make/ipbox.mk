@DIR_uboot@/u-boot.ipbox: bootstrap @DEPENDS_uboot@ $(bootdir)/u-boot-config/u-boot.config
	@PREPARE_uboot@
	cp -pR $(bootdir)/u-boot-tuxbox/* @DIR_uboot@
	cd @DIR_uboot@ && patch -p1 -E -i ../Patches/u-boot-1.2.0-ipbox.diff
	cp -p $(bootdir)/u-boot-config/u-boot.config u-boot-1.2.0/include/configs/$(IPBOX_UBOOT_TARGET).h
	$(MAKE) -C u-boot-1.2.0 $(IPBOX_UBOOT_TARGET)_config
	$(MAKE) -C u-boot-1.2.0 CROSS_COMPILE=$(target)-

$(flashprefix)/u-boot.bin \
$(bootdir)/u-boot-config/$(IPBOX_UBOOT_TARGET).h:
	cp $(bootdir)/u-boot-config/$(IPBOX_UBOOT_TARGET).h $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.ipbox
	cp @DIR_uboot@/System.map $(flashprefix)/u-boot_System.map
	cp @DIR_uboot@/u-boot.bin $(flashprefix)/
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

ipbox_flash_imgs: $(flashprefix)/flash_img_low $(flashprefix)/flash_img_high $(flashprefix)/flash_img_noboot $(flashprefix)/flash_img_kernel_root

$(flashprefix)/config.img:
	dd if=/dev/zero of=$@ bs=8K count=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks config`

$(flashprefix)/welcome.img: $(buildprefix)/../hostapps/flashmaps/bootlogo.m1v $(buildprefix)/../hostapps/dgstation/convbmp $(buildprefix)/../hostapps/dgstation/mkwelcomeimg
	$(buildprefix)/../hostapps/dgstation/mkwelcomeimg -todo addheader -compress_type 3  -input $< -output $@

$(flashprefix)/welcome_iframe: $(WELCOME) $(buildprefix)/../hostapps/dgstation/mkwelcomeimg
	$(buildprefix)/../hostapps/dgstation/mkwelcomeimg.iframe -todo addheader -input $@.tmp -output $@ || { rm $@; false; }

$(flashprefix)/kernel.img: $(flashprefix)/vmlinux $(buildprefix)/../hostapps/dgstation/mkubootimage
	$(target)-objcopy -O binary -R .note -R .comment -S $< $<.bin
	gzip -f9 $<.bin
	$(buildprefix)/../hostapps/dgstation/mkubootimage -A ppc -O linux -T kernel -C gzip -a 0 -e 0 -n "Linux Kernel Image" -d $<.bin.gz $@
	rm $<.bin.gz

$(flashprefix)/db.img: $(flashprefix)/db $(MKJFFS2)
	@if [ "$(MKJFFS2)" = "/bin/false" ] ; then \
		echo "FATAL ERROR: No mkjffs2 or mkfs.jffs2 available"; \
		false; \
	fi
	$(MKJFFS2) -d $< -b -e 65536 -o $@

$(flashprefix)/uboot.img: $(flashprefix)/u-boot.bin
	cp -f $< $@

$(flashprefix)/part_uboot.img: $(flashprefix)/uboot.img $(buildprefix)/../hostapps/dgstation/appendbin
	rm -f $@
	$(buildprefix)/../hostapps/dgstation/appendbin -bs=0x2000 $@ $< `$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks uboot` || { rm $@; exit 1; }

$(flashprefix)/part_db.img: $(flashprefix)/db.img $(buildprefix)/../hostapps/dgstation/appendbin
	rm -f $@
	$(buildprefix)/../hostapps/dgstation/appendbin -bs=0x2000 $@ $< `$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks db` || { rm $@; exit 1; }

$(flashprefix)/part_kernel.img: $(flashprefix)/kernel.img $(buildprefix)/../hostapps/dgstation/appendbin
	rm -f $@
	$(buildprefix)/../hostapps/dgstation/appendbin -bs=0x2000 $@ $< `$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks kernel` || { rm $@; exit 1; }

$(flashprefix)/part_root.img: $(flashprefix)/root-neutrino.squashfs $(buildprefix)/../hostapps/dgstation/appendbin
	rm -f $@
	$(buildprefix)/../hostapps/dgstation/appendbin -bs=0x2000 $@ $< `$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks root` || { rm $@; exit 1; }

$(flashprefix)/part_config.img: $(flashprefix)/config.img $(buildprefix)/../hostapps/dgstation/appendbin
	rm -f $@
	$(buildprefix)/../hostapps/dgstation/appendbin -bs=0x2000 $@ $< `$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks config` || { rm $@; exit 1; }

$(flashprefix)/part_welcome.img: $(flashprefix)/welcome.img $(buildprefix)/../hostapps/dgstation/appendbin
	rm -f $@
	$(buildprefix)/../hostapps/dgstation/appendbin -bs=0x2000 $@ $< `$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks welcome` || { rm $@; exit 1; }

$(flashprefix)/flash_img: $(flashprefix)/part_config.img $(flashprefix)/part_welcome.img $(flashprefix)/part_kernel.img $(flashprefix)/part_root.img $(flashprefix)/part_db.img $(flashprefix)/part_uboot.img 
	rm -f $@
	dd if=$(flashprefix)/part_config.img of=$@ bs=8K seek=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) offset_blocks config` count=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks config`
	dd if=$(flashprefix)/part_welcome.img of=$@ bs=8K seek=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) offset_blocks welcome` count=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks welcome`
	dd if=$(flashprefix)/part_kernel.img of=$@ bs=8K seek=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) offset_blocks kernel` count=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks kernel`
	dd if=$(flashprefix)/part_root.img of=$@ bs=8K seek=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) offset_blocks root` count=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks root`
	dd if=$(flashprefix)/part_db.img of=$@ bs=8K seek=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) offset_blocks db` count=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks db`
	dd if=$(flashprefix)/part_uboot.img of=$@ bs=8K seek=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) offset_blocks uboot` count=`$(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks uboot`

$(flashprefix)/flash_img_low: $(flashprefix)/flash_img
	dd if=$< of=$@ bs=64K count=64

$(flashprefix)/flash_img_high: $(flashprefix)/flash_img
	dd if=$< of=$@ bs=64K skip=64 count=64

$(flashprefix)/flash_img_noboot: $(flashprefix)/flash_img
	dd if=$< of=$@ bs=64K count=`BLOCK_SIZE=0x10000 $(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks 0 -2`

$(flashprefix)/flash_img_kernel_root: $(flashprefix)/flash_img
	dd if=$< of=$@ bs=64K skip=`BLOCK_SIZE=0x10000 $(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) offset_blocks kernel` count=`BLOCK_SIZE=0x10000 $(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks kernel root`

$(flashprefix)/flash_img_kernel_root_db: $(flashprefix)/flash_img
	dd if=$< of=$@ bs=64K skip=`BLOCK_SIZE=0x10000 $(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) offset_blocks kernel` count=`BLOCK_SIZE=0x10000 $(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks kernel db`

$(flashprefix)/flash_img_kernel_root_db_uboot: $(flashprefix)/flash_img
	dd if=$< of=$@ bs=64K skip=`BLOCK_SIZE=0x10000 $(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) offset_blocks kernel` count=`BLOCK_SIZE=0x10000 $(buildprefix)/../hostapps/flashmaps/$(IPBOX_FLASH_MAP) blocks kernel uboot`
