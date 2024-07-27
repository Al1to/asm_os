section .data
    idt_entry_size equ 8

    exception db "Exception! System Halted!"
    exception_len equ $-exception

    irq_routines times 16 dd 0

    idt_ptr dw 0  ; limit
            dd 0  ; base

%macro set_isr 1
    mov eax, %1
    lea ebx, isr%1
    call set_gdt_gate
%endmacro

%macro set_irq 2
    mov eax, %1
    lea ebx, irq%2
    call set_gdt_gate
%endmacro

section .text
; in:  void
; out: void
global init_idt
init_idt:
    push eax
    push ebx
    push ecx
    push edx

    mov ebx, 2048
    lea ecx, idt_entries
    xor dl, dl
    extern memset
    call   memset

    dec ebx
    mov word [idt_ptr], ebx
    mov dword [idt_ptr + 2], ecx

    mov al, 0x20
    mov bl, 0xA0
    mov cl, 0x11

    out al, cl
    out bl, cl

    mov cl, al
    inc al
    inc bl
    mov dl, 0x28

    out al, cl
    out bl, dl

    mov cl, 0x04
    mov dl, 0x02

    out al, cl
    out bl, dl

    mov cl, 0x01
    xor dl, dl

    out al, cl
    out bl, cl

    out al, dl
    out bl, dl

    mov ecx, 0x08
    mov edx, 0x8E

    set_isr 0
    set_isr 1
    set_isr 2
    set_isr 3
    set_isr 4
    set_isr 5
    set_isr 6
    set_isr 7
    set_isr 8
    set_isr 9
    set_isr 10
    set_isr 11
    set_isr 12
    set_isr 13
    set_isr 14
    set_isr 15
    set_isr 16
    set_isr 17
    set_isr 18
    set_isr 19
    set_isr 20
    set_isr 21
    set_isr 22
    set_isr 23
    set_isr 24
    set_isr 25
    set_isr 26
    set_isr 27
    set_isr 28
    set_isr 29
    set_isr 30
    set_isr 31

    set_irq 32, 0
    set_irq 33, 1
    set_irq 34, 2
    set_irq 35, 3
    set_irq 36, 4
    set_irq 37, 5
    set_irq 38, 6
    set_irq 39, 7
    set_irq 40, 8
    set_irq 41, 9
    set_irq 42, 10
    set_irq 43, 11
    set_irq 44, 12
    set_irq 45, 13
    set_irq 46, 14
    set_irq 47, 15

    mov eax, 0x80
    lea ebx, syscall_handler
    call set_idt_gate

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; in:  eax = num, ebx = offset, ecx = selector, edx = flags
; out: void
set_idt_gate:
    mov  word [idt_entries + eax * idt_entry_size + 0], bx   ; offset     0-15
    mov dword [idt_entries + eax * idt_entry_size + 2], ecx  ; selector  16-31
    mov  byte [idt_entries + eax * idt_entry_size + 6], 0    ; zero      32-39
    mov  byte [idt_entries + eax * idt_entry_size + 7], edx  ; flags     40-47
    push ebx
    shr  ebx, 2
    mov  word [idt_entries + eax * idt_entry_size + 0], bx   ; offset    48-63
    pop  ebx

    ret

; in:  -
; out: void
isr_handler:
    pusha
    mov eax, ds
    push eax
    mov eax, cr2
    push eax

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; push esp
    ; ...

    mov eax, exception
    mov ecx, exception_len
    call vga_print

    add esp, 8
    pop ebx
    mov ds, bx
    mov es, bx
    mov fs, bx 
    mov gs, bx

    popa
    add esp, 8
    sti
    iret

; in:  -
; out: void
irq_handler:
    pusha
    mov eax, ds
    push eax
    mov eax, cr2
    push eax

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; push esp
    ; ...

    add esp, 8
    pop ebx
    mov ds, bx
    mov es, bx
    mov fs, bx 
    mov gs, bx

    popa
    add esp, 8
    sti
    iret

; in:  -
; out: void
syscall_handler:
    cli
    push long 0
    push long 0x80

    pusha
    mov eax, ds
    push eax
    mov eax, cr2
    push eax

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; push esp
    ; ...

    add esp, 8
    pop ebx
    mov ds, bx
    mov es, bx
    mov fs, bx 
    mov gs, bx

    popa
    add esp, 8
    sti
    iret

; in:  eax = num, ebx = &handler
; out: void
global install_irq_handler
install_irq_handler:
    mov dword [irq_routines + eax * 4], ebx
    ret

; in:  eax = num
; out: void
global uninstall_irq_handler
uninstall_irq_handler:
    mov dword [irq_routines + eax * 4], 0
    ret

%macro ISR_NOERRCODE 1
    global isr%1
    isr%1:
        cli
        push long 0
        push long %1
        jmp isr_handler
%endmacro

%macro ISR_ERRCODE 1
    global isr%1
    isr%1:
        cli
        push long %1
        jmp isr_handler
%endmacro

%macro IRQ 2
    global irq%1
    irq%1:
        cli
        push long 0
        push long %2
        jmp irq_handler
%endmacro

ISR_NOERRCODE   0
ISR_NOERRCODE   1
ISR_NOERRCODE   2
ISR_NOERRCODE   3
ISR_NOERRCODE   4
ISR_NOERRCODE   5
ISR_NOERRCODE   6
ISR_NOERRCODE   7

ISR_ERRCODE     8
ISR_NOERRCODE   9
ISR_ERRCODE    10
ISR_ERRCODE    11
ISR_ERRCODE    12
ISR_ERRCODE    13
ISR_ERRCODE    14

ISR_NOERRCODE  15
ISR_NOERRCODE  16
ISR_NOERRCODE  17
ISR_NOERRCODE  18
ISR_NOERRCODE  19
ISR_NOERRCODE  20
ISR_NOERRCODE  21
ISR_NOERRCODE  22
ISR_NOERRCODE  23
ISR_NOERRCODE  24
ISR_NOERRCODE  25
ISR_NOERRCODE  26
ISR_NOERRCODE  27
ISR_NOERRCODE  28
ISR_NOERRCODE  29
ISR_NOERRCODE  30
ISR_NOERRCODE  31

IRQ  0, 32
IRQ  1, 33
IRQ  2, 34
IRQ  3, 35
IRQ  4, 36
IRQ  5, 37
IRQ  6, 38
IRQ  7, 39
IRQ  8, 40
IRQ  9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46
IRQ 15, 47    

section .bss
    idt_entries resb idt_entry_size * 256