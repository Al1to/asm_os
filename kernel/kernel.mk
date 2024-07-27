AS:=nasm -f elf32
CC:=gcc -m32
CFLAGS:=-ffreestanding -O2 -Wall -Wextra -nostdlib
LIBS:=-lgcc

OBJECTS:=\
build/boot.o\
build/kernel.o\
build/vga.o\
build/gdt.o\
build/memset.o\
build/idt.o\

iso: build os.iso
	
os.iso: build/isodir/boot/os.bin build/isodir/boot/grub/grub.cfg
	grub-mkrescue -o $@ build/isodir

build/isodir/boot/grub/grub.cfg: kernel/grub.cfg build/isodir/boot/grub
	cp $< $@

build/isodir/boot/os.bin: build/os.bin build/isodir/boot
	cp $< $@

build build/isodir build/isodir/boot build/isodir/boot/grub:
	mkdir -p $@

build/os.bin: $(OBJECTS) kernel/linker.ld
	$(CC) -T kernel/linker.ld -fno-pic -Wl,--build-id=none -o $@ $(CFLAGS) $(OBJECTS) $(LIBS)

build/%.o: kernel/src/%.asm
	$(AS) $< -g -o $@

build/%.o: kernel/src/util/%.asm
	$(AS) $< -g -o $@