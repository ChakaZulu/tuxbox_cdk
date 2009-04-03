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
AC_ARG_WITH(boxtype,
	[  --with-boxtype=NAME box type [[dbox2,tripledragon,generic,dm7000,dm500,dm56x0,dm600pvr...]]],
	[BOXTYPE="$withval"],[BOXTYPE="dbox2"])

AC_SUBST(BOXTYPE)

AM_CONDITIONAL(BOXTYPE_DBOX2, test "$BOXTYPE" = "dbox2")
AM_CONDITIONAL(BOXTYPE_TRIPLE, test "$BOXTYPE" = "tripledragon")
AM_CONDITIONAL(BOXTYPE_GENERIC, test "$BOXTYPE" = "generic")
AM_CONDITIONAL(BOXTYPE_DREAMBOX, test "$BOXTYPE" != "dbox2" -a "$BOXTYPE" != "tripledragon" -a "$BOXTYPE" != "generic")

if test "$BOXTYPE" = "dbox2"; then
	AC_DEFINE(HAVE_DBOX_HARDWARE, 1, [building for a dbox2])
elif test "$BOXTYPE" = "tripledragon"; then
	AC_DEFINE(HAVE_TRIPLEDRAGON, 1, [building for a tripledragon])
elif test "$BOXTYPE" = "generic"; then
	AC_DEFINE(HAVE_GENERIC_HARDWARE, 1, [building for a generic device like a standard PC])
else	# many dreamboxes, don't list them one by one...
	AC_DEFINE(HAVE_DREAMBOX_HARDWARE, 1, [building for a dreambox])
fi

])
