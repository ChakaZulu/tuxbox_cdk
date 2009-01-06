#!/bin/sh

package="tuxbox-cdk"

LIBTOOL_REQUIRED_VERSION=1.4.2
AUTOCONF_REQUIRED_VERSION=2.57a
AUTOMAKE_REQUIRED_VERSION=1.8
GETTEXT_REQUIRED_VERSION=0.12.1
MAKE_REQUIRED_VERSION=3.80
GCC_REQUIRED_VERSION=3.0
GCC_ALTERNATE_VERSION=2.95
GPP_REQUIRED_VERSION=3.0
GPP_ALTERNATE_VERSION=2.95

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

cd "$srcdir"

check_version ()
{
	firstL=`echo $1|cut -f 1 -d '.'`
	secondL=`echo $1|cut -f 2 -d '.'`
	thirdL=`echo $1|cut -f 3 -d '.'`
	firstR=`echo $2|cut -f 1 -d '.'`
	secondR=`echo $2|cut -f 2 -d '.'`
	thirdR=`echo $2|cut -f 3 -d '.'`
	if [ -z $secondL ]; then secondL="0"; fi
	if [ -z $secondR ]; then secondR="0"; fi
	if [ -z $thirdL ]; then thirdL="0"; fi
	if [ -z $thirdR ]; then thirdR="0"; fi
	if expr $firstL \> $firstR \| \( $firstL = $firstR \& $secondL \> $secondR \) \| \( $firstL = $firstR \& $secondL = $secondR \& $thirdL \>= $thirdR \) > /dev/null; then
		echo "yes (version $1)"
	else
		echo "Too old (found version $1)!"
		DIE=1
	fi
}

check_version_alternate ()
{
    if expr $1 \>= $2 > /dev/null || expr $1 = $3 > /dev/null ; then
        echo "yes (version $1)"
    else
        echo "Inappropriate (found version $1)!"
        DIE=1
    fi
}

echo
echo "I am testing that you have the required versions of libtool, autoconf," 
echo "automake, make, gettext, gcc, and g++."
echo

DIE=0

echo -n "checking for libtool >= $LIBTOOL_REQUIRED_VERSION ... "
if (libtoolize --version) < /dev/null > /dev/null 2>&1; then
    VER=`libtoolize --version \
         | grep libtool | sed "s/.* \([0-9.]*\)[-a-z0-9]*$/\1/"`
    check_version $VER $LIBTOOL_REQUIRED_VERSION
else
    echo
    echo "  You must have libtool installed to compile $PROJECT."
    echo "  Install the appropriate package for your distribution,"
    echo "  or get the source tarball at ftp://ftp.gnu.org/pub/gnu/"
    DIE=1;
fi

echo -n "checking for autoconf >= $AUTOCONF_REQUIRED_VERSION ... "
if (autoconf --version) < /dev/null > /dev/null 2>&1; then
    VER=`autoconf --version \
         | grep -iw autoconf | sed "s/.* \([0-9.]*\)[-a-z0-9]*$/\1/"`
    check_version $VER $AUTOCONF_REQUIRED_VERSION
else
    echo
    echo "  You must have autoconf installed to compile $PROJECT."
    echo "  Download the appropriate package for your distribution,"
    echo "  or get the source tarball at ftp://ftp.gnu.org/pub/gnu/"
    DIE=1;
fi

echo -n "checking for automake >= $AUTOMAKE_REQUIRED_VERSION ... "
if (automake --version) < /dev/null > /dev/null 2>&1; then
    VER=`automake --version \
         | grep automake | sed "s/.* \([0-9.]*\)[-a-z0-9]*$/\1/"`
    check_version $VER $AUTOMAKE_REQUIRED_VERSION
else
    echo
    echo "  You must have automake installed to compile $PROJECT."
    echo "  Get ftp://ftp.cygnus.com/pub/home/tromey/automake-1.4p1.tar.gz"
    echo "  (or a newer version if it is available)"
    DIE=1
fi

echo -n "checking for gettext >= $GETTEXT_REQUIRED_VERSION ... "
if (gettext --version) < /dev/null > /dev/null 2>&1; then
    VER=`gettext --version \
         | grep gettext | sed "s/.* \([0-9.]*\)[-a-z0-9]*$/\1/"`
    check_version $VER $GETTEXT_REQUIRED_VERSION
else
    echo
    echo "  You must have gettext installed to compile $PROJECT."
    DIE=1
fi

echo -n "checking for make >= $MAKE_REQUIRED_VERSION ... "
if (make --version) < /dev/null > /dev/null 2>&1; then
    VER=`make --version \
         | grep -i make | sed "s/.* \([0-9.]*\)[-a-z0-9]*$/\1/"`
    check_version $VER $MAKE_REQUIRED_VERSION
else
    echo
    echo "  You must have make installed to compile $PROJECT."
    DIE=1
fi

echo -n "checking for gcc >= $GCC_REQUIRED_VERSION or = $GCC_ALTERNATE_VERSION ... "
if (gcc --version) < /dev/null > /dev/null 2>&1; then
    VER=`gcc --version \
         | grep gcc | cut -f3 -d " "`
    check_version_alternate $VER $GCC_REQUIRED_VERSION $GCC_ALTERNATE_VERSION
else
    echo
    echo "  You must have gcc installed to compile $PROJECT."
    DIE=1
fi

echo -n "checking for g++ >= $GPP_REQUIRED_VERSION or = $GPP_ALTERNATE_VERSION ... "
if (g++ --version) < /dev/null > /dev/null 2>&1; then
    VER=`g++ --version \
         | grep g++ | cut -f3 -d " "`
    check_version_alternate $VER $GPP_REQUIRED_VERSION $GPP_ALTERNATE_VERSION
else
    echo
    echo "  You must have g++ installed to compile $PROJECT."
    DIE=1
fi

if test "$DIE" -eq 1; then
    echo
    echo "Please install/upgrade the missing tools and call me again."
    echo	
    exit 1
fi

mkdir .deps >/dev/null 2>&1

echo
echo "Generating configuration files for $package, please wait...."

autoreconf -f -i -s

