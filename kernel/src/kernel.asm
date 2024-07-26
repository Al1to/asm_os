extern vga_print

section .data
    msg db "El psy cogroo."
    len equ $-msg

section .text
global kernel
kernel:
    extern init_vga
    call   init_vga

    extern init_gdt
    call   init_gdt

    mov eax, msg
    mov ecx, len
    call vga_print

    ret