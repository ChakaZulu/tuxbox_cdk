#!/bin/sh
# run this once to get tuxbox cdk running under cygwin
# (p) +tbn 2002
# 
cd ../boot && patch -p1 < ../cdk/Patches/cygwin/ppcboot.diff
cd ../cdk && cp Patches/cygwin/mkimage.exe ../boot/ppcboot/tools/
