section .text
global kernel
kernel:
    extern init_vga
    call init_vga

    mov bx, 'a'
    extern vga_putc
    call vga_putc

    ret