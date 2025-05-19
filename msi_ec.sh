#!/bin/bash

kernel=$(uname -r)
srcKernel=kernel-${kernel%.*}.src.rpm
version=${kernel%%'-'*}
buildPath=~/rpmbuild/BUILD/kernel-${kernel%-*}-build/kernel-${kernel%-*}/linux-$kernel
sentenceToReplace=${kernel:${#version}:${#kernel}}
searchSentence='EXTRAVERSION ='
machine=$(uname -m)

rpmdev-setuptree

if [ -z "$1" ]
then
  echo "Download kernel source"
  yumdownloader --source kernel-$kernel
else
  echo "Download kernel source from url: "$1
  wget $1
fi

sudo yum-builddep $srcKernel
rpm -Uvh $srcKernel
cd ~/rpmbuild/SPECS
rpmbuild -bp --target=$machine kernel.spec
cd $buildPath
sed -i "s/$searchSentence/$searchSentence $sentenceToReplace/gi" Makefile
cp configs/kernel-$version-$machine.config .config
echo CONFIG_ACPI_EC_DEBUGFS=m >> .config
make modules_prepare

#added because in new kernel occurred problem
export KBUILD_MODPOST_WARN=1 

make M=drivers/acpi modules
sudo make M=drivers/acpi modules_install
sudo depmod -a
