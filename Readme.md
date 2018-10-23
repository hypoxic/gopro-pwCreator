# GoPro Password Dictionary File Creator

I do a lot of "deciphering of code" via static analysis. After seeing KonradIt's post and wanting to do this exercisse for awhile, I wanted to determine every possible wifi password. The latest GoPro's set a password using the following convention: \[sport\]\[0-9\]\[0-9\]\[0-9\]\[0-9\] ie. wave1234. To determine all the possible password combinations I would need to sniff all the prefixes. Reviewing the code was quite complicated due to some obfuscation. However, I thought this would be a great time to use a dynamic analysis method with Docker. After learning docker, and creating an image ran by QEMU-arm, I couldn't debug the code. I realized QEMU can't/does virtualize the hardware breakpoints and therefore can run gdb. After some research I went to justing the gdb like server built into qemu itself. Check out my methodology and the resulting password dictionary file. 

Reference for running & debugging ARM code found in the linux sub-process

Compile bunpack.c & run to extract Sections from update. Pass the whole directory as an attribute. Sorry this was precompiled for pc

Take sector08 and mount it in linux 
```
mkdir -p ./romfs
mkdir -p ./fs
sudo mount -o user ./sector08.bin ./romfs/
sudo bindfs -u $(id -u) -g $(id -g) ./romfs/ ./fs
```

Started with docker, but since the container is running on a qemu virtual machine there were some low-level hw isues with setting breakpoints etc. 
Easiest to debug straight out of in QEMU with the -g option. 

What I believe my setup was 
`sudo apt-get install gcc-arm-linux-gnueabihf qemu qemu-user qemu-user-static binfmt-support gdb-multiarch`

now copy the static library into the created filesystem
```
cp /usr/bin/qemu-arm-static /home/trunk/gopro/hero7/fs
mkdir -p /home/trunk/gopro/hero7/fs/tmp/fuse_d
mkdir -p /home/trunk/gopro/hero7/fs/tmp/fuse_d/MISC
mkdir -p /home/trunk/gopro/hero7/fs/tmp/fuse_a
mkdir -p /home/trunk/gopro/hero7/fs/tmp/fuse_b
```

Depending on what you are doing, copy your fuse_b mfg.json and bin files to fuse_b
NOTE: fuse_a keeps a backup of conf.json.bak

the password creator needs /dev/urandom. Perfect, we can just make our own static version with something like
```
i=1
printf -v string '\\x%02x\\x%02x\\x%02x\\x%02x\\x%02x\\x%02x' $i 0 0 0 0 0
echo -ne $string > /home/trunk/gopro/hero7/fs/dev/urandom
```

patch & stub out your binary as needed. See 'gpNet_patch_definition.txt' I unfortunately couldn't get gdb/qemu to overwrite the .text section, so maunally editting I went.

Now start up the server
```
sudo chroot /home/trunk/gopro/hero7/fs ./qemu-arm-static -g 12345 -singlestep usr/local/gopro/bin/gpNet.patched
```

Then with a new terminal (or IDA) connect to the gdbserver with commands such as
`gdb-multiarch 
below can be a script. The breakpoint is set to the main function of the gpNet. Run doesn't work as there are no symbols. c is continue.
```
file gpNet.patched
target remote localhost:12345
set arch arm
layout asm
b *0x9FEC
c
```

if using IDA be sure to open up the ports in linux and in your client pc's firewall
