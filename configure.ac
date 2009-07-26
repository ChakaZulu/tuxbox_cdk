AC_INIT([tuxbox-cdk],[0])
AC_PREREQ(2.57a)

AC_CANONICAL_BUILD
AC_SUBST(build)

AC_ARG_WITH(toolchain,
	[  --with-toolchain=PATH,	do not build a toolchain but use the one at PATH],
	[TOOLCHAIN_PATH="$withval"],[TOOLCHAIN_PATH="notset"])
AM_CONDITIONAL(USE_FOREIGN_TOOLCHAIN,test "$TOOLCHAIN_PATH" != "notset")
AC_SUBST(TOOLCHAIN_PATH)

AC_ARG_ENABLE(uclibc,
	AS_HELP_STRING(--enable-uclibc,	enable rules for creating uclibc linked targets),
	,[enable_uclibc=no])
AM_CONDITIONAL(TARGETRULESET_UCLIBC,test "$enable_uclibc" = "yes")

if test "$target_alias" = "" ; then
	if test "$enable_uclibc" = "yes"; then
		target_alias="powerpc-tuxbox-linux-uclibc"
	else
		target_alias="powerpc-tuxbox-linux-gnu"
	fi
fi

AC_CANONICAL_TARGET
AC_SUBST(target)

# automake1.10 comes with verbose warning output, but we don't want them
AM_INIT_AUTOMAKE([-Wno-portability])
AM_MAINTAINER_MODE

AC_PROG_CC

TUXBOX_BOXTYPE

AC_ARG_ENABLE(nptl,
	AS_HELP_STRING(--disable-nptl,do not use native posix threads for glibc (only meaningful for kernel 2.6.x, default for 2.4.x)),
	,[
		if test "$enable_kernel26" = "yes"; then 
			enable_nptl=yes
		else
			enable_nptl=no
		fi
	])
if test "$enable_nptl" = "yes"; then
	if test "$enable_kernel26" != "yes"; then
		AC_MSG_ERROR([Option --enable-nptl (native posix threads) is only supported for a 2.6.x kernel])
	fi
	GLIBC_PTHREADS="nptl"
else
	GLIBC_PTHREADS="linuxthreads"
fi
AC_SUBST(GLIBC_PTHREADS)

AC_ARG_ENABLE(sqlite,
	AS_HELP_STRING(--enable-sqlite,enable sql storage),
	[case "${enableval}" in
		yes) SQLITE=sqlite ;;
	esac],[enable_sqlite=no])
AM_CONDITIONAL(ENABLE_SQLITE,test "$enable_sqlite" = "yes")
AC_SUBST(SQLITE)

AC_ARG_WITH(targetruleset,
	[  --with-targetruleset=NAME	OBSOLETE, use --[[enable|disable]]-flashrules instead],
	[TARGETRULESET="$withval"],[TARGETRULESET="notset"])

if test "$TARGETRULESET" != "notset"; then
	AC_MSG_WARN([--with-targetruleset is obsolete; use --[[enable|disable]]-flashrules instead]);
fi

AC_ARG_WITH(assume-kernelsources-old,
	[  --with-assume-kernelsources-old	Do not recompile due to new kernel sources],
	[assume_kernelsources_old="yes"],[assume_kernelsources_old="no"])
AM_CONDITIONAL(ASSUME_KERNELSOURCES_OLD,test "$assume_kernelsources_old" = "yes")

AC_ARG_ENABLE(flashrules,
	AS_HELP_STRING(--disable-flashrules,	disable rules for creating flash targets - build cdk instead),
	,[enable_flashrules=yes])
AM_CONDITIONAL(TARGETRULESET_FLASH,test "$enable_flashrules" = "yes")

if test "$enable_flashrules" = "yes"; then
        INSTALLRULESETFILE="-flash"
else
        INSTALLRULESETFILE=""
fi

if test -z "$CFLAGS" ; then
	CFLAGS="-O2"
fi

if test -z "$TARGET_CFLAGS" -o -z "$TARGET_CXXFLAGS"; then
	TARGET_CFLAGS="-pipe"
	if test "$enable_flashrules" != "yes"; then
		TARGET_CFLAGS="$TARGET_CFLAGS -O2 -g3 -gdwarf-2"
		TARGET_LDFLAGS=""
	else
		case "${BOXTYPE}" in
			dreambox)
				TARGET_CFLAGS="$TARGET_CFLAGS -Os -mcpu=$CPU_MODEL -msoft-float -mmultiple -mstring -meabi -ggdb3"
				TARGET_LDFLAGS=""
				;;
			*)
				TARGET_CFLAGS="$TARGET_CFLAGS -Os"
				TARGET_LDFLAGS="-Wl,-O1"
				;;
		esac
	fi
	if test "$TOOLCHAIN_PATH" != "notset"; then
		TARGET_LDFLAGS="$TARGET_LDFLAGS -L\$(targetprefix)/lib"
		TARGET_CFLAGS="$TARGET_CFLAGS -I\$(targetprefix)/include -mcpu=$CPU_MODEL -msoft-float"
	fi
	TARGET_CXXFLAGS="$TARGET_CFLAGS"
fi

if test "$enable_uclibc" = "yes"; then
	CFLAGS="$CFLAGS -fPIC"
	TARGET_CFLAGS="$TARGET_CFLAGS -fPIC"
	TARGET_CXXFLAGS="$TARGET_CXXFLAGS -fPIC"
	LIBGETTEXT=libgettext
fi
AC_SUBST(LIBGETTEXT)

AC_ARG_ENABLE(lirc,
	AS_HELP_STRING(--enable-lirc,	include lirc in yadds and images),
	[case "${enableval}" in
		yes) LIRC=lirc ;;
	esac], [enable_lirc=no])
AM_CONDITIONAL(ENABLE_LIRC,test "$enable_lirc" = "yes")
AC_SUBST(LIRC)

AC_ARG_ENABLE(cdkVcInfo,
	AS_HELP_STRING(--enable-cdkVcInfo,	include cdkVcInfo in yadds and images),
	[case "${enableval}" in
		yes) CDKVCINFO=cdkVcInfo ;;
	esac],[enable_cdkVcInfo=no])
AM_CONDITIONAL(ENABLE_CDKVCINFO,test "$enable_cdkVcInfo" = "yes")
AC_SUBST(CDKVCINFO)

AC_ARG_ENABLE(german_keymaps,
	AS_HELP_STRING(--enable-german-keymaps,	include loadkey and German keymaps in yadds and images),
	[case "${enableval}" in
		yes) CONSOLE_TOOLS=kbd ;;
	esac],[enable_german_keymaps=no])
AM_CONDITIONAL(ENABLE_GERMAN_KEYMAPS,test "$enable_german_keymaps" = "yes")
AC_SUBST(CONSOLE_TOOLS)

# we need to use $enable_use_mmc instead of $enable_mmc because
# --disable-mmc would be ignored thanks to autoconf
AC_ARG_ENABLE(ide,
	AS_HELP_STRING(--enable-ide,	include ide/mmc and ext2/ext3 drivers in yadds and images),
	[case "${enableval}" in
		yes) enable_use_mmc=yes; DEFAULT_FS_FSTAB="ext3" ;;
		no)  enable_use_mmc=no ;;
	esac],[enable_ide=no; enable_use_mmc=no])

AC_ARG_ENABLE(ext3,
	AS_HELP_STRING(--disable-ext3,	exclude ext2/ext3 drivers in yadds and images),
	[case "${enableval}" in
		yes) enable_ext2=yes
		     enable_ext3=yes ;;
		no)  enable_ext2=no
		     DEFAULT_FS_FSTAB="" ;;
	esac],[if test "$enable_ide" = "yes"; then
		    enable_ext2=yes
		    enable_ext3=yes
		else
		    enable_ext2=no
		    enable_ext3=no
		fi])

AC_ARG_ENABLE(xfs,
	AS_HELP_STRING(--enable-xfs,	include xfs drivers in yadds and images),
	[case "${enableval}" in
		yes) XFSPROGS=xfsprogs;
		     [[ "$DEFAULT_FS_FSTAB" = "" ] && DEFAULT_FS_FSTAB="xfs" || /bin/true ] ;;
	esac],[enable_xfs=no])
AC_SUBST(XFSPROGS)

AC_ARG_ENABLE(mmc,
	AS_HELP_STRING(--enable-mmc,	include mmc drivers in yadds and images - you need to activate a filesystem),
	[case "${enableval}" in
		yes)	enable_use_mmc=yes ;;
		no)	enable_use_mmc=no ;;
	esac],[])

# transfer current defaults to new configuration data
enable_fs_nfs=yes
enable_fs_cifs=yes
enable_fs_smbfs=no
enable_fs_lufs=yes
enable_vfat=no
enable_reiserfs=no

AC_ARG_WITH(filesystems,[  --with-filesystems      comma seperated list of filesystems to be used,
                          first disk filesystem will be used as default for /hdd entry in /etc/fstab
                          allowed values: nfs (always enabled in yadd), cifs, smbfs,
                                          lufs (ftpfs), xfs (not kernel2.4/uClibc),
                                          ext2, ext3, extfs (ext2/3), vfat, reiserfs],[
if test x"${withval+set}" = xset; then
    enable_filesystems=`echo "${withval}" | sed -e 's/[[ 	,]][[ 	,]]*/,/g' -e 's/,$//' -e 's/,/ /g'`
    enable_fs_nfs=no
    enable_fs_cifs=no
    enable_fs_lufs=no
    enable_ext2=no
    enable_ext3=no
    enable_xfs=no
    enable_vfat=no
    enable_reiserfs=no
    DEFAULT_FS_FSTAB=""
    for i in $enable_filesystems; do
	case $i in
	    nfs)		enable_fs_nfs=yes ;;
	    cifs)		enable_fs_cifs=yes ;;
	    smbfs)		enable_fs_smbfs=yes ;;
	    lufs|ftpfs)		enable_fs_lufs=yes ;;
	    vfat)		enable_vfat=yes
#				activate IDE support if MMC is not enabled
				[[ "$enable_use_mmc" != "yes" ] && enable_ide=yes ]
				[[ "$DEFAULT_FS_FSTAB" = "" ] && DEFAULT_FS_FSTAB="vfat" || /bin/true ] ;;
	    xfs)		enable_xfs=yes
				[[ "$enable_use_mmc" != "yes" ] && enable_ide=yes ]
				[[ "$DEFAULT_FS_FSTAB" = "" ] && DEFAULT_FS_FSTAB="xfs" || /bin/true ] ;;
	    reiserfs)		enable_reiserfs=yes
				[[ "$enable_use_mmc" != "yes" ] && enable_ide=yes ]
				[[ "$DEFAULT_FS_FSTAB" = "" ] && DEFAULT_FS_FSTAB="reiserfs" || /bin/true ] ;;
	    extfs)		enable_ext2=yes; enable_ext3=yes
				[[ "$enable_use_mmc" != "yes" ] && enable_ide=yes ]
				[[ "$DEFAULT_FS_FSTAB" = "" ] && DEFAULT_FS_FSTAB="ext3" || /bin/true ] ;;
	    ext3)		enable_ext3=yes
				[[ "$enable_use_mmc" != "yes" ] && enable_ide=yes ]
				[[ "$DEFAULT_FS_FSTAB" = "" ] && DEFAULT_FS_FSTAB="ext3" || /bin/true ] ;;
	    ext2)		enable_ext2=yes
				[[ "$enable_use_mmc" != "yes" ] && enable_ide=yes ]
				[[ "$DEFAULT_FS_FSTAB" = "" ] && DEFAULT_FS_FSTAB="ext2" || /bin/true ] ;;
	    *)			AC_MSG_ERROR([bad value $i for --with-filesystems]) ;;
	esac
    done
fi],[])

# now we need to test some constellations which are not possible,
# i.e. IDE or MMC support without disc filesystems
if test "$enable_ide" = "no" -a "$enable_mmc" = "no"; then
	enable_ext2=no
	enable_ext3=no
	enable_xfs=no
	enable_reiserfs=no
fi

# we need to check vfat support seperately because it
# can be used either with HDD or MMC
if test "$enable_use_mmc" != "yes" -a "$enable_ide" != "yes" -a "$enable_vfat" = "yes"; then
	enable_vfat=no
fi

# if no disc filesystem is activated, deactivate IDE and MMC support
if ! test "$enable_ext2" = "yes" -o "$enable_ext3" = "yes" -o "$enable_xfs" = "yes" -o "$enable_reiserfs" = "yes" -o "$enable_vfat" = "yes"; then
	DEFAULT_FS_FSTAB=""
	enable_ide=no
	enable_use_mmc=no
	enable_ext2=no
	enable_ext3=no
	enable_xfs=no
	enable_reiserfs=no
	enable_vfat=no
	disable_hdd_fs=yes
else
	disable_hdd_fs=no
fi

AM_CONDITIONAL(ENABLE_FS_CIFS,test "$enable_fs_cifs" = "yes")
AM_CONDITIONAL(ENABLE_FS_SMBFS,test "$enable_fs_smbfs" = "yes")
if test "$enable_fs_smbfs" = "yes"; then
	SMBMOUNT=smbmount
fi
AC_SUBST(SMBMOUNT)

AM_CONDITIONAL(ENABLE_FS_LUFS,test "$enable_fs_lufs" = "yes")
if test "$enable_fs_lufs" = "yes"; then
	LUFS=lufs
fi
AC_SUBST(LUFS)

AM_CONDITIONAL(ENABLE_VFAT,test "$enable_vfat" = "yes")
AM_CONDITIONAL(ENABLE_IDE,test "$enable_ide" = "yes")
AM_CONDITIONAL(ENABLE_MMC,test "$enable_use_mmc" = "yes")
AM_CONDITIONAL(ENABLE_EXT2,test "$enable_ext2" = "yes")
AM_CONDITIONAL(ENABLE_EXT3,test "$enable_ext3" = "yes")
AM_CONDITIONAL(ENABLE_XFS,test "$enable_xfs" = "yes")
AM_CONDITIONAL(ENABLE_REISERFS,test "$enable_reiserfs" = "yes")
if test "$enable_reiserfs" = "yes"; then
	REISERFSPROGS=reiserfsprogs
	ENIGMA_REISERFS=yes
else
	ENIGMA_REISERFS=no
fi
AC_SUBST(REISERFSPROGS)
AC_SUBST(ENIGMA_REISERFS)

AC_SUBST(DEFAULT_FS_FSTAB)

if test "$enable_uclibc" = "yes" -a "$enable_xfs" = "yes" -a "$enable_kernel26" != "yes"; then
	echo
	echo "******************************************************************************"
	echo "***** XFS does not work with uClibc/kernel 2.4 yet - use \"--disable-xfs\" *****"
	echo "******************************************************************************"
	echo
	exit 1
fi

AC_ARG_ENABLE(nfsserver,
	AS_HELP_STRING(--enable-nfsserver,	enable the dBox NFS server),
	[case "${enableval}" in
		yes) NFSSERVER=nfsserver; enable_fs_nfs=yes ;;
	esac],[enable_nfsserver=no])
AM_CONDITIONAL(ENABLE_NFSSERVER,test "$enable_nfsserver" = "yes")
AM_CONDITIONAL(ENABLE_FS_NFS,test "$enable_fs_nfs" = "yes")
AC_SUBST(NFSSERVER)

# mark if no network filesystem is activated
# please note that NFS is always activated for yadd images, but
# a deactivated automounter will not be reactivated for yadd
if ! test "$enable_fs_cifs" = "yes" -o "$enable_fs_smbfs" = "yes" -o "$enable_fs_lufs" = "yes" -o "$enable_fs_nfs" = "yes"; then
	disable_net_fs=yes
else
	disable_net_fs=no
fi

AC_ARG_ENABLE(automount,
	AS_HELP_STRING(--enable-automount,	enable automount daemon),
	[case "${enableval}" in
		yes) enable_automount=yes ;;
		no) enable_automount=no ;;
	esac],[enable_automount=yes])

# if no filesystem is active, deactivate automounter
if test "$disable_net_fs" = "yes" -a "$disable_hdd_fs" = "yes"; then
	enable_automount=no
fi

if test "$enable_automount" = "yes"; then
	AUTOMOUNT=automount
fi
AC_SUBST(AUTOMOUNT)
AM_CONDITIONAL(ENABLE_AUTOMOUNT,test "$enable_automount" = "yes")

AC_ARG_ENABLE(sambaserver,
	AS_HELP_STRING(--enable-sambaserver,    enable the dBox samba server),
	[case "${enableval}" in
		yes) SAMBASERVER=sambaserver ;;
	esac],[enable_sambaserver=no])
AM_CONDITIONAL(ENABLE_SAMBASERVER,test "$enable_sambaserver" = "yes")
AC_SUBST(SAMBASERVER)

AC_ARG_ENABLE(dosfstools,
	AS_HELP_STRING(--enable-dosfstools,    enable the dosfstools),
	[case "${enableval}" in
		yes) DOSFSTOOLS=dosfstools ;;
	esac],[enable_dosfstools=no])
AM_CONDITIONAL(ENABLE_DOSFSTOOLS,test "$enable_dosfstools" = "yes")
AC_SUBST(DOSFSTOOLS)

AC_ARG_ENABLE(upnp,
	AS_HELP_STRING(--enable-upnp,include upnp support),
	,[enable_upnp=no])
AM_CONDITIONAL(ENABLE_UPNP,test "$enable_upnp" = "yes")

AC_ARG_ENABLE(flac,
	AS_HELP_STRING(--enable-flac,include Neutrino flac audio decoder with libFLAC),
	[case "${enableval}" in
		yes) FLACLIB=libFLAC ;;
	esac],[enable_flac=no])
AM_CONDITIONAL(ENABLE_FLAC,test "$enable_flac" = "yes")
AC_SUBST(FLACLIB)

AC_ARG_ENABLE(esd,
	AS_HELP_STRING(--enable-esd,include esd sound daemon),
	,[enable_esd=no])
AM_CONDITIONAL(ENABLE_ESD,test "$enable_esd" = "yes")

if test "$enable_uclibc" = "yes" && test "$enable_flac" = "yes" && test "$enable_flashrules" = "yes"; then
	echo
	echo "*********************************************************************"
	echo "***** FLAC does not work with uClibc yet - use \"--disable-flac\" *****"
	echo "*********************************************************************"
	echo
	exit 1
fi

AC_ARG_WITH(rootpartitionsize,
	[  --with-rootpartitionsize=SIZE	size of the root partition],
	[ROOT_PARTITION_SIZE="$withval"],[ROOT_PARTITION_SIZE="0x660000"])
AC_SUBST(ROOT_PARTITION_SIZE)

AC_ARG_WITH(flashfstype,
	[  --with-flashfstype=FS_TYPE	type of flash root filesystem partition for the yadd kernel (squashfs+lzma/squashfs)],
	[FLASH_FS_TYPE="$withval"],[FLASH_FS_TYPE="squashfs+lzma"])
AC_SUBST(FLASH_FS_TYPE)

AC_ARG_WITH(defaultlocale,
	[  --with-defaultlocale=LOCALE	default locale],
	[DEFAULTLOCALE="$withval"],[DEFAULTLOCALE="deutsch"])
AC_SUBST(DEFAULTLOCALE)

AC_SUBST(CFLAGS)
AC_SUBST(TARGET_CFLAGS)
AC_SUBST(TARGET_CXXFLAGS)
AC_SUBST(TARGET_LDFLAGS)

AC_PREFIX_DEFAULT(/dbox2)

if test "$prefix" = "NONE"; then
	prefix=/dbox2
fi

AC_ARG_WITH(targetprefix,
	[  --with-targetprefix=DIR prefix for target files [[PREFIX/cdkroot]]],
	[targetprefix="$with_targetprefix"],[targetprefix="${prefix}/cdkroot"])

AC_ARG_WITH(hostprefix,
	[  --with-hostprefix=DIR   prefix for host files [[PREFIX/cdk]]],
	[hostprefix="$with_hostprefix"],[hostprefix="${prefix}/cdk"])

AC_ARG_WITH(bootprefix,
	[  --with-bootprefix=DIR   prefix for boot files [[PREFIX/tftpboot]]],
	[bootprefix="$with_bootprefix"],[bootprefix="${prefix}/tftpboot"])

AC_ARG_WITH(flashprefix,
	[  --with-flashprefix=DIR  prefix for flash files [[PREFIX/cdkflash]] (only used for flash building)],
	[flashprefix="$with_flashprefix"],[flashprefix="${prefix}/cdkflash"])

AC_ARG_WITH(serversupport,
	[  --with-serversupport=DIR  prefix for server file templates [[PREFIX/serversupport]]],
	[serversupport="$with_serversupport"],[serversupport="${prefix}/serversupport"])

AC_ARG_WITH(ucodesdir,
	[  --with-ucodesdir=DIR  optional directory containing ucodes (dbox2 only) [[NONE]]],
	[ucodesdir="$with_ucodesdir"],[ucodesdir="NONE"])

if test "$BOXTYPE" != "dbox2"; then
	ucodesdir="NONE"
fi

AC_ARG_WITH(logosdir,
	[  --with-logosdir=DIR  optional directory containing logos [[[CVS/]logos]]],
	[logosdir="$with_logosdir"],[logosdir="`pwd`/logos"])

AC_ARG_WITH(customizationsdir,
	[  --with-customizationsdir=DIR  optional directory containing customization scripts [[[CVS]]]],
	[customizationsdir="$with_customizationsdir"],[customizationsdir="`pwd`"])

AC_ARG_WITH(updatehttpprefix,
	[  --with-updatehttpprefix=URL  optional URL containing the URL of a directory with update images
                               "disable" completely disables internet update code [[NONE]]],
	[updatehttpprefix="$with_updatehttpprefix"],[updatehttpprefix=])

AC_ARG_WITH(busybox_conf,
	[  --with-busybox-conf=M4_FILE personalized optional m4 busybox configuration file [[config/busybox.config.m4]]],
	[busybox_conf="$with_busybox_conf"],[busybox_conf="config/busybox.config.m4"])
AC_SUBST(busybox_conf)

AC_ARG_WITH(yadd_kernel_conf,
	[  --with-yadd-kernel-conf=FILE optional personalized linux kernel config file for nfs rootfs [[Patches/linux-KERNEL_VERSION-dbox2.config]]],
	[yadd_kernel_conf="$with_yadd_kernel_conf"],[yadd_kernel_conf="NONE"])
AC_SUBST(yadd_kernel_conf)

AC_ARG_WITH(flash_kernel_conf,
	[  --with-flash-kernel-conf=FILE optional personalized linux kernel config file for flash rootfs [[Patches/linux-KERNEL_VERSION-dbox2.config-flash]]],
	[flash_kernel_conf="$with_flash_kernel_conf"],[flash_kernel_conf="NONE"])
AC_SUBST(flash_kernel_conf)

buildprefix=`pwd`
AC_SUBST(targetprefix)
AC_SUBST(hostprefix)
AC_SUBST(buildprefix)
AC_SUBST(bootprefix)
AC_SUBST(flashprefix)
AC_SUBST(serversupport)
AC_SUBST(ucodesdir)
AC_SUBST(logosdir)
AC_SUBST(customizationsdir)
AC_SUBST(updatehttpprefix)
AM_CONDITIONAL(DISABLE_UPDATE_HTTP,test "$updatehttpprefix" = "disable")
flashprefix_ro=${flashprefix}/ro
AC_SUBST(flashprefix_ro)
flashprefix_rw=${flashprefix}/rw
AC_SUBST(flashprefix_rw)

AC_ARG_WITH(checkImage,
	[  --with-checkImage=[[none,rename,warn]]	How/if to invoke checkImage [[none]]],
	[CHECKIMAGE_BEHAVIOR="$withval"],[CHECKIMAGE_BEHAVIOR="true"])
if [[ "$withval" = "rename" ]] ; then
	TUXBOX_CHECKIMAGE='$(hostprefix)/bin/checkImage $@ || mv $@ $@_bad'
elif [[ "$withval" = "warn" ]] ; then
	TUXBOX_CHECKIMAGE='rm -f $@_bad; $(hostprefix)/bin/checkImage $@ || touch $@_bad'
else
	TUXBOX_CHECKIMAGE=@true
fi
AC_SUBST(TUXBOX_CHECKIMAGE)

AC_ARG_WITH(cvsdir,
	[  --with-cvsdir=DIR       where to find the cvs],
	[cvsdir="$with_cvsdir"],[cvsdir="NONE"])

AC_ARG_WITH(appsdir,
	[  --with-appsdir=DIR      apps dir from cvs [[[CVS/]apps/]]],
	[appsdir="$with_appsdir"],[appsdir="NONE"])

AC_ARG_WITH(bootdir,
	[  --with-bootdir=DIR      boot dir from cvs [[[CVS/]boot/]]],
	[bootdir="$with_bootdir"],[bootdir="NONE"])

AC_ARG_WITH(driverdir,
	[  --with-driverdir=DIR    driver dir from cvs [[[CVS/]driver]]],
	[driverdir="$with_driverdir"],[driverdir="NONE"])

AC_ARG_WITH(hostappsdir,
	[  --with-hostappsdir=DIR  hostapps dir from cvs [[[CVS/]hostapps]]],
	[hostappsdir="$with_hostappsdir"],[hostappsdir="NONE"])

AC_ARG_WITH(gnuserver,
        [  --with-gnuserver=ADDRESS   the gnu server for gnu-stuff (without ftp://)],
        [gnuserver="$with_gnuserver"],[gnuserver=ftp.gwdg.de/pub/misc/gnu/ftp/gnu])

AC_ARG_WITH(defaultserver,
        [  --with-defaultserver=ADDRESS   the server that is taken if no server is given/works (without http://)],
        [defaultserver="$with_defaultserver"],[defaultserver=www.dbox2-tuning.net/cvsdata/files])

if test "$cvsdir" = "NONE"; then
	if test "$appsdir" = "NONE"; then
		appsdir="$buildprefix/apps"
	fi
	if test "$bootdir" = "NONE"; then
		bootdir="$buildprefix/boot"
	fi
	if test "$driverdir" = "NONE"; then
		driverdir="$buildprefix/driver"
	fi
	if test "$hostappsdir" = "NONE"; then
		hostappsdir="$buildprefix/hostapps"
	fi
else
	if test "$appsdir" = "NONE"; then
		appsdir="$cvsdir/apps"
	fi
	if test "$bootdir" = "NONE"; then
		bootdir="$cvsdir/boot"
	fi
	if test "$driverdir" = "NONE"; then
		driverdir="$cvsdir/driver"
	fi
	if test "$hostappsdir" = "NONE"; then
		hostappsdir="$cvsdir/hostapps"
	fi
fi

case "${BOXTYPE}" in
	dreambox)
		startscriptdir="$cvsdir/cdk/root_dream"
		;;
	*)
		startscriptdir="$cvsdir/cdk/root"
		;;
esac

dircheck="ok"
AC_MSG_CHECKING([for apps directory])
if test ! -f "$appsdir/dvb/zapit/configure.ac" ; then
	AC_MSG_WARN([appsdir $appsdir not found])
	appsdir="missing"
	dircheck="fail"
else
	AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for boot directory])
if test ! -d "$bootdir/u-boot-tuxbox" ; then
	AC_MSG_WARN([bootdir $bootdir not found])
	bootdir="missing"
	dircheck="fail"
else
	AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for driver directory])
if test ! -f "$driverdir/Makefile" ; then
	AC_MSG_WARN([driverdir $driverdir not found])
	driverdir="missing"
	dircheck="fail"
else
	AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for hostapps directory])
if test ! -f "$hostappsdir/configure.ac" ; then
	AC_MSG_WARN([hostappsdir $hostappsdir not found])
	hostappsdir="missing"
	dircheck="fail"
else
	AC_MSG_RESULT([yes])
fi

AC_SUBST(appsdir)
AC_SUBST(bootdir)
AC_SUBST(driverdir)
AC_SUBST(hostappsdir)
AC_SUBST(startscriptdir)
AC_SUBST(gnuserver)
AC_SUBST(defaultserver)

AC_PATH_PROG(M4,m4,no)
if test "$M4" = "no"; then
	AC_MSG_WARN(No m4 found)
fi

AC_PROG_CXX
if test "$CXX" = "g++" -a "$GXX" != "yes"; then
	AC_MSG_ERROR(No g++ found)
fi

AC_PROG_LEX
if test "$LEX" != "flex"; then
	AC_MSG_ERROR(No flex found)
fi

AC_PROG_YACC
if test "$YACC" != "bison -y"; then
	AC_MSG_ERROR(No bison found)
fi

if test "$enable_flashrules" = "yes"; then
	if test "$enable_uclibc" = "yes"; then
		MKLIBS="$hostappsdir/mklibs/mklibs_uclibc.py"
	else
		MKLIBS="$hostappsdir/mklibs/mklibs.py"
	fi
	[[ -x "$MKLIBS" ] && true || chmod +x "$MKLIBS" ]
	AC_SUBST(MKLIBS)

	AC_PATH_PROG(MKCRAMFS,mkcramfs,no)
	if test "$MKCRAMFS" = "no"; then
		AC_MSG_WARN(using tuxbox cramfs)
		MKCRAMFS=$hostprefix/bin/mkcramfs
	fi
fi


################################################################
# ccache
#
AC_ARG_ENABLE(ccache,
   AS_HELP_STRING(--enable-ccache,   enable ccache supported compiling ),
   [case "${enableval}" in
      yes) CCACHE=ccache ;;
   esac],[enable_ccache=no])
AM_CONDITIONAL(ENABLE_CCACHE,test "$enable_ccache" = "yes")
AC_SUBST(CCACHE)


hostccachedir=$(dirname `which ccache`)
if  [[ -e $hostccachedir/ccache ]]; then
	ccachedir=$hostccachedir
	AM_CONDITIONAL(USE_CCACHEHOST, true)
else
	ccachedir=$hostprefix/bin
	AM_CONDITIONAL(USE_CCACHEHOST, false)
fi
AC_SUBST(ccachedir)

# optional ccache settings
AC_ARG_WITH(maxcachesize,
	[  --with-maxcachesize=SIZE maximal ccachesize for ccache ],
	[maxcachesize="$with_maxcachesize"],[maxcachesize="-1"])
AC_SUBST(maxcachesize)

AC_ARG_WITH(maxcachefiles,
	[  --with-maxcachefiles=COUNT maximal count of cachefiles for ccache ],
	[maxcachefiles="$with_maxcachefiles"],[maxcachefiles="-1"])
AC_SUBST(maxcachefiles)

if test "$enable_ccache" = "yes"; then
	if  [[ -e $ccachedir/ccache ]]; then
		if test $maxcachesize != -1; then
			$ccachedir/ccache -M $maxcachesize
		fi
		if test $maxcachefiles != -1; then
			$ccachedir/ccache -F $maxcachefiles
		fi
		ccacheinfo="
----------------------------------------
ccache installdir:			$ccachedir
$($ccachedir/ccache -s)
----------------------------------------"
	else
		ccacheinfo="
----------------------------------------
ccache installdir:		$ccachedir
ccache is not yet installed, but installation starts on first build of cdk environment or you can run make ccache
----------------------------------------"
	fi
fi
# UK FreeSat EPG #########################
AC_ARG_ENABLE(freesatepg,
	AS_HELP_STRING(--enable-freesatepg,enable UK FreeSat EPG),
	,[enable_freesatepg=no])
AM_CONDITIONAL(ENABLE_FREESATEPG,test "$enable_freesatepg" = "yes")
#
################################################################

# neutrino movieplayer2 (experimental) #########################
AC_ARG_ENABLE(movieplayer2,
	AS_HELP_STRING(--enable-movieplayer2,enable experimental neutrino movieplayer2),
	,[enable_movieplayer2=no])
AM_CONDITIONAL(ENABLE_MOVIEPLAYER2,test "$enable_movieplayer2" = "yes")

################################################################

# enigma specific stuff #########################
AC_ARG_WITH(webif,
	[  --with-webif=NAME dreambox webif [[standard,expert]]],
	[WEBIF="$withval"],[WEBIF="standard"])

AC_SUBST(WEBIF)
AM_CONDITIONAL(WEBIF_STANDARD,test "$WEBIF" = "standard")
AM_CONDITIONAL(WEBIF_EXPERT,test "$WEBIF" = "expert")

AC_ARG_WITH(epg,
	[  --with-epg=NAME dreambox epg [[standard,private]]],
	[EPG="$withval"],[EPG="standard"])

AC_SUBST(EPG)
AM_CONDITIONAL(EPG_STANDARD,test "$EPG" = "standard")
AM_CONDITIONAL(EPG_PRIVATE,test "$EPG" = "private")

AC_ARG_WITH(mhw-epg,
	[  --with-mhw-epg          enable capture of mhw epg (default off)],
	[MHW_EPG="$withval"],[MHW_EPG="no"])

AC_SUBST(MHW_EPG)
AM_CONDITIONAL(MHW_EPG_NO,test "$MHW_EPG" = "no")
AM_CONDITIONAL(MHW_EPG_YES,test "$MHW_EPG" = "yes")

AC_ARG_WITH(flashtool,
	[  --with-flashtool=NAME dreambox flashtool [[standard,expert]]],
	[FLASHTOOL="$withval"],[FLASHTOOL="standard"])

AC_SUBST(FLASHTOOL)
AM_CONDITIONAL(FLASHTOOL_STANDARD,test "$FLASHTOOL" = "standard")
AM_CONDITIONAL(FLASHTOOL_EXPERT,test "$FLASHTOOL" = "expert")

AC_ARG_WITH(ext-flashtool,
	[  --with-ext-flashtool=NAME dreambox ext-flashtool [[yes,no]]],
	[EXTFLASHTOOL="$withval"],[EXTFLASHTOOL="yes"])

AC_ARG_WITH(enigma-debug,
	[  --with-enigma-debug=NAME dreambox enigma-debug [[yes,no]]],
	[ENIGMA_DEBUG="$withval"],[ENIGMA_DEBUG="yes"])

AC_SUBST(ENIGMA_DEBUG)
AM_CONDITIONAL(ENIGMA_DEBUG_NO,test "$ENIGMA_DEBUG" = "no")
AM_CONDITIONAL(ENIGMA_DEBUG_YES,test "$ENIGMA_DEBUG" = "yes")

#
################################################################

FONTDIR="/share/fonts"
AC_SUBST(FONTDIR)
UCODEDIR="/var/tuxbox/ucodes"
AC_SUBST(UCODEDIR)

CLEANUP="rm -rf"
AC_SUBST(CLEANUP)

DEPSCLEANUP="rm -f"
AC_SUBST(DEPSCLEANUP)

#
# core
#

case "${BOXTYPE}" in
	dreambox)
		TUXBOX_RULES_MAKE(linux_dream)
		TUXBOX_RULES_MAKE(linux_dream_kernel_headers)
		TUXBOX_RULES_MAKE(dreamfiles)
		TUXBOX_RULES_MAKE(dreamdriver_dm7000)
		TUXBOX_RULES_MAKE(dreamdriver_dm56x0)
		TUXBOX_RULES_MAKE(dreamdriver_dm500)
		;;
	ipbox)
		TUXBOX_RULES_MAKE(linux_ipbox)
		TUXBOX_RULES_MAKE(linux_ipbox_kernel_headers)
		TUXBOX_RULES_MAKE(dgstationdriver_cubecafe)
		TUXBOX_RULES_MAKE(dgstationdriver_mutant200s)
		TUXBOX_RULES_MAKE(dgstationdriver_prime)
		TUXBOX_RULES_MAKE(dgstationdriver_relook400s)
		;;
	*)
		TUXBOX_RULES_MAKE(linux)
		TUXBOX_RULES_MAKE(linux24)
		;;
esac

TUXBOX_RULES_MAKE(uboot)
TUXBOX_RULES_MAKE_EXDIR(binutils)
TUXBOX_RULES_MAKE_EXDIR(bootstrap_gcc)
TUXBOX_RULES_MAKE_EXDIR(glibc)
TUXBOX_RULES_MAKE_EXDIR(gcc)
TUXBOX_RULES_MAKE(uclibc)

#
# root
#
TUXBOX_RULES_MAKE(busybox)
TUXBOX_RULES_MAKE(automount)
TUXBOX_RULES_MAKE(nfs_utils)
TUXBOX_RULES_MAKE(fuse)
if test "$enable_kernel26" != "yes"; then
TUXBOX_RULES_MAKE(fusekernel)
fi
TUXBOX_RULES_MAKE(djmount)
TUXBOX_RULES_MAKE(ftpd)
TUXBOX_RULES_MAKE(module_init_tools)
TUXBOX_RULES_MAKE(modutils)
TUXBOX_RULES_MAKE(netkit_telnet)
TUXBOX_RULES_MAKE(portmap)
TUXBOX_RULES_MAKE(procps)
TUXBOX_RULES_MAKE(udev)
TUXBOX_RULES_MAKE(watchdog)
TUXBOX_RULES_MAKE(mrouted)
TUXBOX_RULES_MAKE(samba)
TUXBOX_RULES_MAKE(cramfs)
TUXBOX_RULES_MAKE(squashfs)
#
# contrib libs
#
TUXBOX_RULES_MAKE(libboost)
TUXBOX_RULES_MAKE(libcommoncplusplus)
TUXBOX_RULES_MAKE(libcrypto)
TUXBOX_RULES_MAKE(libcurl)
TUXBOX_RULES_MAKE(libdirectfb)
TUXBOX_RULES_MAKE(libdirectfbpp)
TUXBOX_RULES_MAKE(libppdirectfb)
TUXBOX_RULES_MAKE(libdvb)
TUXBOX_RULES_MAKE(libdvbpsi)
TUXBOX_RULES_MAKE(libexpat)
TUXBOX_RULES_MAKE(libffi)
TUXBOX_RULES_MAKE(libfreetype)
TUXBOX_RULES_MAKE(libfribidi)
TUXBOX_RULES_MAKE(libid3tag)
TUXBOX_RULES_MAKE(libgmp)
TUXBOX_RULES_MAKE(libmad)
TUXBOX_RULES_MAKE(libncurses)
TUXBOX_RULES_MAKE(libjpeg)
TUXBOX_RULES_MAKE(libungif)
TUXBOX_RULES_MAKE(libpcap)
TUXBOX_RULES_MAKE(libpng)
TUXBOX_RULES_MAKE(libreadline)
TUXBOX_RULES_MAKE(libsdl)
TUXBOX_RULES_MAKE(libsigc)
TUXBOX_RULES_MAKE(libvorbisidec)
TUXBOX_RULES_MAKE(libxml2)
TUXBOX_RULES_MAKE(libz)
TUXBOX_RULES_MAKE(libglib)
TUXBOX_RULES_MAKE(libiconv)
TUXBOX_RULES_MAKE(libtool)
TUXBOX_RULES_MAKE(libFLAC)
TUXBOX_RULES_MAKE(libgettext)
TUXBOX_RULES_MAKE(liblzma465)

#
# contrib apps
#
TUXBOX_RULES_MAKE(bzip2)
TUXBOX_RULES_MAKE(console_data)
TUXBOX_RULES_MAKE(console_tools)
TUXBOX_RULES_MAKE(kbd)
TUXBOX_RULES_MAKE(directfb_examples)
TUXBOX_RULES_MAKE(fbset)
TUXBOX_RULES_MAKE(lirc)
TUXBOX_RULES_MAKE(lsof)
TUXBOX_RULES_MAKE(ssh)
TUXBOX_RULES_MAKE(tcpdump)
TUXBOX_RULES_MAKE(bonnie)
TUXBOX_RULES_MAKE(vdr)
TUXBOX_RULES_MAKE(lufs)
TUXBOX_RULES_MAKE(dropbear)
TUXBOX_RULES_MAKE(kermit)
TUXBOX_RULES_MAKE(wget)
TUXBOX_RULES_MAKE(ncftp)
TUXBOX_RULES_MAKE(screen)
TUXBOX_RULES_MAKE(links)
TUXBOX_RULES_MAKE(links_g)
TUXBOX_RULES_MAKE(ntpd)
TUXBOX_RULES_MAKE(ntpclient)
TUXBOX_RULES_MAKE(openntpd)
TUXBOX_RULES_MAKE(esound)
TUXBOX_RULES_MAKE(python)
TUXBOX_RULES_MAKE(ser2net)
TUXBOX_RULES_MAKE(ucl)
TUXBOX_RULES_MAKE(upx_host)
TUXBOX_RULES_MAKE(lzma)
TUXBOX_RULES_MAKE(lzma_host)

#
# ide apps
#
TUXBOX_RULES_MAKE(hdparm)
TUXBOX_RULES_MAKE(e2fsprogs)
TUXBOX_RULES_MAKE(utillinux)
TUXBOX_RULES_MAKE(parted)
TUXBOX_RULES_MAKE(hddtemp)
TUXBOX_RULES_MAKE(xfsprogs)
TUXBOX_RULES_MAKE(reiserfsprogs)
TUXBOX_RULES_MAKE(smartmontools)
TUXBOX_RULES_MAKE(dosfstools)

#
# ccache
#
TUXBOX_RULES_MAKE(ccache)

#
# msttf
#
TUXBOX_RULES_MAKE(cabextract)
TUXBOX_RULES_MAKE(msttf)

#
# additional
#
TUXBOX_RULES_MAKE(gdb)
TUXBOX_RULES_MAKE(insight)
TUXBOX_RULES_MAKE(ltrace)
TUXBOX_RULES_MAKE(strace)
TUXBOX_RULES_MAKE(nano)
TUXBOX_RULES_MAKE(mc)
TUXBOX_RULES_MAKE(joe)
TUXBOX_RULES_MAKE(bash)

#
# java
#
TUXBOX_RULES_MAKE(kaffe)
TUXBOX_RULES_MAKE(kaffeh)

#
# fun stuff
#
TUXBOX_RULES_MAKE(gnuboy)
TUXBOX_RULES_MAKE(scummvm)
TUXBOX_RULES_MAKE(sdldoom)
TUXBOX_RULES_MAKE(tinygl)

#
# dvb apps
#
TUXBOX_RULES_MAKE(dvbdate)
TUXBOX_RULES_MAKE(dvbstream)
TUXBOX_RULES_MAKE(dvbtext)
TUXBOX_RULES_MAKE(dvbtune)
TUXBOX_RULES_MAKE(vls)

#
# bluetooth
#
TUXBOX_RULES_MAKE(bluez_hcidump)
TUXBOX_RULES_MAKE(bluez_libs)
TUXBOX_RULES_MAKE(bluez_pan)
TUXBOX_RULES_MAKE(bluez_sdp)
TUXBOX_RULES_MAKE(bluez_utils)

#
# Database
#
TUXBOX_RULES_MAKE(sqlite)

#
# internal
#
AC_SUBST_FILE(ARCHIVE)
ARCHIVE=Makefile-archive
AC_CONFIG_COMMANDS_PRE([
AC_MSG_NOTICE([creating Makefile-archive])
${srcdir}/rules-archive.pl ${srcdir}/rules-archive > Makefile-archive
])

#
# customized linux kernel configs
#

case "${BOXTYPE}" in
	ipbox)
		if test "$flash_kernel_conf" = "NONE"; then
			flash_kernel_conf="config/ipbox_kernel-2.6.17.config.m4"
		fi
		yadd_kernel_conf=""
		;;
	*)
		if test "$enable_kernel26" = "yes"; then
			if test "$yadd_kernel_conf" = "NONE"; then
				yadd_kernel_conf="Patches/linux-2.6.26.4-dbox2.config"
			fi
			if test "$flash_kernel_conf" = "NONE"; then
				flash_kernel_conf="Patches/linux-2.6.26.4-dbox2.config-flash"
			fi
		else
			if test "$yadd_kernel_conf" = "NONE"; then
				yadd_kernel_conf="Patches/linux-2.4.35.5-dbox2.config"
			fi
			if test "$flash_kernel_conf" = "NONE"; then
				flash_kernel_conf="Patches/linux-2.4.35.5-dbox2.config-flash"
			fi
		fi
		;;
esac

# hack
AC_ARG_ENABLE(dreambox-serial-console,
	AS_HELP_STRING(--enable-dreambox-serial-console, enable serial console on dream),
	,[enable_dreambox_serial_console=no])
AM_CONDITIONAL(DREAMBOX_ENABLE_SERIAL_CONSOLE,test "$enable_dreambox_serial_console" = "yes")

#
# summary
#

if test "$enable_kernel26" == "yes"; then
	used_kernelversion="2.6"
else
	used_kernelversion="2.4"
fi

if test "$enable_uclibc" == "yes"; then
	used_libc="uclibc"
else
	used_libc="glibc"
fi

AC_MSG_RESULT([
summary:
----------------------------------------
target cpu/boxtype:		$CPU_MODEL/$BOXTYPE $BOXMODEL
kernel:				$used_kernelversion
used yadd kernel config:	$yadd_kernel_conf
used flash kernel config:	$flash_kernel_conf
libc:				$used_libc
threads:			$GLIBC_PTHREADS
target:				$target
host:				$host
flash rules:			$enable_flashrules
target prefix:			$targetprefix
host prefix:			$hostprefix
boot prefix:			$bootprefix
build prefix:			$buildprefix
root partition size:		$ROOT_PARTITION_SIZE
default locale:			$DEFAULTLOCALE
serversupport:			$serversupport
checkImage:			$CHECKIMAGE_BEHAVIOR
target apps directory:		$appsdir
boot directory:			$bootdir
start script directory:		$startscriptdir
driver directory:		$driverdir
host apps directory:		$hostappsdir
logo directory:			$logosdir
customization directory:	$customizationsdir
ucode directory:		$ucodesdir
GNU server:			$gnuserver
default server:			$defaultserver
update http prefix:		$updatehttpprefix
used busybox-m4-config:		$busybox_conf
IDE support:			$enable_ide
MMC support:			$enable_use_mmc
fstab default fs:		$DEFAULT_FS_FSTAB
IDE/MMC: Ext2 support		$enable_ext2
IDE/MMC: Ext3 support		$enable_ext3
IDE/MMC: XFS support		$enable_xfs
IDE/MMC: REISERFS support	$enable_reiserfs
IDE/MMC: VFAT support		$enable_vfat
CIFS kernel module:		$enable_fs_cifs
SMBFS kernel module:		$enable_fs_smbfs
LUFS kernel module:		$enable_fs_lufs
NFS kernel module:		$enable_fs_nfs
NFS server:			$enable_nfsserver
Samba server:			$enable_sambaserver
Automount:			$enable_automount
dosfstools:			$enable_dosfstools
Neutrino UPnP-support:		$enable_upnp
Esound support:			$enable_esd
FLAC support:			$enable_flac
German keymaps:			$enable_german_keymaps
sqlite3 storage:		$enable_sqlite
ccache support:			$enable_ccache
$ccacheinfo
])

if test "$dircheck" = "fail"; then
AC_MSG_RESULT([
******************************************************************
*                       !!!WARNING!!!                            *
* one or more of your CVS source directories could not be found, *
* (for details see above), did you maybe supply an incorrect     *
*  --with-cvsdir argument to configure?                          *
*                       !!!WARNING!!!                            *
******************************************************************
])
fi

TUXBOX_CUSTOMIZE='[[ -x $(customizationsdir)/$(notdir $@)-local.sh ] && KERNEL='$used_kernelversion' KERNELVERSION=$(KERNELVERSION) LIBC='$used_libc' BOXTYPE=$(BOXTYPE) BOXMODEL=$(BOXMODEL) $(customizationsdir)/$(notdir $@)-local.sh $(flashprefix) $(buildprefix) || true]'
AC_SUBST(TUXBOX_CUSTOMIZE)
TUXBOX_YADD_CUSTOMIZE='[[ -x $(customizationsdir)/$(notdir $@)-local.sh ] && KERNEL='$used_kernelversion' KERNELVERSION=$(KERNELVERSION) LIBC='$used_libc' BOXTYPE=$(BOXTYPE) BOXMODEL=$(BOXMODEL) $(customizationsdir)/$(notdir $@)-local.sh $(targetprefix) $(buildprefix) || true]'
AC_SUBST(TUXBOX_YADD_CUSTOMIZE)
FLASHROOTDIR_MODIFIED='touch $(flashprefix)/root'
AC_SUBST(FLASHROOTDIR_MODIFIED)


AC_CONFIG_FILES([
Makefile
rules-downcheck.pl
])

case "${BOXTYPE}" in
	dreambox)
	AC_CONFIG_FILES([
root_dream/Makefile
root_dream/etc/Makefile
root_dream/etc/init.d/Makefile
root_dream/share/Makefile
root_dream/share/tuxbox/Makefile
root_dream/share/udhcpc/Makefile
root_dream/var_init/Makefile
root_dream/var_init/etc/Makefile
root_dream/var_init/etc/init.d/Makefile
root_dream/var_init/etc/network/Makefile
root_dream/var_init/tuxbox/Makefile
root_dream/var_init/tuxbox/config/Makefile
root_dream/var_init/tuxbox/config/enigma/Makefile
])
	;;
	*)
	AC_CONFIG_FILES([
root/Makefile
root/etc/Makefile
root/etc/init.d/Makefile
root/etc/network/Makefile
root/share/Makefile
root/share/udhcpc/Makefile
])
	;;
esac

AC_CONFIG_COMMANDS([rules-downcheck-chmod],[chmod +x rules-downcheck.pl])

AC_OUTPUT
