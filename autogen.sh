#!/bin/sh

package="tuxbox-cdk"

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

cd "$srcdir"

mkdir .deps >/dev/null 2>&1

echo "Generating configuration files for $package, please wait...."

autoreconf -f -i -s

