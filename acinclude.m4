AC_DEFUN([TUXBOX_RULES_MAKE],[
AC_MSG_CHECKING([$1 rules])
eval `${srcdir}/rules.pl make ${srcdir}/rules-make $1 cdkoutput`
INSTALL_$1=`${srcdir}/rules.pl install ${srcdir}/rules-install${INSTALLRULESETFILE} $1`
CLEANUP_$1="rm -rf $DIR_$1"
CLEANUP="$CLEANUP $DIR_$1"
DEPSCLEANUP="$DEPSCLEANUP .deps/$1"
AC_SUBST(DEPENDS_$1)dnl
AC_SUBST(DIR_$1)dnl
AC_SUBST(PREPARE_$1)dnl
AC_SUBST(VERSION_$1)dnl
AC_SUBST(INSTALL_$1)dnl
AC_SUBST(CLEANUP_$1)dnl
AC_MSG_RESULT(done)
])

AC_DEFUN([TUXBOX_RULES_MAKE_EXDIR],[
AC_MSG_CHECKING([$1 rules])
eval `${srcdir}/rules.pl make ${srcdir}/rules-make $1 cdkoutput`
SOURCEDIR_$1=$DIR_$1
CONFIGURE_$1="../$DIR_$1/configure"
PREPARE_$1="$PREPARE_$1 && ( rm -rf build_$1 || /bin/true ) && mkdir build_$1"
INSTALL_$1=`${srcdir}/rules.pl install ${srcdir}/rules-install${INSTALLRULESETFILE} $1`
CLEANUP_$1="rm -rf $DIR_$1 build_$1"
CLEANUP="$CLEANUP $DIR_$1"
DIR_$1="build_$1"
AC_SUBST(CLEANUP_$1)dnl
AC_SUBST(CONFIGURE_$1)dnl
AC_SUBST(DEPENDS_$1)dnl
AC_SUBST(DIR_$1)dnl
AC_SUBST(INSTALL_$1)dnl
AC_SUBST(PREPARE_$1)dnl
AC_SUBST(SOURCEDIR_$1)dnl
AC_SUBST(VERSION_$1)dnl
AC_MSG_RESULT(done)
])

AC_DEFUN([TUXBOX_BOXTYPE],[

KERNELVERSION=check
CPU_ARCH="ppc"
CPU_MODEL="823"

AC_ARG_WITH(boxtype,
	[  --with-boxtype          valid values: dbox2,tripledragon,dreambox,ipbox,coolstream,generic],
	[case "${withval}" in
dnl		To-Do: extend CPU types and kernel versions when needed
		dbox2)
			BOXTYPE="$withval"
			;;
		dreambox)
			BOXTYPE="$withval"
			CPU_MODEL="405"
			AM_CONDITIONAL(KERNEL26, true)
			enable_kernel26=yes
			KERNELVERSION="\$(VERSION_linux_dream)"
			;;
		ipbox)
			BOXTYPE="$withval"
			CPU_MODEL="405"
			AM_CONDITIONAL(KERNEL26, true)
			enable_kernel26=yes
			KERNELVERSION="\$(VERSION_linux_ipbox)"
			;;
		tripledragon|generic)
			BOXTYPE="$withval"
			;;
		coolstream)
			BOXTYPE="$withval"
			CPU_ARCH="arm"
			CPU_MODEL="1176"
			target_alias="arm-cx2450x-linux-gnueabi"
			AM_CONDITIONAL(KERNEL26, true)
			enable_kernel26=yes
			enable_uclibc=no
			with_curlversion=current
			with_freetypeversion=current
			;;
		*)
			AC_MSG_ERROR([bad value $withval for --with-boxtype]) ;;
	esac], [BOXTYPE="dbox2"])

if test "$KERNELVERSION" = "check"; then
	AC_ARG_ENABLE(kernel26,
		AS_HELP_STRING(--enable-kernel26,set up the CDK to use the 2.6 kernel (experimental)),
		,[enable_kernel26=no])
	AM_CONDITIONAL(KERNEL26,test "$enable_kernel26" = "yes")
	if test "$enable_kernel26" = "yes"; then
		KERNELVERSION="\$(VERSION_linux)"
	else
		KERNELVERSION="\$(VERSION_linux24)"
	fi
fi

AC_ARG_WITH(boxmodel,
	[  --with-boxmodel         valid for dreambox: dm500, dm500plus, dm600pvr, dm56x0, dm7000, dm7020, dm7025)
                          valid for ipbox: ip200, ip250, ip350, ip400],
	[case "${withval}" in
		dm500|dm500plus|dm600pvr|dm56x0|dm7000|dm7020|dm7025)
			if test "$BOXTYPE" = "dreambox"; then
				BOXMODEL="$withval"
			else
				AC_MSG_ERROR([unknown model $withval for boxtype $BOXTYPE])
			fi
			;;
		ip200|ip250|ip350|ip400)
			if test "$BOXTYPE" = "ipbox"; then
				BOXMODEL="$withval"
			else
				AC_MSG_ERROR([unknown model $withval for boxtype $BOXTYPE])
			fi
			;;
		*)
			AC_MSG_ERROR([unsupported value $withval for --with-boxmodel])
			;;
	esac],
	[if test "$BOXTYPE" = "dreambox" -o "$BOXTYPE" = "ipbox"; then
		AC_MSG_ERROR([Dreambox/IPBox needs --with-boxmodel])
	fi])

AC_SUBST(BOXTYPE)
AC_SUBST(BOXMODEL)
AC_SUBST(CPU_ARCH)
AC_SUBST(CPU_MODEL)
AC_SUBST(KERNELVERSION)

AM_CONDITIONAL(BOXTYPE_DBOX2, test "$BOXTYPE" = "dbox2")
AM_CONDITIONAL(BOXTYPE_TRIPLE, test "$BOXTYPE" = "tripledragon")
AM_CONDITIONAL(BOXTYPE_DREAMBOX, test "$BOXTYPE" = "dreambox")
AM_CONDITIONAL(BOXTYPE_IPBOX, test "$BOXTYPE" = "ipbox")
AM_CONDITIONAL(BOXTYPE_COOL, test "$BOXTYPE" = "coolstream")
AM_CONDITIONAL(BOXTYPE_GENERIC, test "$BOXTYPE" = "generic")

AM_CONDITIONAL(BOXMODEL_DM500,test "$BOXMODEL" = "dm500")
AM_CONDITIONAL(BOXMODEL_DM500PLUS,test "$BOXMODEL" = "dm500plus")
AM_CONDITIONAL(BOXMODEL_DM600PVR,test "$BOXMODEL" = "dm600pvr")
AM_CONDITIONAL(BOXMODEL_DM56x0,test "$BOXMODEL" = "dm56x0")
AM_CONDITIONAL(BOXMODEL_DM7000,test "$BOXMODEL" = "dm7000" -o "$BOXMODEL" = "dm7020" -o "$BOXMODEL" = "dm7025")

AM_CONDITIONAL(BOXMODEL_IP200,test "$BOXMODEL" = "ip200")
AM_CONDITIONAL(BOXMODEL_IP250,test "$BOXMODEL" = "ip250")
AM_CONDITIONAL(BOXMODEL_IP350,test "$BOXMODEL" = "ip350")
AM_CONDITIONAL(BOXMODEL_IP400,test "$BOXMODEL" = "ip400")

AM_CONDITIONAL(CPUMODEL_405,test "$CPU_MODEL" = "405")

if test "$BOXTYPE" = "dbox2"; then
	AC_DEFINE(HAVE_DBOX_HARDWARE, 1, [building for a dbox2])
elif test "$BOXTYPE" = "tripledragon"; then
	AC_DEFINE(HAVE_TRIPLEDRAGON, 1, [building for a tripledragon])
elif test "$BOXTYPE" = "dreambox"; then
	AC_DEFINE(HAVE_DREAMBOX_HARDWARE, 1, [building for a dreambox])
elif test "$BOXTYPE" = "ipbox"; then
	AC_DEFINE(HAVE_IPBOX_HARDWARE, 1, [building for an ipbox])
elif test "$BOXTYPE" = "coolstream"; then
	AC_DEFINE(HAVE_COOL_HARDWARE, 1, [building for a coolstream])
elif test "$BOXTYPE" = "generic"; then
	AC_DEFINE(HAVE_GENERIC_HARDWARE, 1, [building for a generic device like a standard PC])
fi

])
