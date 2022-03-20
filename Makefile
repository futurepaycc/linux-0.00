# Makefile for the simple example kernel.
AS86	=as86 -0 -a
LD86	=ld86 -0
AS	=as --32
LD	=ld
LDFLAGS =-m elf_i386 -Ttext 0 -e startup_32 -s -x -M  

all: Image

boot: boot.s
	$(AS86) -o bin/boot.o boot.s
	$(LD86) -s -o bin/boot bin/boot.o

bin/head.o:
	$(AS) head.s -o bin/head.o

system:	bin/head.o 
	$(LD) $(LDFLAGS) bin/head.o  -o bin/system > bin/System.map

Image: boot system
	dd bs=32 if=bin/boot of=bin/Image skip=1
	objcopy -R .note.gnu.property -O binary bin/system bin/head
	cat bin/head >> bin/Image

bochs_run:
	bochs -qf bochsrc

qemu_run:
	qemu-system-i386 -drive file=bin/Image,if=floppy,format=raw

clean:
	rm -f bin/Image bin/System.map bin/core bin/boot bin/head bin/*.o bin/system
