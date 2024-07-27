section .data
    gdt_entry_size equ 8
    tss_entry_size equ 108

    gdt_ptr dw 0  ; limit
            dd 0  ; base

section .text
; in:  void
; out: void
global init_gdt
init_gdt:
    push eax
    push ebx
    push ecx
    push edx

    mov ax, gdt_entry_size
    imul ax, 6
    dec ax
    mov word [gdt_ptr], ax

    lea eax, gdt_entries
    mov dword [gdt_ptr + 2], eax

    ; null
    xor eax, eax
    xor ebx, ebx
    xor dx, dx
    call set_gdt_gate

    mov ebx, 0xFFFFFFFF

    ; kernel code
    inc eax
    xor ecx, ecx
    mov dx, 0xCF9A
    call set_gdt_gate

    ; kernel data
    inc eax
    xor ecx, ecx
    mov dx, 0xCF92
    call set_gdt_gate

    ; user code
    inc eax
    xor ecx, ecx
    mov dx, 0xCFFA
    call set_gdt_gate

    ; user data
    inc eax
    xor ecx, ecx
    mov dx, 0xCFF2
    call set_gdt_gate

    ; tss
    inc eax
    call set_tss_entry

    lea eax, gdt_ptr
    lgdt [eax]
    mov eax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    jmp 0x08:.end

    .end:
        mov ax, 0x2B
        ltr ax

        pop edx
        pop ecx
        pop ebx
        pop eax
        ret

; in:  eax = num, ebx = limit, ecx = base, dx = flags 0x0F00 | access 0x00FF
; out: void
; modifies: ecx, dx
set_gdt_gate:
    mov word [gdt_entries + (gdt_entry_size * eax) + 0], bx  ; limit   0-15

    mov word [gdt_entries + (gdt_entry_size * eax) + 2], cx  ; base    16-31
    shr ecx, 2
    mov byte [gdt_entries + (gdt_entry_size * eax) + 4], cl  ; base    32-39

    mov byte [gdt_entries + (gdt_entry_size * eax) + 5], dl  ; access  40-47

    push cx
    mov ecx, ebx
    and ecx, 0x00000F00
    shr ecx, 8
    and dx, 0x0F00
    shr dx, 4
    add cx, dx
    mov byte [gdt_entries + (gdt_entry_size * eax) + 6], cl  ; limit 48-51 | flags 52-55

    pop cx
    shr cx, 1
    mov byte [gdt_entries + (gdt_entry_size * eax) + 7], cl  ; base 56-63

    ret

; in:  eax = num
; out: void
set_tss_entry:
    push eax
    push ebx
    push ecx
    push edx

    mov ebx, tss_entry_size
    lea ecx, tss_entry
    xor dl, dl
    extern memset
    call   memset

    add ebx, ecx
    mov dx, 0x00E9
    call set_gdt_gate

    mov dword [tss_entry + 8], 0x10

    mov eax, 8
    or eax, 3
    mov dword [tss_entry + 76], eax   ; cs

    mov eax, 10
    or eax, 3
    mov dword [tss_entry + 72], eax   ; es
    mov dword [tss_entry + 80], eax   ; ss
    mov dword [tss_entry + 84], eax   ; ds
    mov dword [tss_entry + 88], eax   ; fs
    mov dword [tss_entry + 92], eax   ; gs

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

section .bss
    gdt_entries resb gdt_entry_size * 6
    tss_entry resb 27 * 4
