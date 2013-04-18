#! /bin/bash
#
# this script automatically updates the sources for the CocoaAsyncSocket ios library
#
# to upgrade to a new version, change the version number below
#
# as long as the download link is formatted in the same way and folder
# structure are the same, this script should *just work*
#
# 2013 Dan Wilcox <danomatika@gmail.com> 
#

WD=$(dirname $0)
destDir=../libs/CocoaAsyncSocket

###

# move to this scripts dir
cd $WD

# get latest source
git clone git://github.com/robbiehanson/CocoaAsyncSocket.git

# create destination dir
mkdir -pv $destDir/GCD
mkdir -pv $destDir/RunLoop

# copy sources
cp -v CocoaAsyncSocket/GCD/*.h $destDir/GCD
cp -v CocoaAsyncSocket/GCD/*.m $destDir/GCD
cp -v CocoaAsyncSocket/RunLoop/*.h $destDir/RunLoop
cp -v CocoaAsyncSocket/RunLoop/*.m $destDir/RunLoop

# cleanup
rm -rf CocoaAsyncSocket

