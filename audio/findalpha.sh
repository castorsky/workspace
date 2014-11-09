#!/bin/bash

# Usage:
# findalpha [-R]

# Reorder the directory entries according to alphanumerical order, so
# find output is in order.  Useful for preparing files for play on an
# MP3 player that follows directory order.
# If -R is given, do recursively.

# Thu Dec 27 02:47:00 EST 2007 v. 0.1 jh initial version
# Wed Oct 22 11:08:00 EST 2008 v. 0.2 andrew-regner added support for directories with spaces
# Sun Nov 09 12:36:00 GMT+8 2014 v. 0.3 castor reworked with function and more xargs

# TODO:
# figure out why it works on IDE but not on USB, even if the FS is ext3

START_DIR="`pwd`"

if [ "$1" = "-R" ] ; then
    ARGS="-mindepth 1"
else
    ARGS="-maxdepth 1 -mindepth 1"
fi

process_dir() {
    cd "$1"
    tmp=`mktemp -d -p .`
    find . -maxdepth 1 -mindepth 1 | grep -v $tmp | xargs -n1 -d"\n" -I'{}' mv '{}' $tmp
    cd $tmp
    find . -maxdepth 1 -mindepth 1 | sort -n | xargs -n1 -d"\n" -I'{}' mv '{}' ..
    cd ..
    rmdir $tmp
    cd "$START_DIR"
}
export -f process_dir

find . $ARGS -type d -print0 | xargs -L 1 -0 -I{} bash -c "process_dir  \"{}\""
