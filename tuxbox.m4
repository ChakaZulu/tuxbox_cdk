AC_DEFUN([TUXBOX_RULES_MAKE],[
DEPENDS_$1=`${srcdir}/rules-make.pl ${srcdir}/rules-make${MAKERULESETFILE} $1 depend`
AC_SUBST(DEPENDS_$1)dnl
PREPARE_$1=`${srcdir}/rules-make.pl ${srcdir}/rules-make${MAKERULESETFILE} $1 prepare`
AC_SUBST(PREPARE_$1)dnl
DIR_$1=`${srcdir}/rules-make.pl ${srcdir}/rules-make${MAKERULESETFILE} $1 dir`
AC_SUBST(DIR_$1)dnl
INSTALL_$1=`${srcdir}/rules-install.pl ${srcdir}/rules-install${INSTALLRULESETFILE} $1`
AC_SUBST(INSTALL_$1)dnl
CLEANUP_$1="rm -rf `${srcdir}/rules-make.pl ${srcdir}/rules-make${MAKERULESETFILE} $1 dir`"
AC_SUBST(CLEANUP_$1)dnl
])

AC_DEFUN([TUXBOX_RULES_MAKE_EXDIR],[
DEPENDS_$1=`${srcdir}/rules-make.pl ${srcdir}/rules-make${MAKERULESETFILE} $1 depend`
AC_SUBST(DEPENDS_$1)dnl
PREPARE_$1="`${srcdir}/rules-make.pl ${srcdir}/rules-make${MAKERULESETFILE} $1 prepare` && mkdir build"
AC_SUBST(PREPARE_$1)dnl
DIR_$1="build"
AC_SUBST(DIR_$1)dnl
CONFIGURE_$1="../`${srcdir}/rules-make.pl ${srcdir}/rules-make${MAKERULESETFILE} $1 dir`/configure"
AC_SUBST(CONFIGURE_$1)dnl
INSTALL_$1=`${srcdir}/rules-install.pl ${srcdir}/rules-install${INSTALLRULESETFILE} $1`
AC_SUBST(INSTALL_$1)dnl
CLEANUP_$1="rm -rf `${srcdir}/rules-make.pl ${srcdir}/rules-make${MAKERULESETFILE} $1 dir` build"
AC_SUBST(CLEANUP_$1)dnl
])

