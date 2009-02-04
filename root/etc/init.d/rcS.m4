dnl This file generates rcS and (with macro insmod defined) rcS.insmod
dnl
dnl Most of its "power" comes from the macro loadmodule, that is expanded
dnl differently depending upon if insmod is defined or not.
dnl 
changequote({,})dnl
define({loadmodule},{ifdef({insmod},{$IM ${{MD}}$1 $2},{modprobe $1 $2})})dnl
define({ifmarkerfile},{if [ -e /var/etc/.$1 ]; then
	$2
ifelse($3,,,{else
	$3})
fi})dnl
define({runprogifexists},{if [ -e $1 ]; then
	$2 $3
fi})dnl
define({runaltprogifexists},{if [ -e $1 ]; then
	$2
else
	$3
fi})dnl
define({runprogcreatedirifexists},{if [ -e $1 ]; then
	if [ ! -d $2 ]; then
		mkdir $2
	fi
	$3
fi})dnl
define({runifexists},{if [ -x $1 ]; then
	$1 $2
fi})dnl
dnl
dnl
#!/bin/sh
# This file was automatically generated from rcS.m4
#
PATH=/sbin:/bin
ifdef({insmod},{IM=/sbin/{insmod}
MD=/lib/modules/$(uname -r)/misc/
})dnl

# extract kernel minor without using cut
OLD_IFS=$IFS
IFS='.'
get_second() {{ echo $2; }}
KMINOR=`get_second $(uname -r)`
IFS=$OLD_IFS

if [ $KMINOR -ge 6 ]; then
	MD=
	mount -t proc proc /proc
	mount -t tmpfs tmp /tmp
	mount -t tmpfs dev /dev
	mount -t sysfs sys /sys
	echo "/sbin/hotplug" > /proc/sys/kernel/hotplug
	# create necessary nodes,
	# static for now, i am just too lazy for udev :-)
	mkdir -p /dev/pts /dev/dbox /dev/dvb/adapter0 /dev/loop /dev/i2c /dev/input /dev/sound /dev/v4l /dev/fb /dev/vc /dev/mtdblock /dev/mtd /dev/tts
	if type -p makedevices; then
		makedevices
	else
		# in theory, now it is too late to create /dev/console...
		mknod /dev/console c 5 1
		mknod /dev/null c 1 3
		mknod /dev/tty c 5 0
		mknod /dev/tty0 c 4 0
		mknod /dev/tty1 c 4 1
		mknod /dev/tty2 c 4 2
		mknod /dev/tty3 c 4 3
		mknod /dev/ptmx c 5 2

		mknod /dev/urandom c 1 9
		mknod /dev/random c 1 8
		mknod /dev/mem c 1 1
		mknod /dev/kmem c 1 2

		mknod /dev/watchdog c 10 130

		mknod /dev/dvb/adapter0/audio0 c 212 1
		mknod /dev/dvb/adapter0/ca0 c 212 6
		mknod /dev/dvb/adapter0/ca1 c 212 22
		mknod /dev/dvb/adapter0/demux0 c 212 4
		mknod /dev/dvb/adapter0/dvr0 c 212 5
		mknod /dev/dvb/adapter0/frontend0 c 212 3
		mknod /dev/dvb/adapter0/net0 c 212 7
		mknod /dev/dvb/adapter0/video0 c 212 0
		
		mknod /dev/fb0 c 29 0

		mknod /dev/v4l/video0 c 81 0
		
		mknod /dev/sound/dsp c 14 3
		mknod /dev/sound/mixer c 14 0
		mknod /dev/sound/mixer1 c 14 16
		
		mknod /dev/input/event0 c 13 64
		mknod /dev/input/mouse0 c 13 32
		mknod /dev/input/mice c 13 63

		mknod /dev/i2c/0 c 89 0

		# 6 loop devices are enough.
		for i in 0 1 2 3 4 5; do
			mknod /dev/loop/$i b 7 $i
			mknod /dev/mtdblock/$i b 31 $i
		done
		mknod /dev/mtd/0 c 90 0
		mknod /dev/mtd/1 c 90 2
		mknod /dev/mtd/2 c 90 4
		mknod /dev/mtd/3 c 90 6
		mknod /dev/mtd/4 c 90 8
		mknod /dev/mtd/5 c 90 10
		mknod /dev/mtd/0ro c 90 1
		mknod /dev/mtd/1ro c 90 3
		mknod /dev/mtd/2ro c 90 5
		mknod /dev/mtd/3ro c 90 7
		mknod /dev/mtd/4ro c 90 9
		mknod /dev/mtd/5ro c 90 11

		mknod /dev/tts/0 c 4 64
		mknod /dev/tts/1 c 4 65
	fi
	# devices with dynamic minor numbers are created by /sbin/hotplug

	ln -sf /dev/fb0 /dev/fb/0
	ln -sf /dev/tty0 /dev/vc/0
		
	mount /dev/pts
fi

if [ $KMINOR -ge 6 ]; then
	# everything else is already mounted
	mount /var
else
	# Mount file systems in /etc/fstab
	mount -a
fi

# If appropriate, load ide drivers and file system drivers
if [ $KMINOR -ge 6 ]; then
	# kernel 2.6
	if [ -e /lib/modules/$(uname -r)/extra/ide/dboxide.ko ] ; then
		loadmodule(dboxide)
	fi
else
	# kernel 2.4
	if [ -e /lib/modules/$(uname -r)/misc/dboxide.o ] ; then
		loadmodule(ide-core)
		loadmodule(dboxide)
		loadmodule(ide-detect)
		loadmodule(ide-disk)
		loadmodule(ext2)
		loadmodule(jbd)
		loadmodule(ext3)
		loadmodule(xfs)
	fi
fi

# Turn on swap
ifmarkerfile({swap},{swapon -a})

runprogifexists({/var/tuxbox/config/target0.hdparm},{hdparm},{"`cat /var/tuxbox/config/target0.hdparm`" /dev/ide/host0/bus0/target0/lun0/disc})
runprogifexists({/var/tuxbox/config/target1.hdparm},{hdparm},{"`cat /var/tuxbox/config/target1.hdparm`" /dev/ide/host0/bus0/target1/lun0/disc})

# Set time zone etc
. /etc/profile
  
# Setup hostname
hostname -F /etc/hostname
ifup -a

ifdef({insmod},{loadmodule(event)},{type -p depmod > /dev/null && touch /etc/modules.conf && depmod -ae}) dnl

loadmodule(tuxbox)

# Get info about the current box
eval `/bin/tuxinfo -e`

echo "Detected STB:"
echo "	Vendor: $VENDOR"
echo "	Model: $MODEL $SUBMODEL"

loadmodule(dvb-core, dvb_shutdown_timeout=0)

if [ $MODEL_ID -eq 2 ]; then
	# Dreambox, not supported
	echo "For the Dreambox, please use another version"
	exit 1
fi

if [ $KMINOR -ge 6 ]; then
	# kernel 2.6

	dnl FIXME: using loadmodule makes no sense here
	dnl since modprobe is used to pull in the dependencies

	# I2C core
	loadmodule(dbox2_i2c)
	# load order is somehow important, if dbox2_napi (which pulls in
	# e.g. the demodulator drivers) is loaded first, at least tda80{xx,44h}
	# hang while initalizing the i2c-bus :-(
	loadmodule(saa7126)
	loadmodule(avs)
	loadmodule(lcd)

	loadmodule(dbox2_fp_input)

	loadmodule(dbox2_napi)

	loadmodule(avia_gt_fb)
	loadmodule(avia_gt_lirc)
	loadmodule(avia_gt_oss)
	loadmodule(avia_gt_v4l2)

	loadmodule(aviaEXT)
else
	# kernel 2.4

	# I2C core
	loadmodule(dbox2_i2c)

	# Frontprocessor
	loadmodule(dbox2_fp)
	loadmodule(lcd)
	if [ -e /var/etc/.oldrc ]; then
    		loadmodule(dbox2_fp_input, disable_new_rc=1)
	elif [ -e /var/etc/.newrc ]; then
		loadmodule(dbox2_fp_input, disable_old_rc=1)
	elif [ -e /var/etc/.philips_rc_patch ]; then
		loadmodule(dbox2_fp_input, philips_rc_patch=1)
	else
			loadmodule(dbox2_fp_input)
	fi

	# Misc IO
	loadmodule(avs)
	loadmodule(saa7126)

	# Frontends
	if [ $VENDOR_ID -eq 1 ]; then
		# Nokia
		loadmodule(ves1820)
		loadmodule(ves1x93, board_type=1)
		loadmodule(cam, mio=0xC000000 firmware=/var/tuxbox/ucodes/cam-alpha.bin)
	elif [ $VENDOR_ID -eq 2 ]; then
		# Philips
		ifmarkerfile({tda80xx.o},
			{loadmodule(tda80xx)},
			{loadmodule(tda8044h)})
		loadmodule(cam, mio=0xC040000 firmware=/var/tuxbox/ucodes/cam-alpha.bin)
	elif [ $VENDOR_ID -eq 3 ]; then
		# Sagem
		loadmodule(at76c651)
		loadmodule(ves1x93, board_type=2)
		loadmodule(cam, mio=0xC000000 firmware=/var/tuxbox/ucodes/cam-alpha.bin)
	fi

	loadmodule(dvb_i2c_bridge)

	loadmodule(avia_napi)
	loadmodule(cam_napi)
	loadmodule(dbox2_fp_napi)

	# Possibly turn off the watchdog on AVIA 500
	ifmarkerfile({no_watchdog},
		{loadmodule(avia_av, firmware=/var/tuxbox/ucodes no_watchdog=1)},
		{loadmodule(avia_av, firmware=/var/tuxbox/ucodes)})

	# Bei Avia_gt hw_sections und nowatchdog abfragen
	GTOPTS=""
	ifmarkerfile({hw_sections},{GTOPTS="hw_sections=0 "})
	ifmarkerfile({no_enxwatchdog},{GTOPTS="${{GTOPTS}}no_watchdog=1 "})

	loadmodule(avia_gt, {ucode=/var/tuxbox/ucodes/ucode.bin ${GTOPTS}})
  
	loadmodule(avia_gt_fb, console_transparent=0)
	loadmodule(avia_gt_lirc)
	loadmodule(avia_gt_oss)
	loadmodule(avia_gt_v4l2)

	loadmodule(avia_av_napi)
	ifmarkerfile({spts_mode},
		{loadmodule(avia_gt_napi, mode=1)
			loadmodule(dvb2eth)},
		{loadmodule(avia_gt_napi)})

	loadmodule(aviaEXT)
fi

# Create a telnet greeting
echo "$VENDOR $MODEL - Kernel %r (%t)." > /etc/issue.net

# compatibility links
if [ $KMINOR -lt 6 ]; then
	# compatibility links
	ln -sf demux0 /dev/dvb/adapter0/demux1
	ln -sf dvr0 /dev/dvb/adapter0/dvr1
	ln -sf fb/0 /dev/fb0
fi

if [ ! -d /var/etc ] ; then
    mkdir /var/etc
fi

runprogcreatedirifexists({/sbin/syslogd},{/var/log},{/sbin/syslogd})
runprogifexists({/var/tuxbox/config/lirc/lircd.conf},{lircd},
	{/var/tuxbox/config/lirc/lircd.conf})
runifexists({/bin/loadkeys},{/share/keymaps/i386/qwertz/de-latin1-nodeadkeys.kmap.gz})
runifexists({/sbin/inetd})
runprogifexists({/sbin/sshd},{/etc/init.d/start_sshd},{&})
runifexists({/sbin/dropbear})
runprogifexists({/sbin/automount},{/etc/init.d/start_automount})
runprogifexists({/bin/djmount},{/etc/init.d/start_upnp})
ifmarkerfile({boot_info},{runifexists({/bin/cdkVcInfo})})

# If appropriate, load smbfs driver
if [ -e /lib/modules/$(uname -r)/kernel/fs/smbfs/smbfs.ko -o -e /lib/modules/$(uname -r)/kernel/fs/smbfs/smbfs.o ] ; then
	loadmodule(smbfs)
fi

# Start the nfs server if /etc/exports exists
runprogifexists({/etc/exports},{loadmodule(nfsd)
	pidof portmap >/dev/null || portmap
	exportfs -r
	rpc.mountd
	rpc.nfsd 3})	

#Start the samba server if /var/etc/.sambaserver and /etc/smb.conf.dbox exist
ifmarkerfile({sambaserver},{if [ -e /etc/smb.conf -a -x /bin/nmbd -a -x /bin/smbd ]; then
		/bin/nmbd -D
		/bin/smbd -D -a -s /etc/smb.conf
	fi})

ifmarkerfile({tuxmaild},{tuxmaild})
ifmarkerfile({tuxcald},{tuxcald})
ifmarkerfile({rdate},{rdate time.fu-berlin.de})
ifmarkerfile({initialize},{/etc/init.d/initialize && rm /var/etc/.initialize})

if [ -e /var/etc/init.d/rcS.local ]; then
	. /var/etc/init.d/rcS.local
elif [ -e /etc/init.d/rcS.local ]; then
	. /etc/init.d/rcS.local
fi
