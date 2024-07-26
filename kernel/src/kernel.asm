extern vga_print
extern vga_putc

section .data
    msg db "string"
    len equ 6

section .text
global kernel
kernel:
    extern init_vga
    call init_vga

    mov eax, msg
    mov ecx, len
    call vga_print

    ret