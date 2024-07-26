include ./kernel/kernel.mk

all: iso

run: iso
	qemu-system-i386 -cdrom os.iso

run-dbg: iso
	qemu-system-i386 -s -S -cdrom os.iso

dump:
	objdump -D build/os.bin > dump.txt

clean:
	rm -rf build os.iso